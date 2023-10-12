#!/bin/bash
## this script shows how did i setup the first server
apt update
DEBIAN_FRONTEND=noninteractive apt install -y docker.io nginx
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
      - "8000:8000" 
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
    networks: 
      - backend

  # Mysql Service   
  mariadb:
    image: docker.io/bitnami/mariadb:11.1
    container_name: mariadb
    env_file:
      - ./.env    
    environment:
      MARIADB_USER: ${DB_USER}
      MARIADB_DATABASE: ${DB_NAME}
      MARIADB_PASSWORD: ${DB_PASSWORD}
      MARIADB_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
    networks:
      - backend
  # frontend service
  frontend:
    image: "0107romer/angular-app"
    ports:
      - "3000:80"
    restart: always
    container_name: frontend
    env_file:
        - ./.env
    environment:
      ANG_APP_SERVER_URL: ${ANG_APP_SERVER_URL}
    networks:
      - backend

networks:
  backend: 

' >> docker-compose.yml

docker-compose up -d

echo '
server {

   listen 80 default_server;
   server_name _;

   root /usr/share/nginx/html/;    

}
server {
        server_name iapi.cloudblog.in;

       location /{
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_pass http://127.0.0.1:8000;
                proxy_set_header X-Forwarded-Proto $scheme;

        }
}


server {
        server_name iapp.cloudblog.in;

       location /{
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_pass http://127.0.0.1:3000;
                proxy_set_header X-Forwarded-Proto $scheme;

        }
}
' >> /etc/nginx/sites-enabled/new
cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/backup
cp /etc/nginx/sites-enabled/new /etc/nginx/sites-enabled/default
serice nginx restart

snap install certbot --classic 
certbot --nginx -d iapp.cloudblog.in 
certbot --nginx -d iapi.cloudblog.in
