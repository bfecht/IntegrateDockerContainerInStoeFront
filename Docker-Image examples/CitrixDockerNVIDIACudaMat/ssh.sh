#!/bin/sh

# Set up LD_LIBRARY_PATH
ldconfig

# do not detach (-D)
exec /usr/sbin/sshd -D