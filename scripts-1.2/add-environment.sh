#!/bin/bash
sudo cat /etc/environment > environment.txt
cat ../config-1.2/etc_environment >> environment.txt
sudo cp environment.txt /etc/environment