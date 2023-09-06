#!/bin/bash

pip install --target ./packages -r requirements.txt --no-user
7z a -tzip ./deployment.zip ./packages/*
7z a ./deployment.zip ./python/*
