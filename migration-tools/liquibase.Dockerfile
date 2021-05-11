FROM liquibase/liquibase:4.3.3

ENTRYPOINT ["/bin/bash"]

COPY --chown=$USER ./migration-tools/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]

