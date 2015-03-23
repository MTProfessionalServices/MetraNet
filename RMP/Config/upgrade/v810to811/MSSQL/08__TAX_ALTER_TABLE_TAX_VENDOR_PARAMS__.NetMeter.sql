BEGIN TRY
  IF NOT EXISTS(select 1 from sys.columns where name = 'TX_DIRECTION' and object_id = object_id('T_TAX_VENDOR_PARAMS'))
    BEGIN
	  PRINT 'Adding column TX_DIRECTION to T_TAX_VENDOR_PARAMS table'
      ALTER TABLE T_TAX_VENDOR_PARAMS add TX_DIRECTION int null         
    END
  ELSE
    PRINT 'TX_DIRECTION column already exists in T_TAX_VENDOR_PARAMS table'
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
