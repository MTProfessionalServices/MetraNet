
           select 
	             map.id_pricelist priceListID,
	             n_type sharedPriceList,
	             id_pi_instance piInstanceID,
	             id_paramtable paramTableDefID,
	             b_CanICB b_CanICB
            from t_pl_map map
                 inner join t_pricelist pl on map.id_pricelist = pl.id_pricelist
                 where id_pi_instance = %%ID_PI%% and id_paramtable = %%ID_PTD%% and id_sub is null
          