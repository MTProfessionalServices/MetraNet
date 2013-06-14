           
				select id_cap_type as id_capability, tx_desc as capability_desc 
				from t_composite_capability_type
				where id_cap_type not in (select id_capability
											from t_export_report_security
											where id_rep = %%ID_REP%%)
 			