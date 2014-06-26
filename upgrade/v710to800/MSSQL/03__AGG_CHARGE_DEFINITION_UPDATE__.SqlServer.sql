BEGIN TRANSACTION;
BEGIN TRY
DECLARE @sql NVARCHAR(MAX);
IF (NOT EXISTS (select 1 from INFORMATION_SCHEMA.VIEWS where TABLE_SCHEMA='dbo' AND TABLE_NAME= 'agg_charge_definition'))
BEGIN
  IF (EXISTS (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA='dbo' AND TABLE_NAME= 'agg_charge_definition' AND TABLE_TYPE='BASE TABLE'))
  BEGIN
    IF (NOT EXISTS (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA='dbo' AND TABLE_NAME= 't_amp_generatedcharge' AND TABLE_TYPE='BASE TABLE'))
    BEGIN
      SET @sql = 'select NEWID() C_GENCHARGE_ID, 1 C__VERSION, CHARGE_TYPE_ID C_NAME, GETDATE() C_CREATIONDATE, GETDATE() C_UPDATEDATE,
        CHARGE_TYPE_ID C_DESCRIPTION, charge_qualification_group C_AMOUNTCHAIN, productview_name C_PRODUCTVIEWNAME
        into t_amp_generatedcharge
        from agg_charge_definition where row_num=1';
      EXEC sp_executesql @sql;
    END
   
    IF (NOT EXISTS (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA='dbo' AND TABLE_NAME= 't_amp_genchargedirective' AND TABLE_TYPE='BASE TABLE'))
    BEGIN
      SET @sql = 'select NEWID() C_DIRECTIVE_ID, 1 C__VERSION, NEWID() C_INTERNAL_KEY, GETDATE() C_CREATIONDATE, GETDATE() C_UPDATEDATE,
      b.C_GENCHARGE_ID C_GENCHARGE_ID, a.row_num C_ROW_NUM, a.include_table_name C_INCLUDE_TABLE_NAME, a.source_value C_SOURCE_VALUE, a.target_field C_TARGET_FIELD,
      a.include_predicate C_INCLUDE_PREDICATE, a.included_field_prefix C_INCLUDED_FIELD_PREFIX, a.field_name C_FIELD_NAME, a.population_string C_POPULATION_STRING,
      a.mvm_procedure C_MVM_PROCEDURE, a.child_charge_id C_CHILD_CHARGE_NAME, a.filter C_FILTER, a.default_value C_DEFAULT_VALUE
      into t_amp_genchargedirective
      from agg_charge_definition a
      inner join t_amp_generatedcharge b on a.charge_type_id = b.c_Name';
      EXEC sp_executesql @sql;
    END
    EXEC sp_rename 'agg_charge_definition', 'agg_charge_definition_bak';
  END

  SET @sql = 'create view agg_charge_definition
         as 
         select 
         a.c_Name as charge_type_id, 
         a.c_AmountChain as charge_qualification_group, 
         a.c_ProductViewName as productview_name, 
         b.c_row_num as row_num, 
         b.c_include_table_name as include_table_name, 
         b.c_source_value as source_value, 
         b.c_target_field as target_field, 
         b.c_include_predicate as include_predicate, 
         b.c_included_field_prefix as included_field_prefix, 
         b.c_field_name as field_name, 
         b.c_population_string as population_string, 
         b.c_mvm_procedure as mvm_procedure, 
         b.c_child_charge_name as child_charge_id, 
         b.c_filter as filter, 
         b.c_default_value as default_value 
         from t_amp_generatedcharge a 
         inner join t_amp_genchargedirective b on a.c_GenCharge_Id = b.c_GenCharge_Id';
    EXEC sp_executesql @sql;
    COMMIT TRANSACTION;
  END
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
END CATCH;