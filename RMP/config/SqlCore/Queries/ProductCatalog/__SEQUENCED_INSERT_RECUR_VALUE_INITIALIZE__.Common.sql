
insert into t_recur_value(id_prop, id_sub, n_value, vt_start, vt_end, tt_start, tt_end)
/*  __SEQUENCED_INSERT_RECUR_VALUE_INITIALIZE__ */
/*  This is used to insert an initial value for UDRC that is valid for entire period of subscription */
select %%ID_PROP%%, id_sub, %%N_VALUE%%, vt_start, vt_end, %%DT_CURRENT_VALUE%%, %%DT_MAX_VALUE%%
from
t_sub where id_sub=%%ID_SUB%%	
	