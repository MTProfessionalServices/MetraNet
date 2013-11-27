

select tcal.c_calendar_id "id" from
	t_rsched
	INNER JOIN t_pl_map pm on pm.id_po = %%ID%% AND id_paramtable is not NULL AND id_sub is NULL
	JOIN t_base_props tbp on tbp.id_prop = pm.id_paramtable
	JOIN t_pt_calendar tcal on tcal.id_sched = t_rsched.id_sched
 where
	t_rsched.id_pt = pm.id_paramtable AND t_rsched.id_pi_template = pm.id_pi_template AND
	t_rsched.id_pricelist = pm.id_pricelist AND
	%%%UPPER%%%(tbp.nm_name) = %%%UPPER%%%(N'metratech.com/calendar')

			