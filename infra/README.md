# Milestone 6 — One command, one config file

Everything from Milestones 1–5, combined. This is the folder a real
user (including you, for your actual production site eventually)
runs — the `environments/test*` folders stay in the repo as isolated
scratch space for trying changes safely, but this `infra/` root is
the real thing.

## What this creates, in one `terraform apply`
- Static site (S3 + CloudFront + ACM + folder-URL routing)
- GitHub OIDC provider (created or looked up, your choice)
- Two scoped deploy roles — homepage and blog, each provably unable
  to touch the other's content (explicit `Deny` statements, not just
  `--exclude` flags)
- The full contact/comment pipeline (SES + Lambda + API Gateway)
- Two ready-to-use GitHub Actions workflow files, generated with real
  values already filled in
- A pre-filled `hugo.yaml`, including the comment endpoint already
  wired up — nothing to hand-copy between outputs and config

## The ~8 values you actually set

```powershell
cd infra
copy terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
```
Fill in: `domain_name`, `github_org`, `homepage_repo`, `blog_repo`,
`contact_recipient_email`, `contact_sender_email`, `route53_zone_id`
(or leave blank), `create_oidc_provider` (false if you already have
one — true for a fresh AWS account). Everything else has a sensible
default; skip it unless you want to customize branding.

**Also required, as of GitHub's July 2026 OIDC change:**
`github_owner_id`, `homepage_repo_id`, `blog_repo_id` — numeric IDs,
not names. Get them with:
```powershell
gh api users/<your-username> --jq .id
gh api repos/<your-username>/<homepage-repo> --jq .id
gh api repos/<your-username>/<blog-repo> --jq .id
```
Skipping these is the single most common way this setup fails —
role assumption breaks with a generic-looking auth error that gives
no hint the actual cause is a missing numeric ID. See the
[root README's troubleshooting section](../README.md#github-oidc--iam)
for the full explanation if you hit this.

## Apply

```powershell
terraform init
terraform plan
terraform apply
```
Read the `next_steps` output at the end — it's generated dynamically
and tells you exactly what's left, including whether DNS needs a
manual CNAME (Namecheap) or was already handled (Route53).

## The remaining manual steps (same ones flagged throughout every milestone)

1. **DNS validation CNAME** — only if not on Route53. Add it, wait,
   re-apply.
2. **Click the SES verification email** — always required, no way
   around it.
3. **Copy your files into the two repos.** Terraform never pushes
   to GitHub, so none of this happens automatically:
   ```powershell
   # Homepage repo
   copy generated\index.html           <homepage-repo>\index.html
   mkdir <homepage-repo>\.github\workflows -Force
   copy generated\deploy-homepage.yml  <homepage-repo>\.github\workflows\deploy.yml

   # Blog repo — copy the CONTENTS of site\, not the site folder itself
   Copy-Item ..\site\content -Destination <blog-repo> -Recurse
   Copy-Item ..\site\layouts -Destination <blog-repo> -Recurse
   copy generated\hugo.yaml            <blog-repo>\hugo.yaml
   mkdir <blog-repo>\.github\workflows -Force
   copy generated\deploy-blog.yml      <blog-repo>\.github\workflows\deploy.yml
   ```
   `hugo.yaml`, `content\` and `layouts\` must end up at the **root**
   of the blog repo. See the root README's "Copying your files into
   the two repos" section for what goes wrong if they don't.
4. **Push both repos.** Check each one's Actions tab for a green run.

That's it — five AWS services, two GitHub Actions pipelines, and a
working emailing endpoint, from filling in 8 values.

## A note on the homepage repo itself

This toolkit generates the *deploy workflow* for your homepage, but
not the homepage's HTML/CSS content — that's genuinely yours to
design, or you can start from the example in `homepage-example/` in
this repo (a generified version of the site built earlier in this
project) and reskin it.

## Tearing down a real deployment

Unlike the test environments, don't casually `terraform destroy` this
one once it's live — it deletes your actual S3 bucket, CloudFront
distribution, and contact pipeline. If you ever do need to, note that
`create_oidc_provider = true` means this config manages that resource
directly, so destroying will remove it — fine if this is truly your
only pipeline, but coordinate first if you have others depending on
the same provider (unlikely for a personal setup, but worth knowing).

## Done when
A fresh AWS account + a fresh pair of empty GitHub repos + one filled
`terraform.tfvars` produces a fully working personal site, blog, and
emailing contact/comment system — from a single `terraform apply` and
the small set of unavoidable manual clicks listed above, matching
everything built and debugged by hand across this entire project.
