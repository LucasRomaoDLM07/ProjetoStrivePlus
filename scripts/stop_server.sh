#!/bin/bash
echo "🛑 Parando aplicação..."
if [ -f /home/ec2-user/app.pid ]; then
    kill $(cat /home/ec2-user/app.pid) || true
    rm -f /home/ec2-user/app.pid
fi
