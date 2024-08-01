#!/usr/bin/env bash
set -e

# Base variables
TAG=gwas
# Build container
cd containers/gwas
docker build -t $TAG .

# Push to Docker Hub
REPO=juanfortizq/$TAG
docker tag $TAG $REPO
docker push $REPO

# Push to ECR
REGION=ap-southeast-1
ACCT=010526263385
ECR_REPO=$ACCT.dkr.ecr.$REGION.amazonaws.com/$TAG
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPO
docker tag $TAG $ECR_REPO
docker push $ECR_REPO

