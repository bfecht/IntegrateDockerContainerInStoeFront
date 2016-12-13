FROM nvidia/cuda:8.0-devel
MAINTAINER Bernd Fecht "bernd.fecht@hs-augsburg.de"

# Install LXDE, VNC server and Firefox
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  firefox \
  lxde-core \
  lxterminal \
  tightvncserver
  
# Set user for VNC server (USER is only for build)
ENV USER root

RUN echo 'root:root' |chpasswd

EXPOSE 5901

COPY ./vnc.sh /opt/
CMD ["/opt/vnc.sh"]