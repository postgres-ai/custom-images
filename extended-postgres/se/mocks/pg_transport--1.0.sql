create schema if not exists pgtransport;

create or replace function pgtransport.import_from_server(
   host text,
   port int,
   username text,
   password text,
   database text,
   local_password text,
   dry_run bool
) returns void as
   $$
begin
end
   $$
language plpgsql;


