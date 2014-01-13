
      INSERT INTO t_recur_value(id_prop, id_sub, n_value, vt_start, vt_end, tt_start, tt_end) SELECT id_prop, id_sub, n_value, dateadd(s,1,%%VT_END%%) AS vt_start, vt_end, %%DT_CURRENT_VALUE%% AS tt_start, %%DT_MAX_VALUE%% AS tt_end FROM t_recur_value WITH(UPDLOCK) WHERE id_prop = %%ID_PROP%% AND id_sub = %%ID_SUB%% AND vt_start < %%VT_START%% AND vt_end > %%VT_END%% AND tt_end = %%DT_MAX_VALUE%%;
			  /* Transaction table update is an insert and update */
        INSERT INTO t_recur_value(id_prop, id_sub, n_value, vt_start, vt_end, tt_start, tt_end) SELECT id_prop, id_sub, n_value, vt_start, dateadd(s,-1,%%VT_START%%) AS vt_end, %%DT_CURRENT_VALUE%% AS tt_start, %%DT_MAX_VALUE%% AS tt_end FROM t_recur_value WITH(UPDLOCK) WHERE id_prop = %%ID_PROP%% AND id_sub = %%ID_SUB%% AND vt_start < %%VT_START%% AND vt_end >= %%VT_START%% AND tt_end = %%DT_MAX_VALUE%%;
        UPDATE t_recur_value SET tt_end = %%DT_CURRENT_VALUE%% WHERE id_prop = %%ID_PROP%% AND id_sub = %%ID_SUB%% AND vt_start < %%VT_START%% AND vt_end >= %%VT_START%% AND tt_end = %%DT_MAX_VALUE%%;
			  /* Transaction table update is an insert (of the modified existing history into the past history) and update (of the modified existing history) */
        INSERT INTO t_recur_value(id_prop, id_sub, n_value, vt_start, vt_end, tt_start, tt_end) SELECT id_prop, id_sub, n_value, dateadd(s,1,%%VT_END%%) AS vt_start, vt_end, %%DT_CURRENT_VALUE%% AS tt_start, %%DT_MAX_VALUE%% AS tt_end FROM t_recur_value WITH(UPDLOCK) WHERE id_prop = %%ID_PROP%% AND id_sub = %%ID_SUB%% AND vt_start <= %%VT_END%% AND vt_end > %%VT_END%% AND tt_end = %%DT_MAX_VALUE%%;
        UPDATE t_recur_value SET tt_end = %%DT_CURRENT_VALUE%% WHERE id_prop = %%ID_PROP%% AND id_sub = %%ID_SUB%% AND vt_start <= %%VT_END%% AND vt_end > %%VT_END%% AND tt_end = %%DT_MAX_VALUE%%;
        /* Now we delete any interval contained entirely in the interval we are deleting. */
        /* Transaction table delete is really an update of the tt_end */
        /*   [----------------]                 (interval that is being modified) */
        /* [------------------------]           (interval we are deleting) */
        UPDATE t_recur_value SET tt_end = %%DT_CURRENT_VALUE%% WHERE id_prop = %%ID_PROP%% AND id_sub = %%ID_SUB%% AND vt_start >= %%VT_START%% AND vt_end <= %%VT_END%% AND tt_end = %%DT_MAX_VALUE%%;
		