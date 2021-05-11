FROM ruby:3.0.1-alpine3.13

RUN apk add --no-cache bash

COPY ./migration-tools/entrypoint.sh /entrypoint.sh

ENV USER=rake

RUN addgroup -S $USER && adduser -S $USER -G $USER

USER $USER

ENTRYPOINT ["/bin/bash"]
CMD ["/entrypoint.sh"]
