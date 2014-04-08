
			select distinct(ns.tx_desc) BrandedSite from t_account_mapper map
      inner join t_localized_site ls on lower(ls.nm_space) = lower(map.nm_space)
      inner join t_namespace ns on lower(map.nm_space) = lower(ns.nm_space)
      where map.id_acc =  %%ACCOUNT_ID%%

			