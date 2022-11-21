# PostgreSQL Images

## Extended images
PostgreSQL Docker images with various additional extensions. Includes the majority of extensions, including those that are supported by RDS.

Derived from [official PostgreSQL images](https://hub.docker.com/_/postgres). One of the key differences is that PostgreSQL can be stopped or restarted without the container being stopped (this is because in the official image, the `postmaster` process is the main one).

Storage-optimized: the size of each image is ~300-500 MiB.

Use these images with Database Lab, when you need HypoPG or anything else.

### What's inside
Available PostgreSQL versions: 9.6 (EOL), 10, 11, 12, 13, 14, 15. Extensions:
- all official ["core" contrib modules](https://www.postgresql.org/docs/current/contrib.html)
- [bg_mon](https://github.com/CyberDem0n/bg_mon)
- [Citus](https://github.com/citusdata/citus)
- [HypoPG](https://github.com/HypoPG/hypopg)
- [logerrors](https://github.com/munakoiso/logerrors)
- [pg_auth_mon](https://github.com/RafiaSabih/pg_auth_mon)
- [pg_cron](https://github.com/citusdata/pg_cron)
- [pg_hint_plan](https://pghintplan.osdn.jp/pg_hint_plan.html)
- [pg_qualstats](https://github.com/powa-team/pg_qualstats)
- [pg_repack](https://github.com/reorg/pg_repack)
- [pg_show_plans](https://github.com/cybertec-postgresql/pg_show_plans)
- [pg_stat_kcache](https://github.com/powa-team/pg_stat_kcache)
- [pg_stat_monitor](https://github.com/percona/pg_stat_monitor)
- [pg_wait_sampling](https://github.com/postgrespro/pg_wait_sampling)
- [pg_timetable](https://github.com/cybertec-postgresql/pg_timetable)
- [pgaudit](https://github.com/pgaudit/pgaudit)
- [pgextwlist](https://github.com/dimitri/pgextwlist)
- [hll](https://github.com/citusdata/postgresql-hll)
- [topn](https://github.com/citusdata/postgresql-topn)
- [postgresql_anonymizer](https://gitlab.com/dalibo/postgresql_anonymizer) 
- [PoWA](https://github.com/powa-team/powa)
- [set_user](https://github.com/pgaudit/set_user)
- [Timescale](https://github.com/timescale/timescaledb)
- [postgis](https://github.com/postgis/postgis)
- [pgrouting](https://github.com/pgRouting/pgrouting)
- [pgtap](https://github.com/theory/pgtap)
- [plpgsql_check](https://github.com/okbob/plpgsql_check)
- [pljava](https://github.com/tada/pljava)
- [plv8](https://github.com/plv8/plv8)
- [rum](https://github.com/postgrespro/rum)
- [http](https://github.com/pramsey/pgsql-http)
- [pg_hashids](https://github.com/iCyberon/pg_hashids)
- [pg_graphql](https://github.com/supabase/pg_graphql)
- [pg_jsonschema](https://github.com/supabase/pg_jsonschema)
- [pg_net](https://github.com/supabase/pg_net)
- [pgjwt](https://github.com/michelp/pgjwt)
- [pgsodium](https://github.com/michelp/pgsodium)
- [supautils](https://github.com/supabase/supautils)

#### Not included in the PostgreSQL 15 image (yet)
The PostgreSQL 15 image is now missing the following extensions (they will be added in the future):
- pg_repack
- pg_auth_mon
- pg_hint_plan
- timescaledb
- pg_cron
- pg_show_plans
- pg_stat_monitor
- pljava
- rum
- pg_jsonschema

#### Not included in the PostgreSQL 14 image (yet)
The PostgreSQL 14 image is now missing the following extensions (they will be added in the future):
- pg_auth_mon

### How to extend
- You can fork this repository and extend `Dockerfile`, then build your own images
- Proposals to add more extensions to this repository are welcome https://gitlab.com/postgres-ai/custom-images/-/issues

### The complete list of available extensions
| name | version <br> (9.6) | version <br> (10) | version <br> (11) | version <br> (12) | version <br> (13) | version <br> (14) | comment |
| --- | --- | --- | --- | --- | --- | --- | --- |
| address_standardizer | 3.2.0          | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | Used to parse an address into constituent elements. Generally used to support geocoding address normalization step.
| address_standardizer_data_us | 3.2.0   | 3.2.1          | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | Address Standardizer US dataset example 
| adminpack          | 1.1             | 1.1             | 2.0             | 2.0             | 2.1             | 2.1             | administrative functions for PostgreSQL |
| amcheck            | 2               | 1.0             | 1.1             | 1.2             | 1.2             | 1.3             | functions for verifying relation integrity. ("amcheck_next" for Postgres 9.6) |
| anon               | 1.1.0           | 1.1.0           | 1.1.0           | 1.1.0           | 1.1.0           | 1.1.0           | Data anonymization tools |
| autoinc            | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | functions for autoincrementing fields |
| bloom              | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | bloom access method - signature file based index |
| btree_gin          | 1.0             | 1.2             | 1.3             | 1.3             | 1.3             | 1.3             | support for indexing common datatypes in GIN |
| btree_gist         | 1.2             | 1.5             | 1.5             | 1.5             | 1.5             | 1.6             | support for indexing common datatypes in GiST |
| citext             | 1.3             | 1.4             | 1.5             | 1.6             | 1.6             | 1.6             | data type for case-insensitive character strings |
| citus              |                 |                 | 10.0            | 10.2            | 11.1            | 11.1            | Citus distributed database |
| cube               | 1.2             | 1.2             | 1.4             | 1.4             | 1.4             | 1.5             | data type for multidimensional cubes |
| dblink             | 1.2             | 1.2             | 1.2             | 1.2             | 1.2             | 1.2             | connect to other PostgreSQL databases from within a database |
| ddlx               | 0.22            | 0.22            | 0.22            | 0.22            | 0.22            | 0.22            | DDL eXtractor functions |
| dict_int           | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | text search dictionary template for integers |
| dict_xsyn          | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | text search dictionary template for extended synonym processing |
| earthdistance      | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | calculate great-circle distances on the surface of the Earth |
| file_fdw           | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | foreign-data wrapper for flat file access |
| fuzzystrmatch      | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | determine similarities and distance between strings |
| hll                | 2.16            | 2.17            | 2.17            | 2.17            | 2.17            | 2.17            | type for storing hyperloglog data |
| hstore             | 1.4             | 1.4             | 1.5             | 1.6             | 1.7             | 1.8             | data type for storing sets of (key, value) pairs |
| hstore_plpython3u  | 1.0             | 1.0             | 1.0             | 1 .0            | 1.0             | 1.0             | transform between hstore and plpython3u |
| http               | 1.5             | 1.5             | 1.5             | 1.5             | 1.5             | 1.5             | HTTP client for PostgreSQL, allows web page retrieval inside the database |
| hypopg             | 1.3.1           | 1.3.1           | 1.3.1           | 1.3.1           | 1.3.1           | 1.3.1           | Hypothetical indexes for PostgreSQL |
| insert_username    | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | functions for tracking who changed a table |
| intagg             | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | integer aggregator and enumerator (obsolete) |
| intarray           | 1.2             | 1.2             | 1.2             | 1.2             | 1.3             | 1.5             | functions, operators, and index support for 1-D arrays of integers |
| isn                | 1.1             | 1.1             | 1.2             | 1.2             | 1.2             | 1.2             | data types for international product numbering standards |
| jsonb_plpython3u  |                  |                 | 1.0             | 1.0             | 1.0             | 1.0             | transform between jsonb and plpython3u |
| lo                 | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | Large Object maintenance |
| logerrors          |                 | 2.0             | 2.0             | 2.0             | 2.0             | 2.0             | Function for collecting statistics about messages in logfile
| ltree              | 1.1             | 1.1             | 1.1             | 1.1             | 1.2             | 1.2             | data type for hierarchical tree-like structures |
| ltree_plpython3u   | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | transform between ltree and plpython3u |
| moddatetime        | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | functions for tracking last modification time |
| moddatetime        | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | functions for tracking last modification time |
| old_snapshot       |                 |                 |                 |                 |                 | 1.0             | iutilities in support of old_snapshot_threshold |
| pg_auth_mon        | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             |                 | monitor connection attempts per user |
| pg_buffercache     | 1.2             | 1.3             | 1.3             | 1.3             | 1.3             | 1.3             | examine the shared buffer cache |
| pg_cron            | 1.4             | 1.4             | 1.4             | 1.4             | 1.4             | 1.4             | Job scheduler for PostgreSQL |
| pg_freespacemap    | 1.1             | 1.2             | 1.2             | 1.2             | 1.2             | 1.2             | examine the free space map (FSM) |
| pg_graphql         |                 |                 |                 |                 | 0.4.0           | 0.4.0           | GraphQL support |
| pg_hashids         | 1.3             | 1.3             | 1.3             | 1.3             | 1.3             | 1.3             | Short unique id generator for PostgreSQL, using hashids |
| pg_hint_plan       | 1.2.7           | 1.3.6           | 1.3.7           | 1.3.7           | 1.3.7           | 1.4             |  makes it possible to tweak PostgreSQL execution plans using so-called "hints" in SQL comments |
| pg_jsonschema      |                 |                 |                 | 0.1.0           | 0.1.0           | 0.1.0           | PostgreSQL extension providing JSON Schema validation |
| pg_net             |                 |                 |                 | 0.6             | 0.6             | 0.6             | Async HTTP |
| pg_prewarm         | 1.1             | 1.1             | 1.2             | 1.2             | 1.2             | 1.2             | prewarm relation data |
| pg_qualstats       | 2.0.3           | 2.0.4           | 2.0.4           | 2.0.4           | 2.0.4           | 2.0.4           | An extension collecting statistics about quals |
| pg_repack          | 1.4.7           | 1.4.7           | 1.4.7           | 1.4.7           | 1.4.7           | 1.4.7           | Reorganize tables in PostgreSQL databases with minimal locks |
| pg_show_plans      | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | show query plans of all currently running SQL statements |
| pg_stat_kcache     | 2.2.0           | 2.2.1           | 2.2.1           | 2.2.1           | 2.2.1           | 2.2.1           | Kernel statistics gathering |
| pg_wait_sampling   | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | sampling based statistics of wait events |
| pg_stat_statements | 1.4             | 1.6             | 1.6             | 1.7             | 1.8             | 1.9             | track execution statistics of all SQL statements executed |
| pg_stat_monitor    |                 |                 | 1.0             | 1.0             | 1.0             | 1.0             | The pg_stat_monitor is a PostgreSQL Query Performance Monitoring tool, based on PostgreSQL contrib module pg_stat_statements. pg_stat_monitor provides aggregated statistics, client information, plan details including plan, and histogram information.
| pg_surgery         |                  |                 |                 |                 |                 | 1.0             | extension to perform surgery on a damaged relation |
| pg_trgm            | 1.3             | 1.3             | 1.4             | 1.4             | 1.5             | 1.6             | text similarity measurement and index searching based on trigrams |
| pg_visibility      | 1.1             | 1.2             | 1.2             | 1.2             | 1.2             | 1.2             | examine the visibility map (VM) and page-level visibility info |
| pgaudit            | 1.1.4           | 1.2.4           | 1.3.4           | 1.4.3           | 1.5.2           | 1.6.2           | provides auditing functionality |
| pgcrypto           | 1.3             | 1.3             | 1.3             | 1.3             | 1.3             | 1.3             | cryptographic functions |
| pgjwt              | 0.2.0           | 0.2.0           | 0.2.0           | 0.2.0           | 0.2.0           | 0.2.0           | JSON Web Token API for Postgresql |
| pgrouting          | 3.0.2           | 3.0.2           | 3.0.2           | 3.3.3           | 3.3.3           | 3.3.3           | pgRouting Extension
| pgrowlocks         | 1.2             | 1.2             | 1.2             | 1.2             | 1.2             | 1.2             | show row-level locking information |
| pgsodium           | 1.1.1           | 2.0.2           | 2.0.2           | 2.0.2           | 2.0.2           | 3.0.5           | Postgres extension for libsodium functions |
| pgstattuple        | 1.4             | 1.5             | 1.5             | 1.5             | 1.5             | 1.5             | show tuple-level statistics |
| pgtap              | 1.2.0           | 1.2.0           | 1.2.0           | 1.2.0           | 1.2.0           | 1.2.0           | Unit testing for PostgreSQL
| plcoffee           | 3.1.4           | 3.1.4           | 3.1.4           | 3.1.4           | 3.1.4           | 3.1.4           | PL/CoffeeScript (v8) trusted procedural language
| pljava             | 1.5.6           | 1.5.6           | 1.5.6           | 1.6.4           | 1.6.4           | 1.6.4           | PL/Java procedural language
| plls               | 3.1.4           | 3.1.4           | 3.1.4           | 3.1.4           | 3.1.4           | 3.1.4           | PL/LiveScript (v8) trusted procedural language
| plpgsql            | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | PL/pgSQL procedural language |
| plpgsql_check      | 1.16            | 2.1             | 2.1             | 2.2             | 2.2             | 2.2             | extended check for plpgsql functions
| plv8               | 3.1.4           | 3.1.4           | 3.1.4           | 3.1.4           | 3.1.4           | 3.1.4           | PL/JavaScript (v8) trusted procedural language
| plpython3u         | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | PL/Python3U untrusted procedural language |
| postgis            | 3.2.0           | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | PostGIS geometry and geography spatial types and functions
| postgis_raster     | 3.2.0           | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | PostGIS raster types and functions
| postgis_sfcgal     | 3.2.0           | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | PostGIS SFCGAL functions
| postgis_tiger_geocoder | 3.2.0       | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | PostGIS tiger geocoder and reverse geocoder
| postgis_topology   | 3.2.0           | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | 3.2.1           | PostGIS topology spatial types and functions
| postgres_fdw       | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.1             | foreign-data wrapper for remote PostgreSQL servers |
| powa               | 4.1.2           | 4.1.4           | 4.1.4           | 4.1.4           | 4.1.4           | 4.1.4           | PostgreSQL Workload Analyser-core |
| refint             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | functions for implementing referential integrity (obsolete) |
| rum                | 1.3             | 1.3             | 1.3             | 1.3             | 1.3             | 1.3             | RUM index access method
| seg                | 1.1             | 1.1             | 1.3             | 1.3             | 1.3             | 1.4             | data type for representing line segments or floating-point intervals |
| set_user           | 3.0             | 3.0             | 3.0             | 3.0             | 3.0             | 3.0             | similar to SET ROLE but with added logging |
| sslinfo            | 1.2             | 1.2             | 1.2             | 1.2             | 1.2             | 1.2             | information about SSL certificates |
| supautils          |                 | 0.1.0           | 0.1.0           | 0.1.0           | 0.1.0           | 0.1.0           | Supabase standard library. PostgreSQL extension that prevents doing ALTER/DROP/GRANT on a set of reserved roles. |
| tablefunc          | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | functions that manipulate whole tables, including crosstab |
| tcn                | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | Triggered change notifications |
| timescaledb        |                 |                 |                 | 2.8.1           | 2.8.1           | 2.8.1           | Enables scalable inserts and complex queries for time-series data |
| timetravel         | 1.0             | 1.0             | 1.0             |                 |                 |                 | functions for implementing time travel |
| topn               |                 | 2.5.0           | 2.5.0           | 2.5.0           | 2.5.0           | 2.5.0           | type for top-n JSONB |
| tsm_system_rows    | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | 1.0             | TABLESAMPLE method which accepts number of rows as a limit |
| tsm_system_time    | 1.0             | 1.0             | 1.0             | 1.0             | 11.0            | 1.0             | TABLESAMPLE method which accepts time in milliseconds as a limit |
| unaccent           | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | text search dictionary that removes accents |
| uuid-ossp          | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | 1.1             | generate universally unique identifiers (UUIDs) |
| xml2               | 1.1             |1.1              | 1.1             | 1.1             | 1.1             | 1.1             | XPath querying and XSLT |

### PostgreSQL Tools:
- [WAL-G](https://github.com/wal-g/wal-g)
- [pgBackRest](https://github.com/pgbackrest/pgbackrest)

