
      INSERT INTO t_recur_value(t_recur_value_id, n_value, vt_start, vt_end) SELECT t_recur_value_id, n_value, %%VT_END%% AS vt_start, vt_end FROM t_recur_value WITH(UPDLOCK) WHERE id_prop=%%ID_PROP%% AND id_sub=%ID_SUB%% AND vt_start < %%VT_END%% AND vt_end > %%VT_END%%;
      INSERT INTO t_recur_value(t_recur_value_id, n_value, vt_start, vt_end) SELECT t_recur_value_id, n_value, vt_start, %%VT_START%% AS vt_end FROM t_recur_value WITH(UPDLOCK) WHERE id_prop=%%ID_PROP%% AND id_sub=%ID_SUB%% AND vt_start < %%VT_START%% AND vt_end > %%VT_START%%;
      UPDATE t_recur_value SET n_value = %%N_VALUE%% WHERE id_prop=%%ID_PROP%% AND id_sub=%ID_SUB%% AND vt_start < %%VT_END%% AND vt_end > %%VT_START%%;
      UPDATE t_recur_value SET vt_end = %%VT_END%% WHERE id_prop=%%ID_PROP%% AND id_sub=%ID_SUB%% AND vt_start < %%VT_END%% AND vt_end > %%VT_END%%;
      UPDATE t_recur_value SET vt_start = %%VT_START%% WHERE id_prop=%%ID_PROP%% AND id_sub=%ID_SUB%% AND vt_start < %%VT_START%% AND vt_end > %%VT_START%%;
		