#!/bin/bash
echo "🚀 Iniciando aplicação..."

# garante que o python3 existe
command -v python3 >/dev/null 2>&1 || { echo "Python3 não encontrado!"; exit 1; }

nohup python3 /home/ec2-user/deploy/myapp/app.py > /home/ec2-user/app.log 2>&1 &
echo $! > /home/ec2-user/app.pid
