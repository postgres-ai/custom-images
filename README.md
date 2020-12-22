# PostgreSQL Images

## Extended images
PostgreSQL Docker images with various additional extensions. Includes the majority of extensions, including those that are supported by RDS.

Derived from [official PostgreSQL images](https://hub.docker.com/_/postgres). One of the key differences is that PostgreSQL can be stopped or restarted without the container being stopped (this is because in the official image, the `postmaster` process is the main one).

Storage-optimized: the size of each image is just ~120 MiB.

Use these images with Database Lab, when you need HypoPG or anything else.

### What's inside
Available PostgreSQL versions: 9.6, 10, 11, 12, 13. Extensions:
- all official ["core" contrib modules](https://www.postgresql.org/docs/current/contrib.html)
- [bg_mon](https://github.com/CyberDem0n/bg_mon)
- [Citus](https://github.com/citusdata/citus)
- [HypoPG](https://github.com/HypoPG/hypopg)
- [pg_auth_mon](https://github.com/RafiaSabih/pg_auth_mon)
- [pg_cron](https://github.com/citusdata/pg_cron)
- [pg_hint_plan](https://pghintplan.osdn.jp/pg_hint_plan.html)
- [pg_qualstats](https://github.com/powa-team/pg_qualstats)
- [pg_repack](https://github.com/reorg/pg_repack)
- [pg_show_plans](https://github.com/cybertec-postgresql/pg_show_plans)
- [pg_stat_kcache](https://github.com/powa-team/pg_stat_kcache)
- [pg_timetable](https://github.com/cybertec-postgresql/pg_timetable)
- [pgaudit](https://github.com/pgaudit/pgaudit)
- [pgextwlist](https://github.com/dimitri/pgextwlist)
- [hll](https://github.com/citusdata/postgresql-hll)
- [topn](https://github.com/citusdata/postgresql-topn)
- [postgresql_anonymizer](https://github.com/webysther/postgresql_anonymizer) 
- [PoWA](https://github.com/powa-team/powa)
- [set_user](https://github.com/pgaudit/set_user)
- [Timescale](https://github.com/timescale/timescaledb)

#### Not included in the PostgreSQL 13 image (yet)
The PostgreSQL 13 image is now missing the following extensions (they will be added in the future):
- hll
- topn
- citus
- hypopg
- pg_auth_mon
- pg_hint_plan
- pgaudit
- powa
- timescaledb

### How to extend
- You can fork this repository and extend `Dockerfile`, then build your own images
- Proposals to add more extensions to this repository are welcome https://gitlab.com/postgres-ai/custom-images/-/issues

### The complete list of available extensions
| name | version | comment |
| --- | --- | --- |
| adminpack          | 2.0             | administrative functions for PostgreSQL |
| amcheck            | 1.1             | functions for verifying relation integrity |
| anon               | 0.6.0           | Data anonymization tools |
| autoinc            | 1.0             | functions for autoincrementing fields |
| bloom              | 1.0             | bloom access method - signature file based index |
| btree_gin          | 1.3             | support for indexing common datatypes in GIN |
| btree_gist         | 1.5             | support for indexing common datatypes in GiST |
| citext             | 1.5             | data type for case-insensitive character strings |
| citus              | 9.4-1           | Citus distributed database |
| cube               | 1.4             | data type for multidimensional cubes |
| dblink             | 1.2             | connect to other PostgreSQL databases from within a database |
| ddlx               | 0.16            | DDL eXtractor functions |
| dict_int           | 1.0             | text search dictionary template for integers |
| dict_xsyn          | 1.0             | text search dictionary template for extended synonym processing |
| earthdistance      | 1.1             | calculate great-circle distances on the surface of the Earth |
| file_fdw           | 1.0             | foreign-data wrapper for flat file access |
| fuzzystrmatch      | 1.1             | determine similarities and distance between strings |
| hll                | 2.14            | type for storing hyperloglog data |
| hstore             | 1.5             | data type for storing sets of (key, value) pairs |
| hypopg             | 1.1.3           | Hypothetical indexes for PostgreSQL |
| insert_username    | 1.0             | functions for tracking who changed a table |
| intagg             | 1.1             | integer aggregator and enumerator (obsolete) |
| intarray           | 1.2             | functions, operators, and index support for 1-D arrays of integers |
| isn                | 1.2             | data types for international product numbering standards |
| lo                 | 1.1             | Large Object maintenance |
| ltree              | 1.1             | data type for hierarchical tree-like structures |
| moddatetime        | 1.0             | functions for tracking last modification time |
| pageinspect        | 1.7             | inspect the contents of database pages at a low level |
| pg_auth_mon        | 1.0             | monitor connection attempts per user |
| pg_buffercache     | 1.3             | examine the shared buffer cache |
| pg_cron            | 1.2             | Job scheduler for PostgreSQL |
| pg_freespacemap    | 1.2             | examine the free space map (FSM) |
| pg_hint_plan       | 1.3.6           |  |
| pg_prewarm         | 1.2             | prewarm relation data |
| pg_qualstats       | 2.0.2           | An extension collecting statistics about quals |
| pg_repack          | 1.4.5           | Reorganize tables in PostgreSQL databases with minimal locks |
| pg_show_plans      | 1.0             | show query plans of all currently running SQL statements |
| pg_stat_kcache     | 2.1.3           | Kernel statistics gathering |
| pg_stat_statements | 1.6             | track execution statistics of all SQL statements executed |
| pg_trgm            | 1.4             | text similarity measurement and index searching based on trigrams |
| pg_visibility      | 1.2             | examine the visibility map (VM) and page-level visibility info |
| pgaudit            | 1.3.2           | provides auditing functionality |
| pgcrypto           | 1.3             | cryptographic functions |
| pgrowlocks         | 1.2             | show row-level locking information |
| pgstattuple        | 1.5             | show tuple-level statistics |
| plpgsql            | 1.0             | PL/pgSQL procedural language |
| postgres_fdw       | 1.0             | foreign-data wrapper for remote PostgreSQL servers |
| powa               | 4.0.1           | PostgreSQL Workload Analyser-core |
| refint             | 1.0             | functions for implementing referential integrity (obsolete) |
| seg                | 1.3             | data type for representing line segments or floating-point intervals |
| set_user           | 2.0             | similar to SET ROLE but with added logging |
| sslinfo            | 1.2             | information about SSL certificates |
| tablefunc          | 1.0             | functions that manipulate whole tables, including crosstab |
| tcn                | 1.0             | Triggered change notifications |
| timescaledb        | 1.7.2           | Enables scalable inserts and complex queries for time-series data |
| timetravel         | 1.0             | functions for implementing time travel |
| topn               | 2.3.0           | type for top-n JSONB |
| tsm_system_rows    | 1.0             | TABLESAMPLE method which accepts number of rows as a limit |
| tsm_system_time    | 1.0             | TABLESAMPLE method which accepts time in milliseconds as a limit |
| unaccent           | 1.1             | text search dictionary that removes accents |
| uuid-ossp          | 1.1             | generate universally unique identifiers (UUIDs) |
| xml2               | 1.1             | XPath querying and XSLT |

### PostgreSQL Tools:
- [WAL-G](https://github.com/wal-g/wal-g)

## Sync Instance images

**Deprecated. Use the extended image instead.**

PostgreSQL Docker images with WAL-G.

Available versions: 9.6, 10, 11, 12, and 13.

Use these images when you need set up a replica fetching WAL archives from an S3-compatible storage.

Example of sync instance usage with backups in Google Cloud Storage:
```bash
docker run \
   --name sync-instance \
   --env PGDATA=/var/lib/postgresql/pgdata \
   --env WALG_GS_PREFIX="gs://{BUCKET}/{SCOPE}" \
   --env GOOGLE_APPLICATION_CREDENTIALS="/etc/sa/credentials.json" \
   --volume /home/service_account.json:/etc/sa/credentials.json \
   --volume /var/lib/dblab/data:/var/lib/postgresql/pgdata:rshared \
   --detach \
   postgresai/sync-instance:13
```
See the full list of configuration options in the [WAL-G project](https://github.com/wal-g/wal-g#configuration) repo.
