FROM ubuntu:lunar

LABEL maintainer="Grzegorz Sterniczuk <docker@sternicz.uk>"
LABEL org.opencontainers.image.source https://github.com/dzikus/cups-airprint

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
	cups \
	cups-pdf \
	cups-bsd \
	cups-filters \
	cups-core-drivers \
	cups-filters-core-drivers \
	cups-ppdc \
	hplip \
	inotify-tools \
	foomatic-db-compressed-ppds \
	printer-driver-all \
	openprinting-ppds \
	hpijs-ppds \
	hp-ppd \
	python3-cups \
	cups-backend-bjnp \
	ghostscript-x foomatic-db-engine \
        libgtk-3-dev \
        avahi-daemon libjpeg62

COPY cnrdrvcups-ufr2-uk_5.70-1.18_arm64.deb /tmp/cnrdrvcups-ufr2-uk_5.70-1.18_arm64.deb
RUN dpkg -i /tmp/cnrdrvcups-ufr2-uk_5.70-1.18_arm64.deb

RUN apt clean all \
  && rm -rf /var/lib/apt/lists/*

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

# Add scripts
ADD root /
RUN chmod +x /root/*
CMD ["/root/run_cups.sh"]

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing No/Browsing Yes/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
        sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf
