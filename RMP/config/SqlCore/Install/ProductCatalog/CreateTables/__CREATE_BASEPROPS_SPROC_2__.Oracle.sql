
				CREATE OR REPLACE procedure InsertBaseProps(
				id_lang_code int,
				a_kind t_base_props.n_kind%type,
				a_approved t_base_props.b_approved%type,
        a_archive t_base_props.b_archive%type,
        a_nm_name t_base_props.nm_name%type,
        a_nm_desc t_base_props.nm_desc%type,
        a_nm_display_name t_base_props.nm_display_name%type,
        a_id_prop out int)
				as
        id_desc_display_name t_base_props.n_display_name%type;
        id_desc_name t_base_props.n_name%type;
        id_desc_desc t_base_props.n_desc%type;
				begin
					UpsertDescription(id_lang_code, a_nm_display_name, NULL, id_desc_display_name) ;
					UpsertDescription(id_lang_code, a_nm_name, NULL, id_desc_name) ;
					UpsertDescription(id_lang_code, a_nm_desc, NULL, id_desc_desc) ;
					insert into t_base_props (id_prop, n_kind, n_name, n_desc,nm_name,nm_desc,b_approved,b_archive,
					n_display_name, nm_display_name) values
					(seq_t_base_props.nextval, a_kind, id_desc_name, id_desc_desc, a_nm_name,a_nm_desc,a_approved,a_archive,
					id_desc_display_name,a_nm_display_name);
					select seq_t_base_props.currval into a_id_prop from dual;
				end;
   