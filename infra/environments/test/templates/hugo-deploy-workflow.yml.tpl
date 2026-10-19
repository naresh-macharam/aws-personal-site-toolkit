name: Deploy blog

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
        with:
          submodules: recursive

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: 'latest'
          extended: true

      - name: Build
        run: hugo --minify

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${role_arn}
          aws-region: ${aws_region}

      - name: Sync to S3 (blog/ prefix only)
        run: |
          aws s3 sync public/ s3://${bucket_name}/blog/ --delete

      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${distribution_id} \
            --paths "/blog/*"
