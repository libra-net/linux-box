#!/bin/bash

# Init user home in volume
if test ! -f /home/user/.bashrc; then
	cp -a /etc/skel/.bash* /etc/skel/.profile* /home/user
	chown -R user.user /home/user
fi
