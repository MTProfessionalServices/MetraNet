
				CREATE OR REPLACE procedure UpdateBaseProps(
				a_id_prop t_base_props.id_prop%type,
				a_id_lang int,
				a_nm_name t_base_props.nm_name%type,
				a_nm_desc t_base_props.nm_desc%type,
				a_nm_display_name t_base_props.nm_display_name%type,
				updated_id_display_name OUT int,
				updated_id_display_desc OUT int)
				AS
				old_id_name t_base_props.n_name%type;
				id_name t_base_props.n_name%type;
				old_id_desc t_base_props.n_desc%type;
				old_id_display_name t_base_props.n_display_name%type;
				BEGIN
					begin
						SELECT n_name, n_desc, n_display_name
						into old_id_name, old_id_desc, old_id_display_name
						from t_base_props where id_prop = a_id_prop;
					exception
						when no_data_found then
							null;
					end;
					UpsertDescription(a_id_lang, a_nm_name, old_id_name, id_name);
					UpsertDescription(a_id_lang, a_nm_desc, old_id_desc, updated_id_display_desc);
					UpsertDescription(a_id_lang, a_nm_display_name, old_id_display_name, updated_id_display_name);
					UPDATE t_base_props
					SET n_name = id_name, n_desc = updated_id_display_desc, n_display_name = updated_id_display_name,
							nm_name = a_nm_name, nm_desc = a_nm_desc, nm_display_name = a_nm_display_name
					WHERE id_prop = a_id_prop;
				END;
		