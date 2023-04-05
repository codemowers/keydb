FROM eqalpha/keydb:latest
RUN rm /etc/keydb/keydb.conf
RUN ln -s /usr/local/bin/keydb-cli /usr/local/bin/redis-cli
ADD entrypoint.sh liveness.sh readiness.sh /usr/local/bin/
VOLUME /data
WORKDIR /data
EXPOSE 6379
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["keydb-server"]
