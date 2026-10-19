output "cloudfront_domain_name" {
  value = module.site.cloudfront_domain_name
}

output "dns_auto_configured" {
  description = "true if Route53 was used and DNS is already pointed correctly — false means you still need to add a CNAME manually"
  value       = module.site.dns_auto_configured
}

output "acm_validation_records" {
  description = "Only relevant if dns_auto_configured is false — add these at your registrar"
  value       = module.site.acm_validation_records
}

output "bucket_name" {
  value = module.site.bucket_name
}

output "homepage_role_arn" {
  value = module.homepage_role.role_arn
}

output "blog_role_arn" {
  value = module.blog_role.role_arn
}

output "contact_endpoint" {
  description = "Already baked into generated/hugo.yaml — shown here for reference / for your homepage's CONTACT_ENDPOINT"
  value       = module.contact_pipeline.invoke_url
}

output "contact_sender_verification_note" {
  value = module.contact_pipeline.sender_verification_note
}

output "generated_files" {
  description = "Copy these into your actual repos — see README"
  value = {
    homepage_workflow = local_file.homepage_workflow.filename
    blog_workflow      = local_file.blog_workflow.filename
    hugo_config        = local_file.hugo_config.filename
    homepage_html      = local_file.homepage_html.filename
  }
}

output "next_steps" {
  value = <<-EOT

    ────────────────────────────────────────────────────────────
    Setup created. Remaining manual steps (all one-time):

    1. ${module.site.dns_auto_configured ? "DNS already configured via Route53 — nothing to do." : "Add the CNAME shown in `acm_validation_records` at your registrar, wait a few minutes, then re-run `terraform apply`."}

    2. Check the inbox for "${var.contact_sender_email}" and click
       the SES verification link. Nothing will send email until you do.

    3. Copy generated/deploy-homepage.yml into:
       <your homepage repo>/.github/workflows/deploy.yml

    4. Copy generated/deploy-blog.yml into:
       <your blog repo>/.github/workflows/deploy.yml

    5. Copy generated/hugo.yaml into:
       <your blog repo>/hugo.yaml
       Also copy the CONTENTS of ../site/ (the content/ and layouts/
       folders) into the root of your blog repo. Not the site folder
       itself — Hugo needs these at the repo root.

    6. Copy generated/index.html into your homepage repo, then edit it
       for your real content (see the customization comment at the
       top of the file) — the contact endpoint is already wired in,
       no manual editing of that part needed.

    7. Push both repos. Check each repo's Actions tab for a green run.
    ────────────────────────────────────────────────────────────
  EOT
}
