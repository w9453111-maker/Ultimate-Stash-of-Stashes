# SaltyWalty — Ultimate Stash of Stashes

A responsive directory for discovering and sharing websites, rebuilt from the feature notes available from the original SaltyWalty project.

## Features
- Dark, gradient-rich responsive design with a sidebar navigation
- Search across site names, URLs, descriptions, and categories
- Category filters: Tools, Creative, Fun stuff, Learning, and Other gems
- Website cards with external links, optional cover image, description, and category
- Submission form for a site name and URL, with optional image and description
- Admin sidebar with submission queue, approve, disapprove, edit, and delete actions
- Sample entries so the site has content immediately
- GitHub Pages Actions workflow

## Important limitations
This is a working **browser-local prototype**, not yet a shared multi-user application. Site submissions and admin changes are stored in the current browser's localStorage. They do not sync to other visitors, browsers, or devices. The demo admin login is client-side and is not secure authentication.

For a public shared directory, connect Supabase or another backend and enforce authorization in the database/server. The included SQL is a secure starting point for public reads of approved sites and public inserts as pending; it intentionally does not grant anonymous users permission to approve, edit, or delete.

## Demo admin login
In index.html, near the start of the script, change the ADMIN_USERNAME and ADMIN_PASSWORD constants. The current username is saltywalty and the password placeholder is CHANGE_THIS_PASSWORD. Set a test password before trying the local admin interface. Do not treat this browser-only gate as real security, and do not use a real password you rely on elsewhere.

## Publish with GitHub Pages
1. Open this repository's Settings → Pages.
2. Under Build and deployment, choose **GitHub Actions**.
3. Open Actions and make sure the “Deploy SaltyWalty to GitHub Pages” workflow completes successfully.
4. Site URL: https://w9453111-maker.github.io/Ultimate-Stash-of-Stashes/

If you prefer “Deploy from a branch,” choose branch main and folder /(root), and disable the Actions deployment method to avoid configuring two methods at once.

## Supabase starter
The file supabase/schema.sql creates the sites table and safe starter Row Level Security policies. Run it in Supabase SQL Editor. Then build the client integration using the Supabase project URL and publishable/anon key only; never place a service-role key in frontend code.

## Fidelity note
The original repository's source code was not available during this rebuild, so this is a detailed reconstruction of the recorded features and visual direction, not a byte-for-byte copy of the deleted project.
