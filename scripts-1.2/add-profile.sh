#!/bin/bash
cat ~/.profile > profile.txt
cat ../config-1.2/profile >> profile.txt
cp profile.txt ~/.profile
source ~/.profile