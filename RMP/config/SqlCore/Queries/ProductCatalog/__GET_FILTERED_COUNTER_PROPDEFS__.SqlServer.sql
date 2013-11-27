
					SELECT 
						cpd.id_prop, cpd.id_pi, bp.nm_name, td.tx_desc as 'nm_display_name',
						cpd.nm_servicedefprop, cpd.nm_preferredcountertype, cpd.n_order
					FROM t_counterpropdef cpd, t_description td, t_base_props bp
					WHERE 
						cpd.id_prop = bp.id_prop AND
						bp.n_display_name = td.id_desc AND
						td.id_lang_code = %%ID_LANG%%
						%%FILTERS%%
			 