FROM ruby:3.0.4-alpine3.15

RUN apk add --no-cache bash libpq-dev ruby-dev gcc libffi-dev libc-dev make

COPY ./migration-tools/entrypoint.sh /entrypoint.sh

ENV USER=rake

RUN addgroup -S $USER && adduser -S $USER -G $USER

USER $USER

ENTRYPOINT ["/bin/bash"]
CMD ["/entrypoint.sh"]
