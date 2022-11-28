create schema if not exists log_fdw;

create or replace function log_fdw.list_postgres_log_files() returns void as
   $$
begin
end
   $$
language plpgsql;

create or replace function log_fdw.create_foreign_table_for_log_file(
    table_name text,
    server_name text,
    log_file_name text
) returns void as
   $$
begin
end
   $$
language plpgsql;
