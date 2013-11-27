
			select grm.id_acc, bp.nm_display_name, grm.vt_start, grm.vt_end
			from t_gsub_recur_map grm
			inner join t_base_props bp on grm.id_prop=bp.id_prop
			where grm.id_group=%%ID_GSUB%% and grm.id_prop=%%ID_PROP%% and grm.vt_start <= %%VT_DATE%% and grm.vt_end > %%VT_DATE%% and grm.tt_end = %%VT_MAX%%
		