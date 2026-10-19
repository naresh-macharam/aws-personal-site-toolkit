name: Deploy homepage

# This is a thin caller — the actual deploy logic lives in the
# aws-personal-site-toolkit repo's reusable workflow, so fixes and
# improvements there reach every fork automatically on the next run,
# without anyone needing to manually re-copy an updated file.

on:
  push:
    branches: [main, master]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    uses: ${toolkit_repo}/.github/workflows/reusable-deploy-homepage.yml@${toolkit_ref}
    with:
      role_arn: "${role_arn}"
      bucket_name: "${bucket_name}"
      distribution_id: "${distribution_id}"
      aws_region: "${aws_region}"
