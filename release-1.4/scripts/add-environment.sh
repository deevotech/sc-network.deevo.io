#!/bin/bash
sudo cat /etc/environment > environment.txt
cat ../config/etc_environment >> environment.txt
sudo cp environment.txt /etc/environment