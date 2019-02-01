#! /bin/bash
# Provision: Make this (centos instance) a docker engine/docker-compose host
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce # latest version
systemctl enable docker
systemctl start docker
docker-compose_version=1.23.2
curl -L https://github.com/docker/compose/releases/download/${docker-compose_version}/docker-compose-`uname -s`-`uname -m` \
  -o /bin/docker-compose && \
  chmod +x /bin/docker-compose

# Dockerfile: Pull the base splunk image from dockerhub and configure it to accept the
# license and to set a password on startup. Also get it ready to be customized for this demo
cd /root
cat > ./Dockerfile << "EOF"
FROM splunk/splunk:latest
RUN sudo apt-get update && sudo apt-get install -y git
ENV SPLUNK_START_ARGS --accept-license
ENV SPLUNK_PASSWORD puppetlabs
ENV GITHUB_URL https://github.com/puppetlabs
ENV APP1 SplunkTAforPuppetEnterprise
ENV APP2 SplunkAppforPuppetEnterprise
EOF
# Build it
docker build -t splunkdemo_i .
# Run it, name it, open it up for web UI http traffic on port 8000
docker run --name splunkdemo_c -d -p 8000:8000 splunkdemo_i
# Reach into it and add two sample puppet/splunk apps
docker exec splunkdemo_c bash -c 'sudo git clone "${GITHUB_URL}/${APP1}.git" "/opt/splunk/etc/apps/${APP1}"'
docker exec splunkdemo_c bash -c 'sudo git clone "${GITHUB_URL}/${APP2}.git" "/opt/splunk/etc/apps/${APP2}"'
