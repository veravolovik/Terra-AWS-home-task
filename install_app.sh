#!/bin/bash
yum install docker-ce -y
docker run -d -p 80:80 webdevops/php-nginx:latest