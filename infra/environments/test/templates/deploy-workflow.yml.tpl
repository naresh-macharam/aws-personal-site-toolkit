name: Deploy test site

on:
  push:
    branches: [main, master]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${role_arn}
          aws-region: ${aws_region}

      - name: Sync to S3
        run: |
          aws s3 sync . s3://${bucket_name}/ \
            --exclude ".git/*" \
            --exclude ".github/*" \
            --exclude "*.tf" \
            --delete

      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${distribution_id} \
            --paths "/*"
