#!/bin/bash

set -ex

apt-get clean && rm -rf /var/lib/apt/lists/partial \
&& apt-get update -o Acquire::CompressionTypes::Order::=gz \
&& apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
  bc lsb-release apt-utils

# apg_plan_mgmt extension
# Mocked

# aurora_stat_utils extension
# Mocked

# aws_commons extension
# Mocked

# aws_lambda extension
# Mocked

# aws_s3 extension
# copy from build-env

# aws_ml extension
# Mocked

# pg_hint_plan extension
# already in the "Generic" image

# pg_proctab extension
# copy from build-env

# postgis extension
# (+ address_standardizer, postgis_raster, postgis_sfcgal, postgis_tiger_geocoder, postgis_topology)
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION} \
   postgresql-${PG_SERVER_VERSION}-postgis-${POSTGIS_VERSION}-scripts

# pgrouting extension
apt-get install -y --no-install-recommends \
   postgresql-${PG_SERVER_VERSION}-pgrouting

# hll extension
# already in the "Generic" image

# ip4r extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-ip4r

# oracle_fdw requirements
apt-get install -y --no-install-recommends \
  libaio1

# oracle_fdw extension
# copy from build-env

# log_fdw extension
# Mocked
# This extension allowing access database engine log using a SQL interface.

# orafce extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-orafce

# pg_bigm extension
# copy from build-env

# pg_cron extension
# already in the "Generic" image

# pg_partman extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-partman

# pg_repack extension
# already in the "Generic" image

# pg_similarity extension
apt-get install -y --no-install-recommends \
    postgresql-${PG_SERVER_VERSION}-similarity

# pg_transport extension
# Mocked
# This extension provides a physical transport mechanism to move PostgreSQL databases between two Amazon RDS DB instances.
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.TransportableDB.html

# pgaudit extension
# already in the "Generic" image

# pglogical extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-pglogical

# pgtap extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-pgtap

# plperl extension
# (+ bool_plperl + hstore_plperl + jsonb_plperl)
apt-get install -y --no-install-recommends \
  postgresql-plperl-${PG_SERVER_VERSION}

# flow_control extension
# Mocked

# plprofiler extension
if [ "$(echo "$PG_SERVER_VERSION > 9.6" | /usr/bin/bc)" = "1" ]; then \
  apt-get install -y --no-install-recommends \
    postgresql-${PG_SERVER_VERSION}-plprofiler;
fi

# pltcl extension
apt-get install -y --no-install-recommends \
  postgresql-pltcl-${PG_SERVER_VERSION}

# pg_tle extension
# copy from build-env

# prefix extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-prefix

# rdkit extension
# Mocked
# RDKit is a collection of cheminformatics and machine-learning software written in C++ and Python.

# rds_tools extension
# Mocked

# tds_fdw extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-tds-fdw

# test_parser extension
# copy from build-env

# tsearch2 extension (deprecated)
# The tsearch2 extension is deprecated in version 10.
# The tsearch2 extension was remove from PostgreSQL version 11.1 on Amazon RDS (deprecated).

# mysql_fdw extension
apt-get install -y --no-install-recommends \
  postgresql-${PG_SERVER_VERSION}-mysql-fdw

# plv8 extension (+ plcoffee, plls)
# copy from build-env

# babelfish extensions
# copy from build-env

# rds_activity_stream
# Mocked

# remove all auxiliary packages to reduce final image size
apt-get purge -y --auto-remove \
  apt-transport-https apt-utils lsb-release bc
apt-get clean -y autoclean
rm -rf /var/lib/apt/lists/*
