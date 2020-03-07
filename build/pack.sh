#! /usr/bin/bash

zip ./"RaccoonDelver_linux_x86_$1.zip" ./linux_x86/*
cp ./html5/RaccoonDelver.html ./html5/index.html
zip ./"RaccoonDelver_html5_$1.zip" ./html5/*
zip ./"RaccoonDelver_windows_$1.zip" ./windows/*

