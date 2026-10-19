---
title: "I automated my own blog's infrastructure, then packaged it so you can too"
date: 2026-10-17
draft: false
---

My personal site ran on S3 and CloudFront for a while. It worked, but it was held together by console clicks I could no longer remember. When I decided to add a blog and a contact form, I took the opportunity to rebuild all of it as code, then turned the result into a template anyone can fork.

**The repo:** [aws-personal-site-toolkit](https://github.com/naresh852/aws-personal-site-toolkit)

## What it does

You fill in about ten values in a `terraform.tfvars` file and run `terraform apply`. You get:

- A static homepage and a Hugo blog on S3 + CloudFront, with HTTPS
- Two GitHub Actions deploy roles, one for the homepage and one for the blog. Each is blocked from touching the other's files by an explicit IAM `Deny`, not just by careful scripting
- A contact form and blog comment form that email you, built on API Gateway, Lambda and SES, with no third-party form service
- No long-lived AWS keys anywhere. GitHub authenticates to AWS with OIDC

Terraform also generates the workflow files and the Hugo config with your real ARNs and endpoint already filled in, so there's nothing to copy-paste between outputs and config. That mattered more than I expected, because every value I pasted by hand turned out to be a place for a bug.

## The parts that bit me

I'd rather tell you where it hurts than pretend it was smooth. Each of these is now in the repo's troubleshooting section.

**CloudFront can't serve `/blog/` by itself.** With S3 as a private REST origin, CloudFront doesn't map a folder URL to its `index.html`. Clicking "All posts" returned an access-denied error. A small CloudFront Function that appends `index.html` fixes it, and the toolkit's `static-site` module includes it.

**CORS failed because of `www`.** `example.com` and `www.example.com` are different origins to a browser. The allowed-origins list now lives in one Terraform variable that feeds both API Gateway and the Lambda, so they can't drift apart.

**GitHub changed its OIDC token format.** For repos created after July 15, 2026, the `sub` claim embeds numeric owner and repo IDs. A trust policy written with plain names never matches, and the error is a generic `AssumeRoleWithWebIdentity` failure that gives no hint why. I lost a lot of time to this. The role module now builds the right format when you supply the IDs.

**Terraform's template syntax collides with CSS.** `100%{` in a `@keyframes` rule looks like Terraform's own `%{` directive. The fix is to write `%%{`.

**Cloud-synced folders break build tools.** OneDrive and Google Drive lock files mid-write. Keep projects on a plain local path.

## What still needs a human

Buying the domain, clicking the SES verification email, adding a DNS validation record if you're not on Route53, and creating the two GitHub repos. Everything else is `terraform apply`.

## Try it

Use the repo as a template, read `infra/README.md`, and start with a throwaway subdomain. If something breaks, open an issue with the exact error text. That's how the troubleshooting section grew in the first place.
