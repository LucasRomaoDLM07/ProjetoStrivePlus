#!/bin/bash
echo "📦 Ajustando permissões..."

sudo mkdir -p /home/ec2-user/deploy/myapp
sudo chmod -R 755 /home/ec2-user/deploy/myapp
