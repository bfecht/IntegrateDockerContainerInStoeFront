FROM nvidia/cuda:8.0-devel
MAINTAINER Bernd Fecht "bernd.fecht@hs-augsburg.de"

RUN apt-get update

# Install OpenSSH and set password
RUN \
	apt-get install -y openssh-client openssh-server && \
	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

EXPOSE 22

# Install CUDA Samples
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-samples-$CUDA_PKG_VERSION && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/cuda/samples/0_Simple/matrixMulCUBLAS
RUN make

# Add CUDA back to path during SSH
RUN echo "export PATH=$PATH:/usr/local/cuda/bin" >> /etc/profile

COPY ./ssh.sh /
CMD ["/ssh.sh"]