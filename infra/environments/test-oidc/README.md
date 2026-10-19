# Milestone 2 — GitHub OIDC + IAM Role

Two modules here:

- **`github-oidc-provider`** — the trust anchor between AWS and GitHub.
  One per AWS account, ever. Controlled by a `create_provider` boolean:
  `false` (what you'll use) means it looks up your existing one via a
  data source instead of trying to create a duplicate.
- **`github-actions-role`** — a reusable module you instantiate once
  per repo/pipeline, each with its own name, trust condition, and
  attached permissions. This is the module you'll reuse in every
  later milestone (homepage deploy, blog deploy, contact Lambda).

## ⚠️ If you already applied this environment before the toggle was added

You imported your OIDC provider into Terraform state earlier, at the
address `module.oidc_provider.aws_iam_openid_connect_provider.github`.
This module now sets `create_provider = false`, which means it no
longer expects to manage that resource directly at all — it reads it
via a data source instead. Before running `plan` or `apply` again,
remove the old address from state (this only affects Terraform's
bookkeeping — it does NOT call any AWS delete API, your real provider
is untouched):

```powershell
terraform state rm 'module.oidc_provider.aws_iam_openid_connect_provider.github'
```

Then run `terraform plan` — it should show no changes (or only the
new `test_role`-related resources if this is your first time reaching
this point), confirming the data source found your existing provider
correctly.

## Prerequisites
- Milestone 1 done and understood
- A throwaway GitHub repo to test against (just needs to exist —
  empty is fine)

## Step 1 — Set your variables

```powershell
cd infra/environments/test-oidc
```
Create `terraform.tfvars`:
```hcl
github_org = "naresh852"
test_repo  = "oidc-test"
```

## Step 2 — Confirm the toggle is set correctly

With `create_provider = false` (already set in this environment's
`main.tf`), the module doesn't try to create anything — it just reads
your existing provider via a data source. No `terraform import`
needed for a fresh setup; the data source finds it live via the AWS
API as long as it genuinely exists at that URL in your account.

```powershell
terraform init
terraform plan
```
This should show it successfully reading your existing provider and
planning to create only the new `test_role` — nothing provider-related.

If instead you get an error that no provider was found, either your
provider doesn't exist yet (flip `create_provider = true` for this one
apply to create it), or you're pointed at the wrong AWS account/region
— double check your AWS CLI's active credentials.
trivial diff like a tag) — if it wants to change the thumbprint or
audience significantly, stop and check before applying; that would
mean your existing provider differs from what this module expects.

## Step 3 — Apply

```powershell
terraform apply
```
This creates the new `github-actions-oidc-test` role, trusted only
for `repo:<your-username>/oidc-test:*`.

Copy the printed `role_arn` output.

## Step 4 — Wire up the test repo

In your empty `oidc-test` GitHub repo:
```powershell
mkdir .github\workflows
copy test-workflow.yml .github\workflows\test.yml
```
Open `test.yml` and replace `<ACCOUNT_ID>` in the `role-to-assume`
line with your real AWS account ID (or paste the full ARN from the
Terraform output directly).

```powershell
git add .
git commit -m "Test OIDC role assumption"
git push
```

## Step 5 — Verify

Check the **Actions** tab on `oidc-test`. If the "Prove it worked"
step succeeds and prints your account ID and the assumed role's ARN,
the whole OIDC chain — provider, trust policy, permissions — is
working, driven entirely by Terraform with no console clicking for
the role itself.

If it fails at "Configure AWS credentials" with the same
`AssumeRoleWithWebIdentity` error from before: check CloudTrail
(Event history, filter `AssumeRoleWithWebIdentity`) for the exact
`sub` GitHub actually sent, same debugging approach as last time —
though using `allowed_ref = "*"` (this module's default) should avoid
that class of mismatch entirely, since it doesn't try to match a
specific branch pattern.

## Tearing it down

```powershell
terraform destroy
```
This removes the test role but does NOT remove the OIDC provider
(since it was imported, not created, `destroy` will still try to
delete it — be careful here). If you want to keep the provider and
only remove the test role, target it specifically:
```powershell
terraform destroy -target=module.test_role
```

## Done when
A push to a throwaway repo, with zero AWS console clicking, results
in a successful `aws sts get-caller-identity` call in GitHub Actions
— proving the OIDC provider + role + trust policy chain is fully
Terraform-managed and repeatable for any repo you point it at next.
