DECLARE @commit_charge_id uniqueidentifier
BEGIN TRY
  IF EXISTS (SELECT 1 FROM t_amp_generatedcharge WHERE c_name = 'Commitment') 
    BEGIN
	  SELECT @commit_charge_id=c_gencharge_id from t_amp_generatedcharge where c_name = 'Commitment';
	  IF NOT EXISTS (SELECT 1 FROM t_amp_genchargedirective WHERE c_gencharge_id = @commit_charge_id AND c_field_name= 'is_implied_tax') 
        BEGIN
   	      PRINT 'Inserting is_implied_tax row for Commitment charge into t_amp_genchargedirective'
	      BEGIN TRANSACTION
	        INSERT
              INTO t_amp_genchargedirective
              (
              c_Directive_Id,
              c__version,
              c_internal_key,
              c_CreationDate,
              c_UpdateDate,
              c_GenCharge_Id,
              c_row_num,
              c_include_table_name,
              c_source_value,
              c_target_field,
              c_include_predicate,
              c_included_field_prefix,
              c_field_name,
              c_population_string,
              c_mvm_procedure,
              c_child_charge_name,
              c_filter,
              c_default_value
              )
              VALUES
              (
              NEWid() /* c_Directive_Id */,
              1       /* c__version */,
              NEWId()   /* c_internal_key */,
              GETUTCDATE() /* c_CreationDate */,
              GETUTCDATE() /* c_UpdateDate */ ,
              @commit_charge_id /* c_GenCharge_Id */,
              8  /* c_row_num */,
			  NULL /* c_include_table_name */ ,
              NULL  /* c_source_value */ ,
              NULL  /* c_target_field */,
              NULL  /* c_include_predicate */ ,
              NULL  /* c_included_field_prefix */,
              'is_implied_tax' /* c_field_name */,
              'N' /* c_population_string */,
              NULL /* c_mvm_procedure */,
              NULL /* c_child_charge_name */,
              NULL /* c_filter */,
              NULL /* c_default_value */
              );
            UPDATE t_amp_genchargedirective set c_row_num = c_row_num -1 where c_GenCharge_id = @commit_charge_id		  	  
        END
      ELSE
	    BEGIN
		  PRINT 'Found existing is_implied_tax row for Commitment charge in t_amp_genchargedirective'	
		END
	  IF NOT EXISTS (SELECT 1 FROM t_amp_genchargedirective WHERE c_gencharge_id = @commit_charge_id AND c_field_name= 'tax_informational') 
        BEGIN
   	      PRINT 'Inserting tax_informational row for Commitment charge into t_amp_genchargedirective'
	      IF (@@trancount = 0)
			  BEGIN TRANSACTION
		  ELSE
			 PRINT 'Transaction is in progress'
	        INSERT
              INTO t_amp_genchargedirective
              (
              c_Directive_Id,
              c__version,
              c_internal_key,
              c_CreationDate,
              c_UpdateDate,
              c_GenCharge_Id,
              c_row_num,
              c_include_table_name,
              c_source_value,
              c_target_field,
              c_include_predicate,
              c_included_field_prefix,
              c_field_name,
              c_population_string,
              c_mvm_procedure,
              c_child_charge_name,
              c_filter,
              c_default_value
              )
              VALUES
              (
              NEWid() /* c_Directive_Id */,
              1       /* c__version */,
              NEWId()   /* c_internal_key */,
              GETUTCDATE() /* c_CreationDate */,
              GETUTCDATE() /* c_UpdateDate */ ,
              @commit_charge_id /* c_GenCharge_Id */,
              9  /* c_row_num */,
			  NULL /* c_include_table_name */ ,
              NULL  /* c_source_value */ ,
              NULL  /* c_target_field */,
              NULL  /* c_include_predicate */ ,
              NULL  /* c_included_field_prefix */,
              'tax_informational' /* c_field_name */,
              'N' /* c_population_string */,
              NULL /* c_mvm_procedure */,
              NULL /* c_child_charge_name */,
              NULL /* c_filter */,
              NULL /* c_default_value */
              );
            UPDATE t_amp_genchargedirective set c_row_num = c_row_num -1 where c_GenCharge_id = @commit_charge_id		  	  
        END
      ELSE
	    BEGIN
		  PRINT 'Found existing tax_informational row for Commitment charge in t_amp_genchargedirective'
		END
      IF (@@trancount > 0)
	    COMMIT
	END
  ELSE
    BEGIN
	  PRINT 'No Commitment charge found in t_amp_generatedcharge.  No updates for Commitment charge'
    END
END TRY
BEGIN CATCH
   SELECT 
     ERROR_NUMBER() AS ErrorNumber,
     ERROR_MESSAGE() AS ErrorMessage;
   IF @@TRANCOUNT >0
     BEGIN
	   ROLLBACK
     END
END CATCH;
