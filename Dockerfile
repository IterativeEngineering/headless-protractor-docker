FROM ubuntu

MAINTAINER kgasior@iterative.pl

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get install -y \
  wget 

RUN apt-get update && \
  apt-get install -y \
    supervisor \
    netcat-traditional \
    xvfb \
    openjdk-8-jre \
    firefox \
    ffmpeg \
    libcurl4 \
    curl \
    dirmngr \
    gpg-wks-client \
    npm \
    gnupg \
  && \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
  apt-get update -y && \
  apt-get install google-chrome-stable -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  apt-get update && \
  apt-get install -y nodejs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install Protractor and initialized Webdriver
RUN npm install -g protractor@^7

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
