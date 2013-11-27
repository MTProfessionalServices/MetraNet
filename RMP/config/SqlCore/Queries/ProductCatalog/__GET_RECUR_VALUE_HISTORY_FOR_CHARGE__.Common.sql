
			select rv.id_prop, rv.id_sub, rv.n_value, r.nm_unit_name, rv.vt_start, rv.vt_end
			from t_recur_value rv inner join t_recur r on rv.id_prop=r.id_prop
			where rv.id_sub = %%ID_SUB%% AND rv.id_prop=%%ID_PROP%% AND rv.tt_end = %%DT_MAX_VALUE%%
			order by rv.id_prop, rv.vt_start
		