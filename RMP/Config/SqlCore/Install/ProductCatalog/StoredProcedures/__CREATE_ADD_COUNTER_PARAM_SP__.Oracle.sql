
				CREATE OR REPLACE procedure AddCounterParam
				(
				 p_id_lang_code int,
				 p_id_counter int,
				 id_counter_param_type int,
				 nm_counter_value nvarchar2,
				 nm_name nvarchar2,
				 nm_desc nvarchar2,
				 nm_display_name nvarchar2,
				 identity OUT int)
				AS
				identity_value int;
				id_display_name int;
				id_display_desc int;
				BEGIN
	        InsertBaseProps (p_id_lang_code, 190, 'N', 'N', nm_name, nm_desc, nm_display_name, identity_value, id_display_name, id_display_desc);
					INSERT INTO t_counter_params
			    (id_counter_param,id_counter, id_counter_param_meta, Value)
			    VALUES
				  (identity_value,p_id_counter, id_counter_param_type, nm_counter_value);
			    identity :=identity_value;
  			end;
          