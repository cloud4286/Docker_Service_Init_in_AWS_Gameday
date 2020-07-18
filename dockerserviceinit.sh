#!/bin/bash
########Install Docker
yum install docker -y
########Set Docker start on boot
systemctl start docker
systemctl enable docker
########Get the amazonaws docker image
docker pull amazonlinux
########Create volume for docker
docker volume create server
docker volume create efs
#######Mount the efs target to docker
mount -t nfs A.B.C.D:/ /var/lib/docker/volumes/efs/_data
#######Get the Server
wget https://example.com/server
wget https://example.com/server.ini
chmod +x server
######Set the refund script
cat > refund.sh <<EOF
#!/bin/bash
while :
do
eventid=""
teamid=""
for i in \`grep -i refund logs|awk '{print \$7}'|sort|uniq\`
do
curl -i -H "Accept: application/json" -X POST -d '{"game":"'"\$eventid"'", "team":"'"\$teamid"'", "order":"'"\$i"'"}' https://stats.aws.dev-null.link/proc/refund
done
sleep 10
done
EOF
######Set the run script
cat > start.sh <<EOF
#!/bin/bash
cp refund.sh /root
cd /root
./refund.sh&
cd /server
./server
EOF
#######Init the Docker swarm and set pool addr 192.168.0.0/16
docker swarm init --default-addr-pool 192.169.0.0/16
chmod +x refund.sh
chmod +x start.sh
mkswap /dev/sdb
swapon /dev/sdb
#######Create the service of docker
docker service create --name server -p 80:80 --mount type=volume,source=server,destination=/server --mount type=volume,source=efs,destination=/efs -w /server amazonlinux ./start.sh