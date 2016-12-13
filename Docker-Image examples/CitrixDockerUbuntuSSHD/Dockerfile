FROM       ubuntu:14.04
MAINTAINER Bernd Fecht "bernd.fecht@hs-augsburg.de"

RUN apt-get update

RUN \
	apt-get install -y openssh-client openssh-server && \
	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

EXPOSE 22

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]