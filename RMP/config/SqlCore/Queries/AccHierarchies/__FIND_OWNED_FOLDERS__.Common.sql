
				select t_impersonate.id_acc, map.nm_login,
				tav.c_billable billable,
        map.displayname,
				tav.c_folder
				from 
				t_impersonate 
				INNER JOIN vw_mps_or_system_acc_mapper map on map.id_acc = t_impersonate.id_acc 
				INNER JOIN t_av_internal tav on tav.id_acc = t_impersonate.id_acc
        Where t_impersonate.id_owner = %%ID_ACC%%
			