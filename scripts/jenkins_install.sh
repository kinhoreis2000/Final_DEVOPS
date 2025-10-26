#!/bin/bash
sudo yum -y update
sudo yum -y install nodejs
sudo yum -y install npm
sudo yum -y update
sudo yum -y install java-21-amazon-corretto
sudo yum -y install git
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum -y install jenkins
sudo fallocate -l 1G /swapfile_extend_1GB
sudo mount -o remount,size=5G /tmp/
sudo service jenkins start

