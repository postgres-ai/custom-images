# Postgres Images

## Extended images

PostgreSQL Docker images with various additional extensions. Includes HypoPG, pg_hint_plan, 
Timescale, Citus, PoWA extensions, pg_timetable, pg_show_plans, pg_cron, postgresql_anonymizer, 
pg_stat_kcache, pg_qualstats, bg_mon, pgextwlist, pg_auth_mon, set_user.

Available versions: 9.6, 10, 11, 12.

Use these images with Database Lab, when you need HypoPG or anything else. 

Proposals to add more extensions are welcome in the project repo: https://gitlab.com/postgres-ai/custom-images/-/issues

## Sync Instance images

PostgreSQL Docker images with WAL-G.

Available versions: 9.6, 10, 11, 12.

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
   postgresai/sync-instance:12
```
See the full list of configuration options in the [WAL-G project](https://github.com/wal-g/wal-g#configuration) repo.
