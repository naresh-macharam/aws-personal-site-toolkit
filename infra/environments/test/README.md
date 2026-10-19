# Milestone 1 — Static Site Infra (S3 + CloudFront + ACM + routing)

This is the foundation module: it creates everything needed to serve a
static site over HTTPS on a custom domain, with correct handling of
folder-style URLs like `/blog/` or `/blog/posts/my-post/`.

## What it creates
- A private S3 bucket (no public access — CloudFront reads it via
  Origin Access Control, not a public bucket policy)
- An ACM certificate for your domain (created in us-east-1, as
  CloudFront requires, regardless of your main region)
- A CloudFront distribution serving that bucket over HTTPS
- A CloudFront Function that appends `index.html` to any request
  ending in `/` or with no file extension

## Prerequisites
- Terraform >= 1.7 installed (`winget install HashiCorp.Terraform` on
  Windows)
- AWS CLI configured locally with credentials that can create these
  resources (`aws configure`) — this is YOU running Terraform from
  your machine for now; GitHub Actions integration comes in a later
  milestone
- A throwaway subdomain you control, e.g. `tftest.yourdomain.com` —
  **do not point this at your real live site's domain**

## Running it

```powershell
cd infra/environments/test
copy terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars   # fill in your test_domain
terraform init
terraform plan
terraform apply
```

## If your DNS is NOT on Route53 (e.g. Namecheap)

This requires two applies, because Terraform can't reach into your
registrar's account to prove you own the domain:

1. Run `terraform apply` once. It will create the ACM certificate and
   then hang or fail waiting for validation — that's expected.
2. Run `terraform output acm_validation_records` — this prints a CNAME
   name/value pair.
3. Add that exact CNAME record in your Namecheap DNS settings.
4. Wait a few minutes for it to propagate, then run `terraform apply`
   again. This time it should complete, since the certificate is now
   validated.

## If your DNS IS on Route53

Set `route53_zone_id` in your `terraform.tfvars` — both certificate
validation AND the final domain -> CloudFront pointer record are
created automatically. `terraform apply` completes in one pass with
zero manual DNS steps.

## Confirming it worked

```powershell
terraform output cloudfront_domain_name
```

If you're on Route53, your domain is already pointed at CloudFront —
skip straight to uploading a test file. Otherwise, point your test
domain's DNS (a CNAME to that `*.cloudfront.net` address) at that
output first.

Upload a test `index.html` to the bucket manually just to check:

```powershell
aws s3 cp index.html s3://<bucket_name_from_output>/index.html
```

Then visit `https://tftest.yourdomain.com` — you should see it load
over HTTPS with a valid certificate. Also test a folder-style path
like `https://tftest.yourdomain.com/some-folder/` after uploading a
matching `some-folder/index.html`, to confirm the routing function
works.

## Tearing it down

Since this is just a test, don't leave it running:
```powershell
terraform destroy
```

---

# Milestone 3 — Wiring it into a real deploy pipeline

This same environment now also creates a deploy role (scoped to only
this bucket and this distribution) and **generates the actual GitHub
Actions workflow file for you**, with real ARNs and names already
filled in — no manual copy-pasting of outputs into YAML.

## Prerequisites
- Milestone 1 and 2 both done
- A second throwaway GitHub repo — this one simulates your homepage
  repo. Create it empty (e.g. `test-site-deploy`), matching whatever
  you set `github_repo` to in your `terraform.tfvars`

## Apply

```powershell
cd infra\environments\test
terraform apply
```
This adds the new role and writes a real workflow file to
`generated\deploy.yml` in this folder — open it and look, you'll see
your actual role ARN, bucket name, and distribution ID already in
place, not placeholders.

## Deploy it

Copy the generated file into your test repo:
```powershell
mkdir ..\..\..\..\test-site-deploy\.github\workflows -Force
copy generated\deploy.yml ..\..\..\..\test-site-deploy\.github\workflows\deploy.yml
```
(Adjust that relative path to wherever you actually cloned
`test-site-deploy` — or just copy the file manually.)

Add a simple test `index.html` to that repo, then:
```powershell
cd ..\..\..\..\test-site-deploy
git add .
git commit -m "Test deploy via Terraform-generated pipeline"
git push
```

## Verify

Check the repo's **Actions** tab — the workflow should run green
through all three steps (credentials, sync, invalidation). Then visit
your test domain and confirm the new `index.html` is live.

## Done when
A push to the throwaway repo deploys correctly using a workflow file
that Terraform generated for you — proving Milestones 1 and 2 combine
into a real, working pipeline with zero hand-typed ARNs anywhere.
Next: Milestone 4 adds the Hugo build step on top of this same
pattern.

---

# Milestone 4 — The Hugo blog layer

The `site/` folder (at the repo root, alongside `infra/`) has your
three generified templates plus an example `hugo.yaml.example` and a
starter post. "Generified" means no hardcoded name, colors, or nav
links — everything comes from `Site.Params`, with sensible defaults
baked in so it still looks reasonable even before you customize
anything.

## Set up the Hugo project

```powershell
cd site
copy hugo.yaml.example hugo.yaml
notepad hugo.yaml
```
Fill in your real domain in `baseURL` and `homeURL`, your name/title,
and your nav links. Leave `commentEndpoint: ""` for now — the comment
form simply won't render until Milestone 5 gives it something real to
point at.

Test it locally:
```powershell
hugo server -D
```

## Generate the blog deploy workflow

Back in `infra/environments/test`, apply again — this creates a
second scoped role (`blog_deploy_role`, permitted only on the `blog/*`
prefix, completely separate from the homepage role) and generates
`generated/deploy-blog.yml` with the Hugo build step included:

```powershell
cd ..\..\infra\environments\test
terraform apply
```

## Deploy it

Create a second throwaway repo (matching `blog_github_repo` in your
tfvars), copy your `site/` folder's contents into it, and copy the
generated workflow in:
```powershell
copy generated\deploy-blog.yml <path-to-blog-repo>\.github\workflows\deploy.yml
```
Commit and push. Check Actions — this one has an extra step (Hugo
build) compared to the homepage workflow, but otherwise follows the
identical credentials → sync → invalidate pattern.

## Verify

Visit `https://<your-test-domain>/blog/` — you should see the
"Hello, world" starter post, styled with your `hugo.yaml` colors, and
the same header/footer pattern as your real blog.

## Done when
A fresh clone of `site/`, with only `hugo.yaml` filled in (no code
edits), deploys a working, correctly-styled blog to your test domain
via a Terraform-generated pipeline — with the homepage and blog roles
proven to be genuinely separate (each can only touch its own S3
prefix). Next: Milestone 5 adds the SES-backed contact/comment
pipeline, and wires `commentEndpoint` up for real.

---

# Milestone 5 — Contact pipeline (SES + Lambda + API Gateway)

This module is entirely self-contained — it bundles the Lambda source
itself (`infra/modules/contact-pipeline/files/lambda_function.py`),
so applying it creates a fully working emailing endpoint with no
manual Lambda console work at all, except one unavoidable click.

## What's automated vs. not
- **Automated:** Lambda function + code deploy, IAM role and scoped
  SES permission, API Gateway HTTP API with CORS, the route, the
  Lambda invoke permission — all of it.
- **Not automated (can't be):** SES sends you a verification email
  the moment `terraform apply` runs. You still have to open that
  inbox and click the link, same as when we did this by hand. This
  is a genuine AWS security requirement, not a gap in the module —
  domain-level SES verification (a future milestone) would remove
  even this step, at the cost of needing Route53-managed DNS.

## Apply

Add your two new variables to `terraform.tfvars` (see the updated
`terraform.tfvars.example`), then:
```powershell
cd infra\environments\test
terraform apply
```

Immediately after, check the inbox for whatever you set as
`contact_sender_email` and click the AWS verification link — nothing
will send successfully until you do.

## Get the endpoint

```powershell
terraform output contact_endpoint
```

## Wire it up

**Blog comments:** put this value in `site\hugo.yaml`:
```yaml
params:
  commentEndpoint: "https://abc123.execute-api.eu-west-2.amazonaws.com/contact"
```
Rebuild and redeploy the blog (Milestone 4's pipeline) — the comment
form will now actually appear on posts, since the template only
renders it when `commentEndpoint` is set.

**Homepage contact form:** if you're testing against your actual
homepage code, replace the `CONTACT_ENDPOINT` placeholder in its
script with this same URL.

## Verify

```powershell
$body = @{
    name    = "Test"
    email   = "you@example.com"
    message = "Testing the Terraform-generated pipeline"
    source  = "manual test"
} | ConvertTo-Json

Invoke-RestMethod -Uri (terraform output -raw contact_endpoint) -Method POST -ContentType "application/json" -Body $body
```
Then check your inbox. Once that works, submit a real comment through
the deployed blog post and confirm CORS behaves correctly from an
actual browser too.

## Done when
`terraform apply` + one verification-email click produces a working
emailing endpoint, and both the blog's comment form and (if wired up)
the homepage's contact form successfully deliver mail through it —
with zero manually-created AWS resources anywhere in the whole
pipeline at this point.




## Done when
`terraform apply` from a clean checkout produces a working HTTPS
static site on your test domain, with folder-style URLs resolving
correctly — matching what you already have live by hand. Once this
is solid, we move to Milestone 2 (GitHub OIDC + IAM).
