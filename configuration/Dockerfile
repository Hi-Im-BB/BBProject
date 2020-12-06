FROM zabbix/zabbix-server-pgsql
LABEL maintainer "Pedro Martins"

USER root

COPY down_detector.sh /usr/lib/zabbix/externalscripts/

RUN chown zabbix.zabbix /usr/lib/zabbix/externalscripts/down_detector.sh &&\
chmod a+rx /usr/lib/zabbix/externalscripts/down_detector.sh &&\
apk add jq nano