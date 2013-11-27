
                        SELECT 		replace(isnull(rp_prmnames.c_param_name,''),'%','') as c_param_name,isnull(rp_prmnames.c_param_desc,'No Description') as c_param_desc
	                FROM		t_export_report_params rp_prms 
	                INNER JOIN	t_export_param_names rp_prmnames ON rp_prms.id_param_name = rp_prmnames.id_param_name
	                WHERE		rp_prms.id_rep = %%ID_REP%%	      
	