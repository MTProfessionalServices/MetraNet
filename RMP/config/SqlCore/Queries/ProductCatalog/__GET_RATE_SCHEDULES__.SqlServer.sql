
			   SELECT t_rsched.id_sched
			     FROM t_rsched INNER JOIN t_rulesetdefinition
			        ON t_rsched.id_pt = t_rulesetdefinition.id_paramtable
				where t_rulesetdefinition.nm_instance_tablename='%%TABLE_NAME%%'
			