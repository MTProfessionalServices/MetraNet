
			select
                pl.id_pricelist                 ID,  
                pl.nm_currency_code  Currency,
                bp.nm_name                 Name,
                bp.nm_desc                   Description,
				pl.c_plpartitionId 			 PLPartitionId
              from t_pricelist pl
              inner join t_base_props bp on bp.id_prop = pl.id_pricelist
              where pl.n_type = 1
              