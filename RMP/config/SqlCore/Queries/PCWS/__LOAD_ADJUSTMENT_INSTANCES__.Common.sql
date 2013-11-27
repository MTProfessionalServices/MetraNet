
                Select
	                aj.id_prop ID,
	                bp.nm_name Name,
	                bp.nm_display_name DisplayName,
	                adjDesc.id_lang_code LanguageCode,
	                adjDesc.tx_desc
                from
	                t_adjustment aj
	                inner join
	                t_base_props bp on aj.id_prop = bp.id_prop
	                left outer join
	                t_description adjDesc on bp.n_display_name = adjDesc.id_desc
                where
	                aj.id_pi_instance = %%PI_ID%%
                order by ID
               