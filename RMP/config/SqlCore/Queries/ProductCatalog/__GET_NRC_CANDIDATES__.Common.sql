
%%INSERT_INTO_CLAUSE%%
select 
/* __GET_NRC_CANDIDATES__ */
nrc.id_prop,
nrc.n_event_type,
plm.id_pi_instance,
plm.id_pi_template,
plm.id_po,
gsm.id_acc,
gsm.id_sub,
gsm.position,
gsm.vt_start,
gsm.vt_end,
gsm.tt_start,
gsm.tt_end,
gsm.max_vt_tt_start,
gsm.max_vt_tt_end,
rei.dt_arg_start,
rei.dt_arg_end
%%INTO_CLAUSE%%
from 
t_nonrecur nrc
inner join t_pl_map plm on nrc.id_prop=plm.id_pi_instance
inner join %%%TEMP_TABLE_PREFIX%%%tmp_nrc_gsubmember gsm on plm.id_po=gsm.id_po
inner join t_recevent re on gsm.max_vt_tt_start >= re.dt_activated and gsm.max_vt_tt_start <= {fn IFNULL(re.dt_deactivated, {ts '2038-01-01 00:00:00'})}
inner join t_recevent_inst rei on rei.id_event = re.id_event and gsm.max_vt_tt_start >= rei.dt_arg_start and gsm.max_vt_tt_start <= rei.dt_arg_end
where
plm.id_paramtable is null
and
re.tx_name = 'NonRecurringCharges'
and
id_pi_type=%%TYPEID%%
  		