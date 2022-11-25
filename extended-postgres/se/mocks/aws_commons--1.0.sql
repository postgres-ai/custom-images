create schema if not exists aws_commons;

create type aws_commons.uri as (
    bucket varchar,
    filepath varchar,
    s3_region varchar
);

create or replace function aws_commons.create_s3_uri(bucket varchar, filepath varchar, s3_region varchar) returns aws_commons.uri as
   $$
begin
return row(bucket, filepath, s3_region);
end
   $$
language plpgsql;
