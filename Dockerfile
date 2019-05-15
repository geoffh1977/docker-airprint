FROM ubuntu:bionic
LABEL maintainer="geoffh1977 <geoffh1977@gmail.com>"

# Add repos
RUN echo 'deb http://us.archive.ubuntu.com/ubuntu/ bionic multiverse' >> /etc/apt/sources.list.d/multiverse.list && \
	echo 'deb-src http://us.archive.ubuntu.com/ubuntu/ bionic multiverse' >> /etc/apt/sources.list.d/multiverse.list && \
	echo 'deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse' >> /etc/apt/sources.list.d/multiverse.list && \
	echo 'deb-src http://us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse' >> /etc/apt/sources.list.d/multiverse.list && \
	echo 'deb http://archive.ubuntu.com/ubuntu/ bionic-security multiverse' >> /etc/apt/sources.list.d/multiverse.list && \
	echo 'deb-src http://archive.ubuntu.com/ubuntu/ bionic-security multiverse' >> /etc/apt/sources.list.d/multiverse.list

# Install the packages we need. Avahi will be included
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install --no-install-recommends -y cups	cups-pdf inotify-tools python-cups dbus avahi-daemon && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf && \
	mkdir -p /opt/airprint

# Add scripts
COPY scripts/airprint-generate.py /opt/airprint/
COPY scripts/printer-update.sh /opt/airprint/
COPY scripts/run_cups.sh /opt/airprint/

RUN chmod 0755 /opt/airprint/printer-update.sh /opt/airprint/run_cups.sh /opt/airprint/airprint-generate.py

EXPOSE 631
VOLUME /config /services
WORKDIR /tmp
CMD ["/opt/airprint/run_cups.sh"]
