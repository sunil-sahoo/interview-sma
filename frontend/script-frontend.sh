#!/bin/bash
apt update
DEBIAN_FRONTEND=noninteractive apt install -y docker.io
curl -SL https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod 777 /usr/local/bin/docker-compose
mkdir /root/interview_sma
cd /root/interview_sma
echo '
DB_HOST=mariadb
DB_USER=bn_myapp
DB_PASSWORD=xxx012812d
DB_ROOT_PASSWORD=12nziTlakd
DB_NAME=bitnami_myapp
DB_PORT=3306
ALLOWED_ORIGINS=*
ANG_APP_SERVER_URL=http://'`curl api.ipify.org`':8000

' >> .env

echo '
version: "3.1"
services:
  # frontend service
  frontend:
    image: "0107romer/angular-app"
    ports:
      - "80:80"
    restart: always
    container_name: frontend
    env_file:
        - ./.env
    environment:
      ANG_APP_SERVER_URL: ${ANG_APP_SERVER_URL}
    networks:
      - frontend

networks:
  frontend: 

' >> docker-compose.yml

docker-compose up -d

