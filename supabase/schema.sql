-- SaltyWalty sites table starter for Supabase.
-- Run in Supabase SQL Editor. Read README.md before enabling a public launch.
create extension if not exists pgcrypto;

create table if not exists public.sites (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 100),
  url text not null check (url ~* '^https?://'),
  image_url text check (image_url is null or image_url ~* '^https?://'),
  description text check (description is null or char_length(description) <= 600),
  category text not null default 'other' check (category in ('tools','creative','fun','learning','other')),
  status text not null default 'pending' check (status in ('pending','approved','disapproved')),
  created_at timestamptz not null default now()
);

alter table public.sites enable row level security;

drop policy if exists "Public reads approved sites" on public.sites;
create policy "Public reads approved sites"
on public.sites for select to anon, authenticated
using (status = 'approved');

drop policy if exists "Public submits pending sites" on public.sites;
create policy "Public submits pending sites"
on public.sites for insert to anon, authenticated
with check (status = 'pending');

-- Intentionally no public update/delete policy.
-- Configure Supabase Auth and an admin-only policy before enabling moderation.
