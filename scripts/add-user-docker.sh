#!/bin/bash
sudo groupadd docker
sudo usermod -a -G docker $USER
sudo reboot