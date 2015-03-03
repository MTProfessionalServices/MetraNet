WHENEVER SQLERROR EXIT SQL.SQLCODE
declare
commitment_exists integer;
row_exists integer;
commit_charge_id raw(16);
BEGIN
  BEGIN
    SELECT COUNT(*)
    INTO commitment_exists
    FROM t_amp_generatedcharge
    WHERE c_name = 'Commitment';
  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END;
  IF commitment_exists = 1 THEN
    BEGIN
      SELECT c_gencharge_id
      INTO commit_charge_id
      FROM t_amp_generatedcharge
      WHERE c_name = 'Commitment';
      SELECT COUNT(*)
      INTO row_exists
      FROM t_amp_genchargedirective
      WHERE c_gencharge_id = commit_charge_id
      AND c_field_name     = 'is_implied_tax';
    EXCEPTION
    WHEN OTHERS THEN
      RAISE;
    END;
    IF row_exists = 0 THEN
      BEGIN
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
            sys_guid()
            /* c_Directive_Id */
            ,
            1
            /* c__version */
            ,
            sys_guid()
            /* c_internal_key */
            ,
            GETUTCDATE()
            /* c_CreationDate */
            ,
            GETUTCDATE()
            /* c_UpdateDate */
            ,
            commit_charge_id
            /* c_GenCharge_Id */
            ,
            8
            /* c_row_num */
            ,
            NULL
            /* c_include_table_name */
            ,
            NULL
            /* c_source_value */
            ,
            NULL
            /* c_target_field */
            ,
            NULL
            /* c_include_predicate */
            ,
            NULL
            /* c_included_field_prefix */
            ,
            'is_implied_tax'
            /* c_field_name */
            ,
            'N'
            /* c_population_string */
            ,
            NULL
            /* c_mvm_procedure */
            ,
            NULL
            /* c_child_charge_name */
            ,
            NULL
            /* c_filter */
            ,
            NULL
            /* c_default_value */
          );
        UPDATE t_amp_genchargedirective
        SET c_row_num        = c_row_num -1
        WHERE c_gencharge_id = commit_charge_id;
        COMMIT;
      EXCEPTION
      WHEN OTHERS THEN
        BEGIN
          ROLLBACK;
          RAISE;
        END;
      END;
    END IF;
    BEGIN
      SELECT COUNT(*)
      INTO row_exists
      FROM t_amp_genchargedirective
      WHERE c_gencharge_id = commit_charge_id
      AND c_field_name     = 'tax_informational';
    EXCEPTION
    WHEN OTHERS THEN
      RAISE;
    END;
    IF row_exists = 0 THEN
      BEGIN
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
            sys_guid()
            /* c_Directive_Id */
            ,
            1
            /* c__version */
            ,
            sys_guid()
            /* c_internal_key */
            ,
            GETUTCDATE()
            /* c_CreationDate */
            ,
            GETUTCDATE()
            /* c_UpdateDate */
            ,
            commit_charge_id
            /* c_GenCharge_Id */
            ,
            9
            /* c_row_num */
            ,
            NULL
            /* c_include_table_name */
            ,
            NULL
            /* c_source_value */
            ,
            NULL
            /* c_target_field */
            ,
            NULL
            /* c_include_predicate */
            ,
            NULL
            /* c_included_field_prefix */
            ,
            'tax_informational'
            /* c_field_name */
            ,
            'N'
            /* c_population_string */
            ,
            NULL
            /* c_mvm_procedure */
            ,
            NULL
            /* c_child_charge_name */
            ,
            NULL
            /* c_filter */
            ,
            NULL
            /* c_default_value */
          );
        UPDATE t_amp_genchargedirective
        SET c_row_num        = c_row_num -1
        WHERE c_gencharge_id = commit_charge_id;
        COMMIT;
      EXCEPTION
      WHEN OTHERS THEN
        BEGIN
          ROLLBACK;
          RAISE;
        END;
      END;
    END IF;
  END IF;
  END;
  /
