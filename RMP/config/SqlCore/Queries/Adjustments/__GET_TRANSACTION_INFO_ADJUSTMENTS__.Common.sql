
			SELECT 
			tau.*,
			pi.id_pi PITypeID,
      pitype.nm_servicedef,
      pitype.nm_productview
			from VW_AJ_INFO tau
      INNER JOIN t_usage_interval tui on tui.id_interval = tau.id_usage_interval
      INNER JOIN t_pi_template pi on tau.id_pi_template = pi.id_template
      INNER JOIN t_pi pitype ON pitype.id_pi = pi.id_pi
      WHERE tau.id_sess %%PREDICATE%%
		