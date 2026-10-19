# Contributing

Thanks for looking. This started as one person's personal-site
pipeline, so the bar is "does it make the next person's setup less
painful?"

## Good first contributions
- A troubleshooting entry for a failure you hit (include the exact
  error text, since that's what people search for)
- Domain-level SES verification (removes the manual inbox click for
  Route53 users)
- Support for another DNS provider in the `static-site` module
- A stronger spam layer (rate limiting, CAPTCHA) for `contact-pipeline`

## Before opening a PR
1. Run `terraform fmt -recursive` and `terraform validate` in `infra/`
2. Never commit `*.tfvars`, `*.tfstate`, or anything under `generated/`
3. If you change a `.tpl` file, remember Terraform's template syntax:
   `${...}` and `%{...}` are special. Escape a literal `%{` as `%%{`
4. Test against a throwaway domain (`infra/environments/test`), not a
   live site

## Reporting bugs
Open an issue with: what you ran, the exact error, and whether your
GitHub repo was created before or after July 15, 2026 (that date
changes the OIDC token format and explains many auth failures).
