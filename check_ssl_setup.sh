#!/bin/bash

echo "=== SSL/HTTPS Setup Checker ==="
echo ""

# Check HTTP response
echo "1. Testing HTTP connection:"
curl -I http://taewojo.site 2>/dev/null || echo "HTTP connection failed"
echo ""

# Check HTTPS response
echo "2. Testing HTTPS connection:"
curl -I https://taewojo.site 2>/dev/null || echo "HTTPS connection failed"
echo ""

# Check SSL certificate
echo "3. Checking SSL certificate:"
echo | openssl s_client -connect taewojo.site:443 -servername taewojo.site 2>/dev/null | openssl x509 -noout -dates -subject 2>/dev/null || echo "SSL certificate check failed"
echo ""

# Check DNS resolution
echo "4. Checking DNS resolution:"
host taewojo.site 2>/dev/null || echo "DNS resolution failed"
echo ""

# Check port 443 connectivity
echo "5. Testing port 443 connectivity:"
nc -zv taewojo.site 443 2>&1 | grep -q "succeeded" && echo "Port 443 is open" || echo "Port 443 is closed or filtered"
echo ""

# Check port 80 connectivity
echo "6. Testing port 80 connectivity:"
nc -zv taewojo.site 80 2>&1 | grep -q "succeeded" && echo "Port 80 is open" || echo "Port 80 is closed or filtered"
echo ""

echo "=== End of SSL/HTTPS Setup Check ==="