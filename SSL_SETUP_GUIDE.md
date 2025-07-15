# SSL/HTTPS Setup Guide for Django on AWS Elastic Beanstalk

## Current Problem Analysis

Your Django application is having issues with both HTTP and HTTPS because:

1. **HTTP** - Works but redirects to HTTPS (301 redirect)
2. **HTTPS** - Fails to connect on port 443 (SSL certificate not configured)

## Root Causes

1. **Missing SSL Certificate**: No SSL certificate configured for your domain
2. **Nginx Configuration**: Only configured for HTTP (port 80), not HTTPS (port 443)
3. **Missing Django SSL Settings**: No HTTPS security configurations in Django settings

## Solution: Use AWS Application Load Balancer (ALB) with SSL Certificate

### Step 1: Request SSL Certificate via AWS Certificate Manager

1. Go to AWS Certificate Manager (ACM) in your AWS console
2. Click "Request a certificate"
3. Choose "Request a public certificate"
4. Add domain names:
   - `taewojo.site`
   - `www.taewojo.site`
5. Choose DNS validation
6. Complete the validation process by adding the CNAME records to your DNS provider

### Step 2: Configure Your Elastic Beanstalk Environment

1. **Update the `https-redirect.config` file** (already created):
   - Replace `YOUR_ACCOUNT_ID` with your AWS account ID
   - Replace `YOUR_CERTIFICATE_ID` with the certificate ID from Step 1

2. **Deploy your updated application** with the new configurations

### Step 3: Update Your Elastic Beanstalk Environment

1. Go to your Elastic Beanstalk environment in AWS console
2. Click "Configuration" → "Load balancer"
3. Add listeners:
   - **HTTP (port 80)**: Redirect to HTTPS
   - **HTTPS (port 443)**: Use your SSL certificate
4. Update the security groups to allow traffic on port 443

### Step 4: Update DNS Settings

Make sure your domain's DNS records point to your Elastic Beanstalk environment:
- A record for `taewojo.site` → Your EB environment URL
- CNAME record for `www.taewojo.site` → Your EB environment URL

### Step 5: Test Your Setup

After deployment, test:
```bash
curl -I http://taewojo.site    # Should redirect to HTTPS
curl -I https://taewojo.site   # Should return 200 OK
```

## Alternative Solution: Manual SSL Certificate Installation

If you prefer to handle SSL directly in your nginx configuration:

1. Obtain SSL certificates (Let's Encrypt, purchased certificate, etc.)
2. Update nginx.conf to listen on port 443 with SSL configuration
3. Update Docker container to expose port 443
4. Update security groups to allow port 443

## Django Settings Changes Made

The following security settings were added to your Django settings:

- `SECURE_PROXY_SSL_HEADER`: Recognizes HTTPS from load balancer
- `SECURE_SSL_REDIRECT`: Redirects HTTP to HTTPS
- `SESSION_COOKIE_SECURE`: Only sends session cookies over HTTPS
- `CSRF_COOKIE_SECURE`: Only sends CSRF cookies over HTTPS
- Additional security headers for XSS protection

## Important Notes

1. **Production Settings**: Consider setting `DEBUG = False` in production
2. **Security Groups**: Ensure port 443 is open in your EC2 security groups
3. **DNS Propagation**: DNS changes may take up to 48 hours to propagate
4. **Certificate Validation**: SSL certificate validation may take several minutes

## Troubleshooting

- **503 Service Unavailable**: Check if your application is running correctly
- **SSL Certificate Errors**: Verify the certificate is valid and covers your domain
- **Connection Timeouts**: Check security groups and load balancer configuration
- **Redirect Loops**: Ensure `SECURE_PROXY_SSL_HEADER` is correctly configured

The main issue is that you need to set up SSL termination either through AWS Application Load Balancer (recommended) or directly in your nginx configuration. The ALB approach is easier to manage and more scalable.