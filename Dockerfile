FROM ubuntu:focal

LABEL maintainer="Bjoern Stierand <bjoern-github@innovention.de>"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  wget \
  vim-tiny \
  unbound \
  unbound-anchor \
  netcat \
	&& apt-get autoremove --purge -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD files/unbound.conf /etc/unbound/unbound.conf

RUN chown -R unbound.unbound /etc/unbound

USER unbound
RUN unbound-anchor -a /etc/unbound/root.key ; true
RUN unbound-control-setup \
	&& wget ftp://FTP.INTERNIC.NET/domain/named.cache -O /etc/unbound/root.hints \
  && rm /etc/unbound/unbound.conf.d/*

USER root
ADD files/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 53/udp
EXPOSE 53

VOLUME /etc/unbound/unbound.conf.d

HEALTHCHECK CMD netcat -z localhost 53

CMD ["/entrypoint.sh"]
