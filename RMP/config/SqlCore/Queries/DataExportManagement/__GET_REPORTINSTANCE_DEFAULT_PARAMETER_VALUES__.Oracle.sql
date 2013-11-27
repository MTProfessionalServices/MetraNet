
			   SELECT 
			   rp_prms.id_param_name as IDParameterInstance, 
			   replace(rp_names.c_param_name,'%','') as ParameterNameInstance, 
			   rp_names.c_param_desc as ParameterDescriptionInstance, 
               tpdfv.c_param_value as ParameterValueInstance, 
			   tpdfv.id_param_values as IDParameterValueInstance     
               FROM  t_export_report_params rp_prms         
               INNER JOIN t_export_param_names rp_names ON rp_prms.id_param_name = rp_names.id_param_name
                    INNER JOIN t_export_default_param_values tpdfv ON rp_prms.id_param_name = tpdfv.id_param_name
						INNER JOIN t_export_report_instance eri ON rp_prms.id_rep = eri.id_rep and eri.id_rep_instance_id = tpdfv.id_rep_instance_id
							WHERE eri.id_rep_instance_id = %%ID_REP_INSTANCE_ID%%
                        