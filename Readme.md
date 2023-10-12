# Here is the process of the setup
1. Script.sh shows the command that i run to setup the first server
2. After the first server is setup i have taken a snapshot of it and created more servers with same size and same tag
3. Creating the new droplets with same tag will add it to the LoadBalancer
4. LoadBalancer has 443 port open with SSL passthrough. As i have setup nginx vhost and SSL on the droplet itself.
5. Latest version of Laravel and angular is deployed throgh docker-compose

# Here is the process of the pipeline
1. Pipleline is set to run and deploy (docker-compose up -d) on PR merge to main branch
2. Pipeline simply SSH to the droplets and does (docker-compose pull && docker-compose up -d) this will pull the latest image and deploy 
3. NOTE** we are not doing the build here in pipeline.

# Here is the proces of monitoring
1. Monitoring is set to send alert to my email when CPU and memory Utililization is above 70% for 5 mins
2. And Disk utilization is above 75% for 5 mins

# Here is process of the Loadbalancer
1. Loadbalancer takes the tag of the droplets and sends traffic to the droplets having the same tag
2. SSL of port 443 is set to passthrough as the SSL is enabled on droplet level as nginx SSL
3. Always redirect from HTTP to HTTPS is enabled for more security

