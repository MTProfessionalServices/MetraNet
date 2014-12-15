CREATE OR REPLACE procedure UpdateCounterInstance
		    (
				p_id_lang_code int,
				p_id_prop t_base_props.id_prop%type,
				counter_type_id t_counter.id_counter_type%type,
				nm_name_in t_base_props.nm_name%type,
				nm_desc_in t_base_props.nm_desc%type)
			  as
				updated_id_display_name int;
				updated_id_display_desc int;
			  begin
				UpdateBaseProps (p_id_prop, p_id_lang_code, NULL, nm_desc_in, NULL, updated_id_display_name, updated_id_display_desc);
				UPDATE t_base_props SET nm_name = nm_name_in,nm_desc = nm_desc_in
				WHERE
				id_prop = p_id_prop;
				UPDATE t_counter
				SET id_counter_type = counter_type_id
				WHERE id_prop = p_id_prop;
 			  end;
        