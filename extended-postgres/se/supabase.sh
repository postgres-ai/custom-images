#!/bin/bash

set -ex

# remove the "beta" and "rc" suffix in the PG_SERVER_VERSION variable (if exists)
PG_SERVER_VERSION="$( echo ${PG_SERVER_VERSION} | sed 's/beta.*//' | sed 's/rc.*//' )"

# install dependencies
apt-get update -o Acquire::CompressionTypes::Order::=gz
apt-get install --no-install-recommends -y \
   # plv8 extension requirements
   python3 pkg-config clang g++ libc++-dev libc++abi-dev \
   libglib2.0-dev libtinfo5 ninja-build binutils \

# supautils extension
if [ $(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc) = "1" ]; then \
  git clone https://github.com/supabase/supautils.git \
  && cd supautils \
  && make \
  && make install; \
fi \
# plv8 extension
&& cd /tmp && git clone --branch r3.1 --single-branch https://github.com/plv8/plv8 \
&& cd plv8 \
&& git checkout 8b7dc73 \
&& make DOCKER=1 install \
&& strip /usr/lib/postgresql/${PG_SERVER_VERSION}/lib/plv8-3.1.4.so
