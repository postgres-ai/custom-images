FROM python:3.9.4-alpine3.13

RUN apk add --no-cache bash && pip install django

ENV PATH="/home/django/.local/bin":$PATH
ENV USER=django

RUN addgroup -S $USER && adduser -S $USER -G $USER

USER $USER

COPY ./migration-tools/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash"]
CMD ["/entrypoint.sh"]
