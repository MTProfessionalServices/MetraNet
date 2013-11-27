
        select t_rsched.id_sched "id" from
        	t_rsched
	      INNER JOIN t_pl_map pm on pm.id_po = %%ID%% AND id_paramtable is not NULL AND id_sub is NULL
        where
        	t_rsched.id_pt = pm.id_paramtable AND t_rsched.id_pi_template = pm.id_pi_template AND
        	t_rsched.id_pricelist = pm.id_pricelist
			