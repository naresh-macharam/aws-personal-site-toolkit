import json
import os
import boto3

ses = boto3.client('ses', region_name=os.environ.get('SES_REGION', 'us-east-1'))

RECIPIENT = os.environ['RECIPIENT_EMAIL']
SENDER = os.environ['SENDER_EMAIL']
ALLOWED_ORIGINS = [o.strip() for o in os.environ.get('ALLOWED_ORIGINS', '').split(',') if o.strip()]


def cors_headers(event):
    request_origin = event.get('headers', {}).get('origin', '')
    allow_origin = request_origin if request_origin in ALLOWED_ORIGINS else (ALLOWED_ORIGINS[0] if ALLOWED_ORIGINS else '')
    return {
        'Access-Control-Allow-Origin': allow_origin,
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST,OPTIONS',
        'Content-Type': 'application/json'
    }


def lambda_handler(event, context):
    cors = cors_headers(event)

    if event.get('requestContext', {}).get('http', {}).get('method') == 'OPTIONS':
        return {'statusCode': 200, 'headers': cors, 'body': ''}

    try:
        body = json.loads(event.get('body') or '{}')

        name = (body.get('name') or 'Anonymous').strip()
        sender_email = (body.get('email') or '').strip()
        message = (body.get('message') or body.get('comment') or '').strip()
        source = body.get('source', 'contact form')
        post_title = body.get('post', '')
        post_url = body.get('post_url', '')

        # Honeypot: a hidden field real visitors never see or fill in.
        # Bots that blindly fill every field trip this. Return success
        # so the bot has no signal it was caught, but skip sending mail.
        honeypot = (body.get('website') or '').strip()
        if honeypot:
            return {'statusCode': 200, 'headers': cors, 'body': json.dumps({'success': True})}

        if not message or not sender_email:
            return {
                'statusCode': 400,
                'headers': cors,
                'body': json.dumps({'success': False, 'error': 'Missing required fields'})
            }

        subject = f"New {source} — {name}"
        if post_title:
            subject += f" (on: {post_title})"

        body_text = f"From: {name} <{sender_email}>\nVia: {source}\n\n{message}"
        if post_title:
            body_text += f"\n\nPost: {post_title}\nURL: {post_url}"

        ses.send_email(
            Source=SENDER,
            Destination={'ToAddresses': [RECIPIENT]},
            Message={
                'Subject': {'Data': subject},
                'Body': {'Text': {'Data': body_text}}
            },
            ReplyToAddresses=[sender_email]
        )

        return {'statusCode': 200, 'headers': cors, 'body': json.dumps({'success': True})}

    except Exception as e:
        return {'statusCode': 500, 'headers': cors, 'body': json.dumps({'success': False, 'error': str(e)})}
