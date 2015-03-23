declare
table_exists integer;
begin
select count(*) into table_exists  from user_tables where table_name = 'MVM_SERVER_PARAMS';
if table_exists = 0
then
execute immediate
 '      create table mvm_server_params(
        server_id NUMBER(10,0) NOT NULL,
        parameter_name VARCHAR2(400) NOT NULL,
        parameter_value VARCHAR2(400) NOT NULL)';
end if;
end;  
/
