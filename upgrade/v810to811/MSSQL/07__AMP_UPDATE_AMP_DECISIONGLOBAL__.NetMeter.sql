BEGIN TRY
  IF NOT EXISTS(select 1 from t_amp_decisionglobal where c_name = 'Tax Vendor ID')
    BEGIN
	  PRINT 'INSERTING Tax Vendor ID row into t_amp_decision_global'
       INSERT into t_amp_decisionglobal (c_DecisionGlobalDefault_Id, c__version, c_CreationDate, c_UpdateDate, c_Name, c_Description, c_DefaultValue) 
        values (NEWID(),1, GETUTCDATE(), GETUTCDATE(),'Tax Vendor ID','id of tax software vendor from t_enum_data',NULL); 
    END
  ELSE
    PRINT 'Tax Vendor ID row found in t_amp_decision_global'
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
