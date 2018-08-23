#!/bin/bash
cat ~/.profile > profile.txt
cat ../config/profile >> profile.txt
cp profile.txt ~/.profile