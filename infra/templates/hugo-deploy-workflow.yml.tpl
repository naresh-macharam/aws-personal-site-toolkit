name: Deploy blog

# Thin caller — see deploy-homepage.yml's comment for why.

on:
  push:
    branches: [main, master]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    uses: ${toolkit_repo}/.github/workflows/reusable-deploy-blog.yml@${toolkit_ref}
    with:
      role_arn: "${role_arn}"
      bucket_name: "${bucket_name}"
      distribution_id: "${distribution_id}"
      aws_region: "${aws_region}"
