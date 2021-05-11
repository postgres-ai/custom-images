FROM sqitch/sqitch:1.0.0

ENTRYPOINT ["/bin/bash"]

COPY --chown=$USER ./migration-tools/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
