# firefox over VNC
#
# VERSION               0.1
# DOCKER-VERSION        0.2

FROM	ubuntu:16.04
# Use the caching proxy
ARG APTPROXY
ENV APTPROXY=$APTPROXY
RUN echo "Acquire::http { Proxy \"$APTPROXY\"; };" >> \
    /etc/apt/apt.conf.d/01proxy
# make sure the package repository is up to date
RUN	echo "deb http://archive.ubuntu.com/ubuntu xenial main universe" > /etc/apt/sources.list
RUN	apt-get update

# Install vnc, xvfb in order to create a 'fake' display and firefox.
RUN	apt-get install -q -y x11vnc xvfb firefox 
RUN	mkdir ~/.vnc
# Setup a password
RUN	x11vnc -storepasswd 1234 ~/.vnc/passwd
# Autostart browser (might not be the best way to do it, but it does the trick)
RUN	bash -c 'echo "firefox" >> /.bashrc'