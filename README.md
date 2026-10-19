# aws-personal-site-toolkit

A fork-and-deploy Terraform template for a personal brand website: a
static homepage, a Hugo blog, and a serverless contact/comment
pipeline that emails you — all on AWS, deployed via GitHub Actions,
with OIDC (no long-lived AWS keys anywhere).

Fill in about 8 values, run `terraform apply`, click one unavoidable
verification email, and you have a working site.

## Use this template

Click **Use this template** at the top of the GitHub page to create
your own copy, then follow the quickstart below. Keep your copy
**public** if you want the generated deploy workflows to call its
reusable workflows (see "Reusable workflows" further down).

## What you get

- **Homepage** — a single static HTML file, your design
- **Blog** — Hugo, with your posts in plain markdown
- **Both deploy automatically** on `git push`, via GitHub Actions
  roles that are provably scoped — the homepage pipeline cannot touch
  blog content and vice versa, enforced by explicit IAM `Deny`
  statements, not just careful scripting
- **A working contact form and blog comment form** — SES + Lambda +
  API Gateway, emails land in your inbox, no third-party form service
- **Basic spam protection** — an invisible honeypot field on both
  forms; bots that blindly fill every field trip it, real visitors
  never see it (hidden from screen readers too, so it doesn't trap
  assistive-tech users)
- **Reusable GitHub Actions workflows** — your generated pipelines are
  thin callers referencing this repo's own workflows via `uses:`, so
  a fix pushed here reaches every deployment automatically
- **No manually-clicked AWS console setup** — S3, CloudFront, ACM,
  the OIDC trust relationship, IAM roles, Lambda, API Gateway: all
  Terraform

## What still requires a manual step, and why

Terraform can't do everything — a few things are inherent to how AWS
and DNS work, not gaps in this toolkit:

- **Buying your domain** — has to be a human with a credit card
- **DNS validation CNAME**, if your registrar isn't Route53 —
  Terraform can't reach into an external registrar's account
- **Clicking the SES verification email** — proving you own an
  inbox can't be automated by the thing trying to prove it
- **Creating your two GitHub repos** — one click each ("use this
  template" or a blank repo)
- **Copying your content into those two repos** — Terraform writes
  files on your own machine, it never pushes to GitHub. See
  "Copying your files into the two repos" below.

Everything else — every piece of AWS infrastructure — is `terraform
apply`.

### Copying your files into the two repos

This is a manual step, and easy to get wrong. After `terraform apply`,
nothing has been placed in your homepage or blog repo yet. You copy
the files in yourself, then `git push`:

| What | Copy from | Copy into |
|---|---|---|
| Homepage page | `infra/generated/index.html` | root of your **homepage** repo |
| Homepage deploy workflow | `infra/generated/deploy-homepage.yml` | homepage repo, `.github/workflows/deploy.yml` |
| Blog source | the **contents** of `site/` (`content/`, `layouts/`) | root of your **blog** repo |
| Blog config | `infra/generated/hugo.yaml` | blog repo root, as `hugo.yaml` |
| Blog deploy workflow | `infra/generated/deploy-blog.yml` | blog repo, `.github/workflows/deploy.yml` |

Things that go wrong here:

- **Copy the contents of `site/`, not the `site` folder itself.**
  Hugo only looks for `hugo.yaml`, `content/` and `layouts/` at the
  repo root. If they end up inside a `site/` subfolder, the build fails
  with `Unable to locate config file`.
- **Use `generated/index.html`, not `homepage-example/index.html.tpl`.**
  The `.tpl` file is a Terraform template with placeholders. The
  generated one has your contact endpoint and colors filled in.
- **Don't skip `content/` and `layouts/`.** They are your source
  material, not build output. Hugo builds your site from them and
  can't regenerate them if they're missing.
- **Use `generated/hugo.yaml`, not `site/hugo.yaml.example`.** The
  generated one already has your real domain and comment endpoint.
- **Re-copy after changing `terraform.tfvars`.** If you change a
  color, title or endpoint and re-run `terraform apply`, the files in
  `generated/` update but your repos don't. Copy them over again.

## Quickstart

See [`infra/README.md`](infra/README.md) for the full walkthrough.
Short version:

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
# fill in domain_name, github_org, homepage_repo, blog_repo,
# contact_recipient_email, contact_sender_email, route53_zone_id
terraform init
terraform apply
```

Read the `next_steps` output — it tells you exactly what's left,
including whether your DNS needs a manual step or was handled
automatically (Route53).

## Repo structure

```
infra/
├── main.tf, variables.tf, outputs.tf   ← the real, consolidated setup
├── modules/
│   ├── static-site/        S3 + CloudFront + ACM + URL routing
│   ├── github-oidc-provider/  create OR look up, your choice
│   ├── github-actions-role/   reusable, one instance per pipeline
│   └── contact-pipeline/      SES + Lambda + API Gateway
├── templates/               workflow + config files Terraform fills in
├── generated/                ← where your ready-to-use output lands
└── environments/            isolated scratch space for trying changes
    ├── test/, test-oidc/     (safe to break — not the real deployment)

site/                        Hugo blog template (generic — no hardcoded branding)
homepage-example/            Homepage template (also generic)
```

## Architecture

`terraform.tfvars` feeds four modules. The static-site module builds
your S3/CloudFront/ACM infrastructure; the OIDC and role modules set
up scoped, keyless GitHub Actions access; the contact-pipeline module
builds the emailing backend. Terraform then generates your actual
deploy workflow files and site config from those modules' outputs —
you copy the generated files into your two repos and push.

## Troubleshooting

This section exists because every one of these was hit and solved
while building this toolkit — not hypothetical failure modes.

### Windows / local environment

**Hugo fails with `Access is denied` on `public/`, or Git/Terraform
behave strangely** — your project is inside a cloud-synced folder
(OneDrive, Google Drive for Desktop, Dropbox). These actively lock
files mid-write, which breaks build tools and can corrupt Terraform
state. Move the project to a plain local path (`C:\Users\you\...` or
`C:\dev\...`), outside any synced folder. Use `git push` as your
actual backup, not a cloud-drive client.

**`curl` fails with a `Cannot bind parameter 'Headers'` error in
PowerShell** — PowerShell aliases `curl` to `Invoke-WebRequest`, which
takes different flags. Either call `curl.exe` explicitly (bypasses the
alias), or use native `Invoke-RestMethod` syntax instead.

**A command from a guide doesn't run / gives a parser error** — check
whether it was meant to be typed as a command, or is file *content*
meant to be pasted into an editor. These look similar in a code block
but are very different things.

### Hugo

**`ERROR Unable to locate config file`** — you're running `hugo` from
the wrong directory, or `hugo.yaml` isn't actually at the repo root
(check for a stray extra folder level from an unzip or copy).

**Deleting `content/` and `layouts/` and expecting Hugo/CI to
regenerate them** — it won't. These are your source material, not
build output. `hugo` builds `public/` *from* `content/` + `layouts/`
— if those are gone, there's nothing to build from. For any new
clone, copying these from `site/` into your actual blog repo is a
required one-time step, not something the pipeline does for you.

**A code fix "still doesn't work" after multiple attempts** — before
assuming the fix is wrong, verify the whole chain: is the source file
actually saved correctly (`Get-Content`, read it back)? Does a *fresh*
local build (`Remove-Item -Recurse -Force public; hugo`) reflect it?
Was it actually committed (`git status`) and pushed? Did the GitHub
Action actually run since then? Only then suspect the code itself —
and check for a duplicate/stray template file shadowing the one you
think you're editing (`Get-ChildItem -Recurse -Filter "single.html"`).

### CloudFront / S3

**Clicking a link (a blog post, "All posts") downloads a file or
shows AccessDenied XML instead of rendering the page** — CloudFront,
when pointed at S3 as a REST origin (the secure, recommended setup),
does not automatically serve `index.html` for folder-style URLs the
way S3's own website-hosting endpoint does. This toolkit's
`append-index-html` CloudFront Function (baked into the `static-site`
module) fixes this for every path, not just the homepage. If you're
still hitting it, confirm the function is **Published** (not just
Development) and actually **associated** with the right
behavior — creating it and attaching it are two separate steps.

**A fix seems to not be live** — test in an Incognito window first
(rules out local browser cache) and confirm the CloudFront
invalidation actually ran (`aws cloudfront create-invalidation
--distribution-id <id> --paths "/*"`). Both browser and CDN caching
can make an already-fixed problem look unfixed.

### CORS

**`blocked by CORS policy` on a contact form or comment submission**
— the origin your site is actually served from isn't in the allowed
list. Read the *exact* origin from the browser's error message, and
compare it against what's configured — commonly a `www` vs. non-`www`
mismatch, since those count as two different origins to a browser. In
this toolkit, both the API Gateway CORS config and the Lambda's
`ALLOWED_ORIGINS` are driven from the same Terraform list
(`local.origins`), so they can't drift out of sync the way they can
with hand-managed setups.

**A `403 Forbidden` that looks CORS-shaped but isn't** — read the
exact failing URL, not just the status code. A stray literal quote
character embedded in a JS variable can turn a fetch URL into a
broken relative path that 403s for a completely different reason than
CORS. Check the actual request URL in DevTools' Network tab.

### GitHub Actions: calling the reusable workflows

**`failed to fetch workflow: reference to workflow should be either a
valid branch, tag, or commit`** — the `@main` at the end of the
`uses:` line in your generated `deploy-*.yml` names a branch that
doesn't exist in your toolkit repo. Many repos default to `master`.
Check with `gh api repos/<you>/<toolkit-repo> --jq .default_branch`,
then either set `toolkit_ref` in `terraform.tfvars` to that name and
re-run `terraform apply`, or rename the toolkit repo's default branch
to `main`. Also confirm the two `reusable-deploy-*.yml` files sit in
`.github/workflows/` at the toolkit repo **root**, and that the repo
is public.

### GitHub OIDC / IAM

**`Not authorized to perform sts:AssumeRoleWithWebIdentity`, and your
org/repo names in the trust policy are definitely correct** — check
this first: GitHub changed the OIDC token format on July 15, 2026
("immutable subject claims"). Repos created on or after that date
send a `sub` claim like `repo:org@123456/repo@789012:ref:...` —
with numeric owner and repo IDs embedded — instead of the older
`repo:org/repo:ref:...`. A trust policy built for the old format
will never match a token in the new format, and there's no error
message that tells you this directly; it just looks like a generic
auth failure. This toolkit's `github-actions-role` module auto-builds
the correct format once you supply `github_owner_id` and the
per-repo `*_repo_id` values in `terraform.tfvars` — get them with
`gh api users/<you> --jq .id` and `gh api repos/<you>/<repo> --jq .id`.
If you're still unsure which format your repo uses, check the actual
value AWS received via CloudTrail (Event history, filter
`AssumeRoleWithWebIdentity`, look at the `sub` in the failed event) —
don't guess.

**Same error, but you've confirmed the ID format is right** — in
order of likelihood: (1) missing `permissions: id-token: write` in
the workflow file, (2) a stale/wrong Role ARN in the workflow file,
(3) the `ref` portion of the trust condition doesn't match how the
workflow was actually triggered (a branch push vs. a PR vs. a
different branch name than expected).

**`terraform apply` fails with "already exists" on the OIDC
provider** — you already have one in this AWS account (there can only
be one per account). Use `create_provider = false` on the
`github-oidc-provider` module to look it up instead of creating a
duplicate.

**Upgrading a module changes a resource's state address** — if you
add `count` to a resource that Terraform already manages without it,
the address changes shape (e.g. `resource.name` →
`resource.name[0]`), which Terraform reads as "destroy the old one,
create a new one." For anything already applied against shared/live
infrastructure (like an OIDC provider other pipelines depend on), fix
the address with `terraform state rm` or `terraform state mv` first —
check what `plan` proposes before ever applying after a module
version bump.

### Terraform `templatefile()`

**`Invalid character; The ";" character is not valid`** when
generating a file containing CSS — Terraform's template syntax uses
`${...}` and `%{...}`, and CSS `@keyframes` percentages
(`100%{ opacity: 1; }`) look exactly like Terraform's own `%{...}`
directive syntax. Escape the percent sign immediately before a brace
as `%%{`. Only escape ones directly followed by `{` — doubling a bare
`%` elsewhere will incorrectly output two percent signs.

**A templated value renders with extra literal quote marks** — if
`{{ x | jsonify }}` (Hugo) or a Terraform-interpolated string ends up
double-quoted in the rendered output, check for a stray second config
file or a leftover pre-templating version of the value before
assuming the templating function is broken. A more robust fix that
sidesteps this entire class of bug: inject the value via an HTML
`data-*` attribute and read it with `dataset` in JS, rather than
interpolating it directly into a `<script>` block — this toolkit uses
that pattern for both the contact form and blog comment endpoint.

## Reusable workflows — and the one constraint that comes with them

Your generated `deploy-homepage.yml` and `deploy-blog.yml` don't
contain the actual sync/invalidate steps — they `uses:` this repo's
own `.github/workflows/reusable-deploy-*.yml` files and just pass in
your role ARN, bucket, and distribution ID. This means fixing a bug
in the deploy logic here (in your fork) updates every pipeline that
calls it, the next time it runs — no re-copying files into two repos
every time something changes.

**The constraint:** GitHub only allows a reusable workflow to be
called from a *different* repository (as yours will be, since your
homepage/blog repos aren't this toolkit repo) when the repo hosting
it is **public**, unless both repos are in the same organization with
the right settings. If you keep your fork of this toolkit private,
your generated workflows will fail to find the reusable workflow at
all. Either keep the toolkit fork public (nothing in it is sensitive
— your actual secrets are AWS role ARNs resolved at runtime via
OIDC, never stored in this repo), or copy the two
`reusable-deploy-*.yml` files directly into each of your repos
instead and point `uses:` at `./.github/workflows/...` locally —
trading the "fix once, apply everywhere" benefit for keeping
everything private.

## License

MIT — see [`LICENSE`](LICENSE).
