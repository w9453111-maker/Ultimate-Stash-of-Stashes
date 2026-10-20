-- SaltyWalty database setup for Supabase
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now()
);

create or replace function public.create_profile_for_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
declare
  requested_username text;
begin
  requested_username := lower(coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)));
  requested_username := regexp_replace(requested_username, '[^a-z0-9_-]', '', 'g');
  if length(requested_username) < 3 then
    requested_username := 'user_' || substr(new.id::text, 1, 8);
  end if;
  if requested_username = 'saltywalty' then
    requested_username := 'saltywalty_' || substr(new.id::text, 1, 6);
  end if;
  insert into public.profiles (id, username, role)
  values (new.id, requested_username, 'user')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_profile on auth.users;
create trigger on_auth_user_created_profile
after insert on auth.users
for each row execute procedure public.create_profile_for_new_user();

create or replace function public.is_saltywalty_admin()
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin' and username = 'saltywalty'
  );
$$;

create table if not exists public.pages (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 80),
  parent_id uuid references public.pages(id) on delete set null,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.sites (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 100),
  url text not null check (url ~* '^https?://'),
  image_url text,
  about text check (about is null or length(about) <= 1000),
  page_id uuid references public.pages(id) on delete set null,
  submitted_by uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.pages enable row level security;
alter table public.sites enable row level security;

drop policy if exists "Users can read their own profile" on public.profiles;
create policy "Users can read their own profile" on public.profiles
for select to authenticated using (id = auth.uid() or public.is_saltywalty_admin());

drop policy if exists "Public can read pages" on public.pages;
create policy "Public can read pages" on public.pages
for select to anon, authenticated using (true);

drop policy if exists "Admin can add pages" on public.pages;
create policy "Admin can add pages" on public.pages
for insert to authenticated with check (public.is_saltywalty_admin() and created_by = auth.uid());

drop policy if exists "Admin can edit pages" on public.pages;
create policy "Admin can edit pages" on public.pages
for update to authenticated using (public.is_saltywalty_admin()) with check (public.is_saltywalty_admin());

drop policy if exists "Admin can delete pages" on public.pages;
create policy "Admin can delete pages" on public.pages
for delete to authenticated using (public.is_saltywalty_admin());

drop policy if exists "Public can read approved sites" on public.sites;
create policy "Public can read approved sites" on public.sites
for select to anon, authenticated using (status = 'approved' or submitted_by = auth.uid() or public.is_saltywalty_admin());

drop policy if exists "Signed-in users can submit pending sites" on public.sites;
create policy "Signed-in users can submit pending sites" on public.sites
for insert to authenticated with check (submitted_by = auth.uid() and status = 'pending');

drop policy if exists "Admin can edit sites" on public.sites;
create policy "Admin can edit sites" on public.sites
for update to authenticated using (public.is_saltywalty_admin()) with check (public.is_saltywalty_admin());

drop policy if exists "Admin can delete sites" on public.sites;
create policy "Admin can delete sites" on public.sites
for delete to authenticated using (public.is_saltywalty_admin());

grant usage on schema public to anon, authenticated;
grant select on public.pages to anon, authenticated;
grant select, insert, update, delete on public.pages to authenticated;
grant select on public.sites to anon, authenticated;
grant insert, update, delete on public.sites to authenticated;
grant select on public.profiles to authenticated;

-- After creating the admin user in Supabase Authentication with:
-- email: saltywalty@saltywalty.local
-- password: use the admin password you chose
-- run this once to grant admin privileges (replace the email if you used a different one):
-- update public.profiles
-- set username = 'saltywalty', role = 'admin'
-- where id = (select id from auth.users where email = 'saltywalty@saltywalty.local');
