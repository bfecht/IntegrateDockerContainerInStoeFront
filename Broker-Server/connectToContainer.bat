:: This batch script is used to establish a SSH Connection to a Docker-Container in a virtual environment by Citrix
:: Params:
:: containerIP: The IP-Adress of the Container 
:: p: Port of the mapped Container
:: containerUserName: user name spezified in the Container
:: keyFile: Parth to Key-File
:: conConnectFile: Path to Connection-File

@echo off

TITLE Docker-XenApp Connector by b.fecht

set containerIP=%1
set p=%2
set /p containerUserName="Enter username: "
set keyFile=%HOMEDRIVE%%HOMEPATH%\.ssh\id_rsa.pub
set conConnectFile=%HOMEDRIVE%%HOMEPATH%\.ssh\%containerIP%-%p%-%containerUserName%.con

:: Two params needed
IF [%2]==[] GOTO SYNTAX

:: Check for key-file
IF exist %keyFile% GOTO CHECKCONNECTION

call ssh-keygen -f %HOMEDRIVE%%HOMEPATH%\.ssh\id_rsa -t rsa -N ''
call icacls %HOMEDRIVE%%HOMEPATH%\.ssh\ /t /grant:r *S-1-3-0:(F) /inheritance:r

:CHECKCONNECTION

:: Check ContainerConnection-File
IF exist %conConnectFile% GOTO SSH

call ssh %containerUserName%@%containerIP% -p %p% "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys || exit 1" < %keyFile%
echo DockerConnection: > %conConnectFile%
echo ContainerIP:	%containerIP% >> %conConnectFile%
echo Port:		%p% >> %conConnectFile%
echo UserName:		%containerUserName% >> %conConnectFile%

:SSH

call ssh %containerUserName%@%containerIP% -p %p%

GOTO END

:SYNTAX

echo Usage: 		establishSSH [arguments]
echo Arguments:		containerIP Port

:END