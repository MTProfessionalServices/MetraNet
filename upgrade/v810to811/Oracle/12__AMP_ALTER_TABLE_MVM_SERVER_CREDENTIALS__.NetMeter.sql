WHENEVER SQLERROR EXIT SQL.SQLCODE
declare
table_exists integer;
server_id_exists integer;
server_type_exists integer;
pk_exists integer;
constraint_exists integer;
index_exists integer;
rename_statement varchar2(200);
BEGIN
  select count(*) into table_exists  from user_tables where table_name = 'MVM_SERVER_CREDENTIALS';
  if table_exists = 0  then
  BEGIN
    select count(*) into constraint_exists from user_constraints where constraint_name = 'MVM_SERVER_CRED_PK';
    if (constraint_exists = 1) then
    BEGIN
      select 'alter table '|| table_name ||' rename constraint mvm_server_cred_pk to mvm_server_cred_pk_'||dbms_random.string('A', 6) into rename_statement from 
              user_constraints where constraint_name = 'MVM_SERVER_CRED_PK';
      execute immediate (rename_statement);
    END;
    end if;
    select count(*) into index_exists from user_indexes where index_name = 'MVM_SERVER_CRED_PK';
    if (index_exists = 1) then
    BEGIN
      select 'alter index '|| index_name || ' rename to mvm_server_cred_pk_'||dbms_random.string('A',6) into rename_statement from 
        user_indexes where index_name = 'MVM_SERVER_CRED_PK';
      execute immediate (rename_statement);
    END;  
    end if;
    execute immediate
    '        create table mvm_server_credentials(
          server_type VARCHAR2(400) not null,
          server_id NUMBER(10,0) not null,
          server VARCHAR2(400) not null,
          username VARCHAR2(4000) null,
          password VARCHAR2(4000) null,
          CONSTRAINT mvm_server_cred_pk PRIMARY KEY (server_id))';
  END;
  else
    BEGIN
      select count(*) into server_id_exists from user_tab_columns where table_name = 'MVM_SERVER_CREDENTIALS' and column_name = 'SERVER_ID';
      select count(*) into server_type_exists from user_tab_columns where table_name = 'MVM_SERVER_CREDENTIALS' and column_name = 'SERVER_TYPE';
      select count(*) into pk_exists from user_indexes i join user_ind_columns ic on i.index_name = ic.index_name where i.table_name = 'MVM_SERVER_CREDENTIALS' and ic.column_name = 'SERVER_ID';
      if (server_id_exists = 0 or server_type_exists = 0 or pk_exists = 0)
      then
      BEGIN
        select 'alter table mvm_server_credentials rename to mvm_server_credentials_'|| dbms_random.string('A', 6) into rename_statement from dual;
        execute immediate (rename_statement);
        select count(*) into constraint_exists from user_constraints where constraint_name = 'MVM_SERVER_CRED_PK';
        if (constraint_exists = 1) then
        BEGIN
          select 'alter table '|| table_name ||' rename constraint mvm_server_cred_pk to mvm_server_cred_pk_'||dbms_random.string('A', 6) into rename_statement from 
              user_constraints where constraint_name = 'MVM_SERVER_CRED_PK';
          execute immediate (rename_statement);
        END;
        end if;
        select count(*) into index_exists from user_indexes where index_name = 'MVM_SERVER_CRED_PK';
        if (index_exists = 1) then
        BEGIN
          select 'alter index '|| index_name || ' rename to mvm_server_cred_pk_'||dbms_random.string('A',6) into rename_statement from 
          user_indexes where index_name = 'MVM_SERVER_CRED_PK';
          execute immediate (rename_statement);
        END;  
        end if;
        execute immediate
        ' create table mvm_server_credentials(
          server_type VARCHAR2(400) not null,
          server_id NUMBER(10,0) not null,
          server VARCHAR2(400) not null,
          username VARCHAR2(4000) null,
          password VARCHAR2(4000) null,
          CONSTRAINT mvm_server_cred_pk PRIMARY KEY (server_id))';
      END;
      end if;
   END;  
  end if;
EXCEPTION
  WHEN OTHERS THEN
  RAISE;
END;
/
