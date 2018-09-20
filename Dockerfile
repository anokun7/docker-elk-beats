FROM busybox:1
COPY filebeat.yml /tmp/filebeat.yml
CMD mkdir -p /filebeat/filebeat && cp /tmp/filebeat.yml /filebeat/filebeat/
