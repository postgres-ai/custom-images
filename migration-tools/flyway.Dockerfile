FROM flyway/flyway:7.7.3

ENTRYPOINT ["/bin/bash"]

COPY --chown=$USER ./migration-tools/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
