FROM ubuntu:18.04
MAINTAINER Samuele Bistoletti <samuele.bistoletti@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Default versions
ENV TELEGRAF_VERSION 1.8.2-1
ENV INFLUXDB_VERSION 1.6.4
ENV GRAFANA_VERSION  5.3.2
ENV CHRONOGRAF_VERSION 1.6.2

# Database Defaults
ENV INFLUXDB_GRAFANA_DB datasource
ENV INFLUXDB_GRAFANA_USER datasource
ENV INFLUXDB_GRAFANA_PW datasource
ENV INFLUXDB_GRAFANA_DB_CUSTOM_1 uc
ENV INFLUXDB_GRAFANA_DB_CUSTOM_2 network
ENV INFLUXDB_GRAFANA_DB_CUSTOM_3 vpackets
ENV MYSQL_GRAFANA_USER grafana
ENV MYSQL_GRAFANA_PW grafana

# Fix bad proxy issue
COPY system/99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy

# Clear previous sources
RUN rm /var/lib/apt/lists/* -vf

# Base dependencies
RUN apt-get -y update && \
 apt-get -y dist-upgrade && \
 apt-get -y --force-yes install \
  apt-utils \
  ca-certificates \
  curl \
  fping \
  git \
  htop \
  libfontconfig \
  mysql-client \
  mysql-server \
  nano \
  net-tools \
  #net-snmp \
  snmp \ 
  snmp-mibs-downloader \
  snmpd \
  openssh-server \
  supervisor \
  wget \
  vim \
  tree 
  
  
  


  
# Configure Supervisord, SSH and base env
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /root

RUN mkdir -p /var/log/supervisor && \
    mkdir -p /root/python3-scripts && \
    mkdir -p /var/run/sshd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'root:root' | chpasswd && \
    rm -rf .ssh && \
    rm -rf .profile && \
    mkdir .ssh

COPY ssh/id_rsa .ssh/id_rsa
COPY bash/profile .profile

# Configure MySql
COPY scripts/setup_mysql.sh /tmp/setup_mysql.sh
RUN /tmp/setup_mysql.sh

# Install InfluxDB
RUN wget https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
	dpkg -i influxdb_${INFLUXDB_VERSION}_amd64.deb && rm influxdb_${INFLUXDB_VERSION}_amd64.deb

# Configure InfluxDB
COPY influxdb/influxdb.conf /etc/influxdb/influxdb.conf
COPY influxdb/init.sh /etc/init.d/influxdb
COPY influxdb/entrypoint.sh /etc/

# Install Telegraf
RUN wget https://dl.influxdata.com/telegraf/releases/telegraf_${TELEGRAF_VERSION}_amd64.deb && \
	dpkg -i telegraf_${TELEGRAF_VERSION}_amd64.deb && rm telegraf_${TELEGRAF_VERSION}_amd64.deb

# Configure Telegraf
COPY telegraf/telegraf.conf /etc/telegraf/telegraf.conf
COPY telegraf/init.sh /etc/init.d/telegraf

# Install chronograf
RUN wget https://dl.influxdata.com/chronograf/releases/chronograf_${CHRONOGRAF_VERSION}_amd64.deb && \
  dpkg -i chronograf_${CHRONOGRAF_VERSION}_amd64.deb

# Install Grafana
RUN wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${GRAFANA_VERSION}_amd64.deb && \
	dpkg -i grafana_${GRAFANA_VERSION}_amd64.deb && rm grafana_${GRAFANA_VERSION}_amd64.deb

# Configure Grafana
COPY grafana/grafana.ini /etc/grafana/grafana.ini
COPY grafana/provisionning/uc_data_source.yaml /etc/grafana/provisioning/datasources/uc_data_source.yaml
COPY grafana/provisionning/dashboards.yaml /etc/grafana/provisioning/dashboards/dashboards.yaml
COPY grafana/provisionning/uc-dashboards.json /etc/grafana/provisioning/dashboards/uc-dashboards.json
#COPY grafana/provisionning/UC-USA-1541099528408.json /etc/grafana/provisioning/dashboards/UC-USA-1541099528408.json


# Configure Python-Scripts
COPY python-scripts/python.sh /root/python3-scripts/python.sh
COPY python-scripts/test.py /root/python3-scripts/test.py
RUN chmod +x /root/python3-scripts/python.sh
RUN chmod +x /root/python3-scripts/test.py
# Cleanup
RUN apt-get clean && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/usr/bin/supervisord"]
