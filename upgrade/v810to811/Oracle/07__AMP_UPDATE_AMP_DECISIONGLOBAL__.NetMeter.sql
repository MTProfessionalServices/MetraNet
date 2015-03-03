WHENEVER SQLERROR EXIT SQL.SQLCODE
declare
row_exists integer;
BEGIN
  BEGIN
    select count(*)  into row_exists from t_amp_decisionglobal where c_name = 'Tax Vendor ID';
  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END;
  if row_exists = 0
  then
    BEGIN
      INSERT into t_amp_decisionglobal (c_DecisionGlobalDefault_Id, c__version, c_CreationDate, c_UpdateDate, c_Name, c_Description, c_DefaultValue) 
        values (sys_guid(),1, GETUTCDATE(), GETUTCDATE(),'Tax Vendor ID','id of tax software vendor from t_enum_data',NULL); 
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
