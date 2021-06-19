#!/usr/bin/bash 
clear
#banner block
echo -e "       \e[35;1m"


echo "                    ██╗  ██╗██╗██████╗  █████╗                                   "
echo "                    ██║ ██╔╝██║██╔══██╗██╔══██╗                                  "
echo "                    █████╔╝ ██║██████╔╝███████║                                  "
echo "                    ██╔═██╗ ██║██╔══██╗██╔══██║                                  "
echo "                    ██║  ██╗██║██║  ██║██║  ██║                                  "
echo "                    ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝                                  "
echo "                                                                                 "
echo "███╗   ███╗ ██████╗ ███╗   ██╗██╗████████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗ "
echo "████╗ ████║██╔═══██╗████╗  ██║██║╚══██╔══╝██╔═══██╗██╔══██╗██║████╗  ██║██╔════╝ "
echo "██╔████╔██║██║   ██║██╔██╗ ██║██║   ██║   ██║   ██║██████╔╝██║██╔██╗ ██║██║  ███╗"
echo "██║╚██╔╝██║██║   ██║██║╚██╗██║██║   ██║   ██║   ██║██╔══██╗██║██║╚██╗██║██║   ██║"
echo "██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██║   ██║   ╚██████╔╝██║  ██║██║██║ ╚████║╚██████╔╝"
echo "╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ "

##check root
set -x
[ `id -u` = '0' ] || { echo "EXIT=$? : You need to be a root user to run this script " ; exit ; }
#update block
apt update
apt upgrade -y
apt install -y curl wget
apt install snapd
snap install node --classic
npm install --global yarn 
#adding users for services
useradd -s /dev/null prometheus
useradd -s /dev/null node_exporter
#adding directories for prometheus
mkdir -p /etc/prometheus 
mkdir -p /var/lib/prometheus
#directories ownership
chown prometheus:prometheus /etc/prometheus 
chown prometheus:prometheus /var/lib/prometheus
#clonig repository from github
mkdir -p $GOPATH/src/github.com/prometheus
mv ./Dockerfile $GOPATH/src/github.com/prometheus/
cd $GOPATH/src/github.com/prometheus
git clone https://github.com/prometheus/prometheus.git
git clone https://github.com/prometheus/promu.git
cd promu
make build
./promu crossbuild -p linux/amd64
cd $GOPATH/src/github.com/prometheus/prometheus
mv $GOPATH/src/github.com/prometheus/Dockerfile /$GOPATH/src/github.com/prometheus/prometheus/
#building container
make build common-docker-amd64

#::TEST::  deluser prometheus && deluser node_exporter && rm -rf /etc/prometheus/ && rm -rf /lib/prometheus/ && rm -rf $GOPATH/src/github.com/prometheus/