           
				select id_rep, id_capability, tx_desc as capability_desc 
				from t_export_report_security A
				left outer join t_composite_capability_type B ON A.id_capability = B.id_cap_type
				where id_rep = %%ID_REP%%
 			