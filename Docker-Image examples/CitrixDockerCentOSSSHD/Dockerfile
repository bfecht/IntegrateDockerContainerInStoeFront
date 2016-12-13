FROM centos:7
MAINTAINER Bernd Fecht "bernd.fecht@hs-augsburg.de"

RUN \
  yum -y install openssh-clients openssh-server && \
  yum -y clean all && \
  touch /run/utmp && \
  chmod u+s /usr/bin/ping && \
  echo "root:root" | chpasswd
  
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
  
EXPOSE 22

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]