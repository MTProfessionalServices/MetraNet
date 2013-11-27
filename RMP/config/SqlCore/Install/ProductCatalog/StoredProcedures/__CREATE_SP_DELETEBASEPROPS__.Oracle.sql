
				CREATE OR REPLACE procedure DeleteBaseProps(
				a_id_prop t_base_props.id_prop%type)
				as
				id_desc_display_name t_base_props.nm_display_name%type;
				id_desc_name t_base_props.n_name%type;
				id_desc_desc t_base_props.n_desc%type;
				begin
                    for i in (
					SELECT n_name, n_desc, n_display_name
					from t_base_props where id_prop = a_id_prop) loop
                        id_desc_name:=i.n_name;
                        id_desc_desc:=i.n_desc;
                        id_desc_display_name:=i.n_display_name;
                    end loop;
					DeleteDescription(id_desc_display_name);
					DeleteDescription(id_desc_name);
					DeleteDescription(id_desc_desc);
					DELETE FROM t_base_props WHERE id_prop = a_id_prop;
				end;
		