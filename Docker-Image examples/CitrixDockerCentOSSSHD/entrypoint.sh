#!/bin/sh

# generate host keys if not present
ssh-keygen -A

# do not detach (-D)
exec /usr/sbin/sshd -D