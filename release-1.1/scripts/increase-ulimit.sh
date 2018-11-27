#!/bin/bash
sudo sed -i  '1 a fs.file-max = 131072' /etc/sysctl.conf
sudo sysctl -p
sudo sed -i '1 a * soft     nproc          131072' /etc/security/limits.conf
sudo sed -i '1 a * hard     nproc          131072' /etc/security/limits.conf
sudo sed -i '1 a * soft     nofile         131072' /etc/security/limits.conf
sudo sed -i '1 a * hard     nofile         131072' /etc/security/limits.conf
sudo sed -i '1 a root soft     nproc          131072' /etc/security/limits.conf
sudo sed -i '1 a root hard     nproc          131072' /etc/security/limits.conf
sudo sed -i '1 a root soft     nofile         131072' /etc/security/limits.conf
sudo sed -i '1 a root hard     nofile         131072' /etc/security/limits.conf
sudo sed -i '1 a session required pam_limits.so' /etc/pam.d/common-session
ulimit -n 131072


