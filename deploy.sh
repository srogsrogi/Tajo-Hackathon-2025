#!/bin/bash

# Django Deployment Script for taewojo.site

echo "🚀 Starting deployment process for taewojo.site..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ .env file not found! Please create one based on .env.example${NC}"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running! Please start Docker first.${NC}"
    exit 1
fi

# Collect static files
echo -e "${YELLOW}📦 Collecting static files...${NC}"
python manage.py collectstatic --noinput

# Build Docker image
echo -e "${YELLOW}🔨 Building Docker image...${NC}"
docker build -t yejin99/tajo-web:latest .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker image built successfully!${NC}"
else
    echo -e "${RED}❌ Docker build failed!${NC}"
    exit 1
fi

# Push to Docker Hub
echo -e "${YELLOW}📤 Pushing to Docker Hub...${NC}"
docker push yejin99/tajo-web:latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker image pushed successfully!${NC}"
else
    echo -e "${RED}❌ Docker push failed!${NC}"
    exit 1
fi

# Deploy to Elastic Beanstalk
echo -e "${YELLOW}🚀 Deploying to Elastic Beanstalk...${NC}"
eb deploy

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
    echo -e "${GREEN}🌐 Your site should be available at: https://taewojo.site${NC}"
else
    echo -e "${RED}❌ Deployment failed!${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Deployment process completed!${NC}"