
			update t_recevent_inst ri
			set b_ignore_deps = 'Y'
			where exists (select 'x' 
			              from t_recevent re 
			              where re.id_event = ri.id_event and
                          re.tx_type = 'Root' and
			                    ri.id_arg_billgroup = %%ID_BILLGROUP%%)
	  