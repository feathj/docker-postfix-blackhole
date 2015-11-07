FROM ubuntu:trusty

# bypass postfix install prompt
ENV DEBIAN_FRONTEND noninteractive

# install and cleanup
RUN apt-get update \
  && apt-get install -y supervisor postfix \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# add install script
COPY install.sh /install.sh
RUN /install.sh

# run in supervisor because postfix doesn't have an option
# to be run in the foreground
CMD /usr/bin/supervisord -c /etc/supervisor/supervisord.conf