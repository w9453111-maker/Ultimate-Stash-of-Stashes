# SaltyWalty

A small website directory: visitors can browse approved links without an account; signed-in users can submit a site; the admin can approve, disapprove, edit, or delete submissions and organize links into pages and subpages.

## Connect the database

1. Create/open your Supabase project.
2. Open **SQL Editor**, paste the contents of `supabase/schema.sql`, and run it.
3. In **Project Settings → API**, copy the Project URL and the publishable/anon key.
4. In `index.html`, replace `YOUR_SUPABASE_PROJECT_URL` and `YOUR_SUPABASE_ANON_KEY` with those two values. Never put a service-role key in this website.
5. In Supabase **Authentication → Providers → Email**, turn off email confirmation if you want username/password accounts to work without email verification.

## Create the admin account

1. In Supabase **Authentication → Users**, add a user with email `saltywalty@saltywalty.local` and the admin password you chose.
2. In **SQL Editor**, run:

```sql
update public.profiles
set username = 'saltywalty', role = 'admin'
where id = (
  select id from auth.users
  where email = 'saltywalty@saltywalty.local'
);
```

Sign in to SaltyWalty using the username `saltywalty` and that password. Regular users sign in with their email and password; the username they choose is shown on their profile.

## Publish with GitHub Pages

The included workflow deploys the site from the `main` branch. In your repository, open **Settings → Pages** and select **GitHub Actions** as the source. Then open **Actions** to watch the deployment.

## Included behavior

- Browse approved sites without signing in.
- Signed-in users can submit a required name and link, plus an optional image, description, and page.
- New submissions stay pending until an admin approves them.
- Admins can disapprove, edit, or delete submissions.
- Admins can create nested pages in the sidebar and assign links to them.

The Supabase connection must be configured before accounts, shared submissions, moderation, and pages work. The public website only uses the Supabase publishable/anon key; access is restricted by the database policies in `supabase/schema.sql`.
