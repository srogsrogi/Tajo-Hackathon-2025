# Connecting Django Web Server to taewojo.site Domain

## Current Setup Analysis

Your Django project is already configured with:
- ✅ Domain added to `ALLOWED_HOSTS` in settings.py
- ✅ AWS Elastic Beanstalk deployment configured
- ✅ Docker containerization with Gunicorn
- ✅ MySQL database setup

## Step-by-Step Domain Connection Guide

### 1. DNS Configuration

First, you need to point your domain to your AWS Elastic Beanstalk environment:

1. **Get your EB environment URL:**
   - Go to AWS Elastic Beanstalk Console
   - Find your environment URL: `eb-taewojo-env.eba-scw6jbim.ap-northeast-2.elasticbeanstalk.com`

2. **Configure DNS records** (at your domain registrar):
   ```
   Type: CNAME
   Name: www
   Value: eb-taewojo-env.eba-scw6jbim.ap-northeast-2.elasticbeanstalk.com
   
   Type: CNAME  
   Name: @
   Value: eb-taewojo-env.eba-scw6jbim.ap-northeast-2.elasticbeanstalk.com
   ```

### 2. SSL Certificate Setup

**Option A: Using AWS Certificate Manager (Recommended)**
1. Go to AWS Certificate Manager
2. Request a public certificate for:
   - `taewojo.site`
   - `www.taewojo.site`
3. Add certificate to your Load Balancer in EB environment

**Option B: Using Let's Encrypt (Alternative)**
- Configure SSL certificate in your application

### 3. Update Django Settings

Your current settings are mostly correct, but let's optimize them for production:

```python
# Update in tajo/settings.py
DEBUG = False  # Set to False in production
ALLOWED_HOSTS = [
    "127.0.0.1",
    "54.180.178.147",
    "eb-taewojo-env.eba-scw6jbim.ap-northeast-2.elasticbeanstalk.com",
    "www.taewojo.site",
    "taewojo.site"
]

# Add security settings for production
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
```

### 4. Environment Variables Setup

Create a `.env` file (if not exists) with production values:

```bash
# Database Configuration
DB_NAME=your_production_db_name
DB_USER=your_production_db_user
DB_PASSWORD=your_production_db_password
DB_HOST=your_production_db_host

# Django Configuration
SECRET_KEY=your_secret_key_here
DEBUG=False
```

### 5. Deploy Updated Configuration

1. **Update your Docker image:**
   ```bash
   docker build -t yejin99/tajo-web:latest .
   docker push yejin99/tajo-web:latest
   ```

2. **Deploy to Elastic Beanstalk:**
   ```bash
   eb deploy
   ```

### 6. Configure Load Balancer (in AWS EB)

1. Go to EB Console → Configuration → Load Balancer
2. Add HTTPS listener on port 443
3. Attach your SSL certificate
4. Configure HTTP to HTTPS redirect

### 7. Test Your Setup

1. **Check DNS propagation:**
   ```bash
   nslookup taewojo.site
   dig taewojo.site
   ```

2. **Test domain access:**
   - http://taewojo.site (should redirect to https)
   - https://taewojo.site (should work)
   - https://www.taewojo.site (should work)

## Common Issues and Solutions

### Issue 1: "Bad Request (400)"
- **Cause:** Domain not in ALLOWED_HOSTS
- **Solution:** Already configured in your settings

### Issue 2: SSL Certificate Issues
- **Cause:** Certificate not properly attached to load balancer
- **Solution:** Check AWS Certificate Manager and Load Balancer configuration

### Issue 3: DNS Not Resolving
- **Cause:** DNS records not properly configured
- **Solution:** Wait for DNS propagation (can take up to 48 hours)

## Production Checklist

- [ ] DNS records configured
- [ ] SSL certificate obtained and attached
- [ ] DEBUG = False in production
- [ ] Environment variables properly set
- [ ] Load balancer configured for HTTPS
- [ ] Security headers enabled
- [ ] Database configured for production

## Monitoring and Maintenance

1. **Set up monitoring:**
   - CloudWatch for AWS resources
   - Application logs monitoring

2. **Regular maintenance:**
   - SSL certificate renewal
   - Database backups
   - Security updates

## Next Steps

1. Configure DNS records at your domain registrar
2. Set up SSL certificate in AWS Certificate Manager
3. Update production settings
4. Deploy the updated configuration
5. Test the domain connection

Your Django application is well-configured and ready for production deployment with your domain!