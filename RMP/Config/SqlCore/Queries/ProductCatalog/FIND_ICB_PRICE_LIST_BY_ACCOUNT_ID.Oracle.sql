
				select t_pricelist.id_pricelist, t_pricelist.n_type, t_pricelist.nm_currency_code,
					t_base_props.nm_name, t_base_props.nm_desc
				from t_av_internal,t_pricelist,t_base_props
				where t_pricelist.id_pricelist = t_av_internal.c_icb_pricelist
				and t_base_props.id_prop = t_pricelist.id_pricelist
				and t_av_internal.id_acc = %%ACC_ID%%
			