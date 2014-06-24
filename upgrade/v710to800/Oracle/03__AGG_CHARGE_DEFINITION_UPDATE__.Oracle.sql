DECLARE
cnt NUMBER(10);
BEGIN
  select count(*) into cnt from dba_views where LOWER(VIEW_NAME)= 'agg_charge_definition';
  IF cnt > 0 THEN
  BEGIN
    select count(*) into cnt from dba_tables where LOWER(TABLE_NAME)= 'agg_charge_definition';
    IF cnt > 0 THEN
    BEGIN
      select count(*) into cnt from dba_tables where LOWER(TABLE_NAME)= 't_amp_generatedcharge';
      IF cnt = 0 THEN
        EXECUTE IMMEDIATE 'create table t_amp_generatedcharge as
        select SYS_GUID() C_GENCHARGE_ID,1 C__VERSION,CHARGE_TYPE_ID C_NAME,sysdate C_CREATIONDATE,sysdate C_UPDATEDATE,CHARGE_TYPE_ID C_DESCRIPTION,
        charge_qualification_group C_AMOUNTCHAIN,productview_name C_PRODUCTVIEWNAME
        from agg_charge_definition where row_num=1';
      END IF;
   
      select count(*) into cnt from dba_tables where LOWER(TABLE_NAME)= 't_amp_genchargedirective';
      IF cnt = 0 THEN
        EXECUTE IMMEDIATE 'create table t_amp_genchargedirective as
        select SYS_GUID() C_DIRECTIVE_ID, 1 C__VERSION, SYS_GUID() C_INTERNAL_KEY, sysdate C_CREATIONDATE, sysdate C_UPDATEDATE,
        b.C_GENCHARGE_ID C_GENCHARGE_ID, a.row_num C_ROW_NUM, a.include_table_name C_INCLUDE_TABLE_NAME, a.source_value C_SOURCE_VALUE, a.target_field C_TARGET_FIELD,
        a.include_predicate C_INCLUDE_PREDICATE, a.included_field_prefix C_INCLUDED_FIELD_PREFIX, a.field_name C_FIELD_NAME, a.population_string C_POPULATION_STRING,
        a.mvm_procedure C_MVM_PROCEDURE, a.child_charge_id C_CHILD_CHARGE_NAME, a.filter C_FILTER, a.default_value C_DEFAULT_VALUE
        from agg_charge_definition a
        inner join t_amp_generatedcharge b on a.charge_type_id = b.c_Name';
      END IF;
      EXECUTE IMMEDIATE 'alter table agg_charge_definition rename to agg_charge_definition_bak';    
    END;
    END IF;
    EXECUTE IMMEDIATE 'create view agg_charge_definition
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
    COMMIT;
  END;
  END IF;    
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK; 
END;