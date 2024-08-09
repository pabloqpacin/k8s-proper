#!/usr/bin/env bash

# En el host de vbox, vagrant etc (en mi caso el GL76 PopOS)
# https://www.virtualbox.org/manual/ch06.html#network_hostonly
# Originally there was no file; the default Range was 192.168.56.0/21

if [ ! -d /etc/vbox ]; then sudo mkdir /etc/vbox; fi

sudo tee /etc/vbox/networks.conf << EOF
* 0.0.0.0/0 ::/0
EOF
