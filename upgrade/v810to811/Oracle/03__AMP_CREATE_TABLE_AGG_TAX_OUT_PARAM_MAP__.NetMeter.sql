declare
table_exists integer;
begin
select count(*) into table_exists  from user_tables where table_name = 'AGG_TAX_OUT_PARAM_MAP';
if table_exists = 0
then
execute immediate
 '        CREATE TABLE AGG_TAX_OUT_PARAM_MAP(
        ID_TAX_VENDOR NUMBER(10,0) NOT NULL,
        ID_VIEW_IN NUMBER(10,0) NOT NULL,        
        CHARGE_NAME_IN NVARCHAR2(255) NOT NULL,
        PV_TABLE NVARCHAR2(255) NOT NULL, 
        FILTER NVARCHAR2(2000) NULL)';
end if;
end;  
/
      