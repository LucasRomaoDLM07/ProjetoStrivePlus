#!/bin/bash
echo "🧹 Limpando versão antiga..."

if [ -d /home/ec2-user/deploy/myapp ]; then
    sudo rm -rf /home/ec2-user/deploy/myapp
fi
