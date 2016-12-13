# Integrate Docker-Containern on the StoreFront

These Script-Examples provide an ability to register Docker-Container as XenApps.
For complete understanding of this integration you have to refer to the thesis by Bernd Fecht.

## Getting Started

The following instructions help you to set up the environment for the Docker-Integration.

### Prerequisites

To use this solution you must have a running virtual Citrix-environment with an Host-VM that is able to create Docker-Containers.

### Host-VM

SSH and Docker must be installed on th Host-VM.

#### Docker-Container running on the Host-VM

The Docker-Container must be able to act as SSH-servers. Therefore you have to extend your Base-Image:

Dockerfile:
```
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
```

entrypoint.sh:
```
#!/bin/sh

# generate host keys if not present
ssh-keygen -A

# do not detach (-D)
exec /usr/sbin/sshd -D
```

There are example-Images in the "Docker-Images example" Folder you can build and run.

### Broker-Server

The Broker-Server is a virtual Windows Server instance running that must be added to a Machine-Catalog in your XenStudio.
Furthermore the server should be placed into a Delivery-Group.

The Broker-Server must be able to act as a SSH-Client. You can use either OpenSSH for Microsoft or an Windows Server 2016
that natively supports SSH.

The Script attached in the "Broker-Server" Folder in this project must be placed into your homedrive! 

### Delivery-Controller

You need full admin-access to your Delivery-Controller. The Skripts located in the "Delivery-Controller" folder should be placed somewhere
where you can access them easily from your Host-VM. These Scripts register the Docker-Container as XenApps to the StoreFront.
You can either access the Script by SSH or Remote-PowerShell from your Host-VM or call them directly on the Delivery-Controller.

## Usage

### Register the Containers as XenApps on the StoreFront

Call the createXenContainer.ps1 script with the following params: 

* **hostVMIP** : The IP-Adress of your Host-VM the Docker-Containers are running.
* **p** : The mapped Port of your Docker-Container.
* **containerName** : Name of your Container. This name will be displayed in the StoreFront later.
* **brokerVMName** : Name of the Broker-Server.
* **desktopGroupName** : Name of the Delivery-Group you want the Docker-Container to be placed in.
* **machineCatalogName** : Name of the Machine-Catalog the Broker-Server was delivered in.

#### Delete the Contrainers from the StoreFront

Call the deleteXenContainer.ps1 script with the following params: 

* **hostVMIP** : The IP-Adress of your Host-VM the Docker-Containers are running.
* **p** : The mapped Port of your Docker-Container.
* **containerName** : Name of your Container. This name will be displayed in the StoreFront later.
* **brokerVMName** : Name of the Broker-Server.

### Example Usage

Here is an example how you can use SSH in a Shell-Script to call the PowerShell Script on the Delivery-Controller:

Call createXenContainer.ps1:
```
#!/bin/bash

#ssh Params
deliveryControllerIP="$1"
xenAdmin="$2"

#site Params
brokerVMName="$3"
desktopGroupName="$4"
machineCatalogName="$5"

#container Params
containerName="$6"
containerPort="${7:-"$(docker port "$containerName" | cut -d \: -f 2)"}"

hostVMIP=`(ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')`

ssh "$xenAdmin"@"$deliveryControllerIP" 'powershell "C:\createXenContainer.ps1 '"$hostVMIP"' '"$containerPort"' '"$containerName"' '"$brokerVMName"' '"$desktopGroupName"' '"$machineCatalogName"'"'

```

Call deleteXenContainer.ps1:
```
#ssh Params
deliveryControllerIP="$1"
xenAdmin="$2"

#site Params
brokerVMName="$3"

#container Params
containerName="$4"
containerPort="${5:-"$(docker port "$containerName" | cut -d \: -f 2)"}"

hostVMIP=`(ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')`

ssh "$xenAdmin"@"$deliveryControllerIP" 'powershell "C:\deleteXenContainer.ps1 '"$hostVMIP"' '"$containerPort"' '"$containerName"' '"$brokerVMName"'"'

```

These Skripts are also available in the "Host-VM" folder.

## Authors

* **Bernd Fecht** - *Initial work* - [bfecht](https://github.com/bfecht)