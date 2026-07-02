#!/bin/bash

set -e

echo "Updating system..."
sudo apt update -y
sudo apt upgrade -y

echo "Installing required packages..."
sudo apt install -y curl ca-certificates apt-transport-https gnupg lsb-release

if ! command -v docker &> /dev/null
then
    echo "Docker not found. Installing Docker..."
    sudo apt install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "Docker already installed."
fi

echo "Creating config directory..."
sudo mkdir -p /home/webtop
sudo chmod 777 /home/webtop

echo "Pulling Webtop image..."
sudo docker pull lscr.io/linuxserver/webtop:ubuntu-xfce

echo "Removing old container if exists..."
sudo docker rm -f webtop 2>/dev/null || true

echo "Starting Webtop container..."

sudo docker run -d \
  --name=webtop \
  --restart unless-stopped \
  --security-opt seccomp=unconfined \
  -p 3000:3000 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Tehran \
  -v /home/webtop:/config \
  --shm-size="1gb" \
  lscr.io/linuxserver/webtop:ubuntu-xfce

IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')

echo ""
echo "--------------------------------------"
echo "Webtop is running!"
echo ""
echo "Open your browser and go to:"
echo ""
echo "http://$IP:3000"
echo ""
echo "--------------------------------------"
