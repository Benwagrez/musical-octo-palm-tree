#!/bin/bash

# Installing Python dependencies into packages and zipping the deployment
pip install --target ./packages -r requirements.txt --no-user
7z a -tzip ./lambda_function_payload.zip ./packages/*
7z a ./lambda_function_payload.zip ./python/*

# Running terraform apply
terraform apply -var-file="terraform.tfvars"

# Cleaning up working directory
rm lambda_function_payload.zip