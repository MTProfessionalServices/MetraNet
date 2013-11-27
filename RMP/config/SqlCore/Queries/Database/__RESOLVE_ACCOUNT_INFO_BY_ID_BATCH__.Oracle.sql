
			    SELECT arg.id_request, arg.id_acc, cycle.id_usage_cycle,
					   interval.id_usage_interval, avint.c_pricelist 
					FROM %%TABLE_NAME%% arg
					INNER JOIN t_av_internal avint ON avint.id_acc = arg.id_acc
					INNER JOIN t_acc_usage_cycle cycle ON cycle.id_acc = arg.id_acc
					INNER JOIN t_acc_usage_interval interval ON interval.id_acc = arg.id_acc
					 where interval.dt_effective is null
			