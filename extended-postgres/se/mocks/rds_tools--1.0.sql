create schema if not exists rds_tools;

create type rds_tools.response as (
    role_name text,
    encryption_method text
);

create or replace function rds_tools.role_password_encryption_type() returns rds_tools.response as
   $$
begin
return row(role_name, encryption_method);
end
   $$
language plpgsql;


