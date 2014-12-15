
      CREATE OR REPLACE procedure AddCounterParamType
          (id_lang_code int,
		   temp_n_kind int,
          nm_name nvarchar2,
          id_counter_type t_counter_params_metadata.id_counter_meta%type,
          nm_param_type t_counter_params_metadata.paramtype%type,
          nm_param_dbtype t_counter_params_metadata.DBtype%type,
          id_prop OUT int)
      as
				identity_value t_counter_params_metadata.id_prop%type;
				id_display_name int;
				id_display_desc int;
      BEGIN
				InsertBaseProps(id_lang_code, temp_n_kind, 'N', 'N', nm_name, NULL, NULL, identity_value, id_display_name, id_display_desc);

				INSERT INTO t_counter_params_metadata
					(id_prop, id_counter_meta, ParamType, DBType)
				VALUES
					(identity_value, id_counter_type, nm_param_type, nm_param_dbtype);
		        id_prop := identity_value;
			END;
      