#! /bin/bash
# Provision: Make this (centos instance) a docker engine/docker-compose host
yum install -y yum-utils device-mapper-persistent-data lvm2 git
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce # latest version
systemctl enable docker
systemctl start docker
compose_version=1.23.2
curl -L https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-`uname -s`-`uname -m` \
  -o /bin/docker-compose && \
  chmod +x /bin/docker-compose

### Deploy Pupperware
cd /root
git clone https://github.com/puppetlabs/pupperware.git && \
cd pupperware && \
docker-compose up -d
