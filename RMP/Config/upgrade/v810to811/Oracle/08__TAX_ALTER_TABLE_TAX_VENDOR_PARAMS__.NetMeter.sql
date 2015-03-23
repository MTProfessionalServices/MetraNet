WHENEVER SQLERROR EXIT SQL.SQLCODE
declare
column_exists integer;
BEGIN
  BEGIN
    select count(*) into column_exists  from user_tab_columns where table_name = 'T_TAX_VENDOR_PARAMS' and column_name = 'TX_DIRECTION';
  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END; 
if column_exists = 0
then
BEGIN
  execute immediate
  '    ALTER TABLE T_TAX_VENDOR_PARAMS  ADD (TX_DIRECTION number(10) NULL) ';
  EXCEPTION
    WHEN OTHERS THEN
    RAISE;
  END;
end if;

END;  
/