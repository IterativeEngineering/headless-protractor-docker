FROM debian:sid

MAINTAINER kgasior@iterative.pl

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get install -y \
  wget 

RUN wget http://ftp.br.debian.org/debian/pool/main/o/openldap/libldap-common_2.4.49+dfsg-3_all.deb
RUN dpkg -i libldap-common_2.4.49+dfsg-3_all.deb

RUN apt-get update && \
  apt-get install -y \
    supervisor \
    netcat-traditional \
    xvfb \
    openjdk-8-jre \
    chromium \
    firefox \
    ffmpeg \
    libcurl4 \
    curl \
    dirmngr \
    gpg-wks-client \
    libldap-2.4-2 \
    gnupg \
  && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  apt-get update && \
  apt-get install -y nodejs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install Protractor and initialized Webdriver
RUN npm install -g protractor@^5.4 && \
  webdriver-manager update

# Add a non-privileged user for running Protrator
RUN adduser --home /project --uid 1000 \
  --disabled-login --disabled-password --gecos node node

# Add main configuration file
ADD supervisord.conf /etc/supervisor/supervisor.conf

# Add service defintions for Xvfb, Selenium and Protractor runner
ADD supervisord/*.conf /etc/supervisor/conf.d/

# By default, tests in /data directory will be executed once and then the container
# will quit. When MANUAL envorinment variable is set when starting the container,
# tests will NOT be executed and Xvfb and Selenium will keep running.
ADD bin/run-protractor /usr/local/bin/run-protractor
ADD bin/run-webdriver /usr/local/bin/run-webdriver

# Container's entry point, executing supervisord in the foreground
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisor.conf"]

# Protractor test project needs to be mounted at /project
