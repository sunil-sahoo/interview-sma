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
ANG_APP_SERVER_URL=http://'`curl api.ipify.org`':80

' >> .env

echo '
version: "3.1"
services:
  backend:
    # Configuration for building the docker image for the service
    image: docker.io/bitnami/laravel:10
    ports:
      - "80:8000" # Forward the exposed port 8080 on the container to port 8080 on the host machine
    restart: unless-stopped
    container_name: backend
    depends_on: 
      - mariadb
    env_file:
      - ./.env
    environment:
      DB_HOST: ${DB_HOST}
      DB_USERNAME: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      DB_DATABASE: ${DB_NAME}
      DB_PORT: ${DB_PORT}
      ALLOWED_ORIGINS: ${ALLOWED_ORIGINS}
    networks: # Networks to join (Services on the same network can communicate with each other using their name)
      - backend

  # Mysql Service   
  mariadb:
    image: docker.io/bitnami/mariadb:11.1
    env_file:
      - ./.env    
    environment:
      MARIADB_USER: ${DB_USER}
      MARIADB_DATABASE: ${DB_NAME}
      MARIADB_PASSWORD: ${DB_PASSWORD}
      MARIADB_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
    networks:
      - backend
networks:
  backend: 

' >> docker-compose.yml

docker-compose up -d

