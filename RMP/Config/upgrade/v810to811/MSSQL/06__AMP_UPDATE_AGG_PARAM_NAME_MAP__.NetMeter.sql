BEGIN TRY
  IF NOT EXISTS(select 1 from agg_param_name_map where from_name = 'Tax Vendor ID')
    BEGIN
	  PRINT 'INSERTING Tax Vendor ID row into AGG_PARAM_NAME_MAP'
      INSERT INTO AGG_PARAM_NAME_MAP (FROM_NAME, TO_NAME) VALUES('Tax Vendor ID', 'id_tax_vendor');
    END
  ELSE
    PRINT 'Tax Vendor ID row found in AGG_PARAM_NAME_MAP'
END TRY
BEGIN CATCH
   SELECT 
     ERROR_NUMBER() AS ErrorNumber,
     ERROR_MESSAGE() AS ErrorMessage;
   IF @@TRANCOUNT > 0
     BEGIN
	   ROLLBACK
     END
END CATCH
