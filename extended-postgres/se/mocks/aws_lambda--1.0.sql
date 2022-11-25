create schema if not exists aws_lambda;

create type aws_lambda.response as (
    status_code int,
    payload json,
    executed_version text,
    log_result text
);

create or replace function aws_lambda.invoke(status_code int, payload json, executed_version text, log_result text) returns aws_lambda.response as
   $$
begin
return row(status_code, payload, executed_version, log_result);
end
   $$
language plpgsql;


