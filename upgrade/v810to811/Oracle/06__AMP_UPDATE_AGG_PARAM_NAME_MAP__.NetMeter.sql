WHENEVER SQLERROR EXIT SQL.SQLCODE
declare
row_exists integer;
BEGIN
  BEGIN
    select count(*)  into row_exists from agg_param_name_map where from_name = 'Tax Vendor ID';
  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END;
  if row_exists = 0
  then
    BEGIN
      INSERT INTO AGG_PARAM_NAME_MAP (FROM_NAME, TO_NAME) VALUES('Tax Vendor ID', 'id_tax_vendor');
      commit;
    EXCEPTION  
    WHEN OTHERS THEN
      BEGIN
        ROLLBACK;
        RAISE;
      END;
    END;
  END IF;
END;
/
