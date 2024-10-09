# PostgreSQL Images

## Extended images
PostgreSQL Docker images with various additional extensions. Includes the majority of extensions, including those that are supported by RDS.

Derived from [official PostgreSQL images](https://hub.docker.com/_/postgres). One of the key differences is that PostgreSQL can be stopped or restarted without the container being stopped (this is because in the official image, the `postmaster` process is the main one).

Storage-optimized: the size of each image is ~300-500 MiB.

Use these images with Database Lab, when you need HypoPG or anything else.

### What's inside
Available PostgreSQL versions: 9.6 (EOL), 10 (EOL), 11 (EOL), 12, 13, 14, 15, 16, 17. Extensions:
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
- [pg_wait_sampling](https://github.com/postgrespro/pg_wait_sampling)
- [pg_timetable](https://github.com/cybertec-postgresql/pg_timetable)
- [pgaudit](https://github.com/pgaudit/pgaudit)
- [pgextwlist](https://github.com/dimitri/pgextwlist)
- [hll](https://github.com/citusdata/postgresql-hll)
- [topn](https://github.com/citusdata/postgresql-topn)
- [postgresql_anonymizer](https://github.com/webysther/postgresql_anonymizer) 
- [PoWA](https://github.com/powa-team/powa)
- [set_user](https://github.com/pgaudit/set_user)
- [timescaledb](https://github.com/timescale/timescaledb)
- [pgvector](https://github.com/pgvector/pgvector)

#### Not included in the PostgreSQL 17 image (yet)
The PostgreSQL 17 image is now missing the following extensions (they will be added in the future):
- powa
- citus
- topn

### How to extend
- You can fork this repository and extend `Dockerfile`, then build your own images
- Proposals to add more extensions to this repository are welcome https://gitlab.com/postgres-ai/custom-images/-/issues

### PostgreSQL Tools:
- [WAL-G](https://github.com/wal-g/wal-g)
- [pgBackRest](https://github.com/pgbackrest/pgbackrest)
