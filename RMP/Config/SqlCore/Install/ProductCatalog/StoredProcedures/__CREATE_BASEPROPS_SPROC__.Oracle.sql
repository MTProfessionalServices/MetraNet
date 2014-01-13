
				CREATE OR REPLACE procedure sp_InsertBaseProps (a_kind int,
						a_nameID t_base_props.n_name%type,
						a_descID t_base_props.n_desc%type,
						a_approved t_base_props.b_approved%type,
						a_archive t_base_props.b_archive%type,
						a_nm_name t_base_props.nm_name%type,
						a_nm_desc t_base_props.nm_desc%type,
						a_id_prop OUT int )
				as
				begin
			  insert into t_base_props (id_prop,n_kind,n_name,n_desc,nm_name,nm_desc,b_approved,b_archive) values
			  (seq_t_base_props.nextval,a_kind,a_nameID,a_descID,a_nm_name,a_nm_desc,a_approved,a_archive);
			  select seq_t_base_props.currval into a_id_prop from dual;
				end;        