#!/bin/bash
sudo groupadd --system docker
sudo usermod -a -G docker $USER
sudo reboot