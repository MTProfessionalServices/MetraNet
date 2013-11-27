
				create or replace procedure AddCounterInstance
				(id_lang_code int,
				 n_kind int,
				 nm_name nvarchar2,
				 nm_desc nvarchar2,
			   counter_type_id t_counter.id_counter_type%type, 
			   id_prop OUT int) 
	   	  as
				identity_value int;
    		begin 
					InsertBaseProps(id_lang_code, n_kind, 'N', 'N', nm_name, nm_desc, null, identity_value);
					INSERT INTO t_counter (id_prop, id_counter_type) values (identity_value, counter_type_id);
					id_prop := identity_value;
				end;
        