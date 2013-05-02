


select  
  /* Do individual subscriptions separately from group subs. */
  /* The ICB case */
  rs.id_sched,  
  rs.dt_mod as dt_modified,  
  rs.id_paramtable,  
  rs.id_pricelist,  
  rs.id_sub,  
  rs.id_po,  
  rs.id_pi_instance,  
  arg.id_request,
	rs.rs_begintype,
	rs.rs_beginoffset,
	rs.rs_beginbase,
	rs.rs_endtype,
	rs.rs_endoffset,
	rs.rs_endbase,
	sub.vt_start as vt_sub_start,
	arg.acc_cycle_id,
	arg.RecordDate 
  from  
  %%TABLE_NAME%% arg with(READCOMMITTED)
  inner join t_sub sub on sub.id_acc=arg.id_acc
  inner join t_vw_allrateschedules_po_icb rs with(noexpand) on rs.id_po = sub.id_po and rs.id_pi_template=arg.id_pi_template and rs.id_sub=sub.id_sub 
  where  
  sub.id_group is null and 
  ((sub.vt_start is null or sub.vt_start <= arg.RecordDate)  
  AND (arg.RecordDate <= sub.vt_end or sub.vt_end is null))  
  union all
select  
  /* Do individual subscriptions separately from group subs. */
  /* The non ICB case */
  rs.id_sched,  
  rs.dt_mod as dt_modified,  
  rs.id_paramtable,  
  rs.id_pricelist,  
  rs.id_sub,  
  rs.id_po,  
  rs.id_pi_instance,  
  arg.id_request, 
	rs.rs_begintype,
	rs.rs_beginoffset,
	rs.rs_beginbase,
	rs.rs_endtype,
	rs.rs_endoffset,
	rs.rs_endbase,
	sub.vt_start as vt_sub_start,
	arg.acc_cycle_id,
	arg.RecordDate 
  from  
  %%TABLE_NAME%% arg with(READCOMMITTED)
  inner join t_sub sub on sub.id_acc=arg.id_acc
  inner join t_vw_allrateschedules_po_noicb rs with(noexpand) on rs.id_po = sub.id_po and rs.id_pi_template=arg.id_pi_template 
  where  
  sub.id_group is null and 
  ((sub.vt_start is null or sub.vt_start <= arg.RecordDate)  
  AND (arg.RecordDate <= sub.vt_end or sub.vt_end is null))  
  union all
  select  
  /* Do group subscriptions separately from individual subs. */
  /* The ICB case */
  rs.id_sched,  
  rs.dt_mod as dt_modified,  
  rs.id_paramtable,  
  rs.id_pricelist,  
  rs.id_sub,  
  rs.id_po,  
  rs.id_pi_instance,  
  arg.id_request, 
	rs.rs_begintype,
	rs.rs_beginoffset,
	rs.rs_beginbase,
	rs.rs_endtype,
	rs.rs_endoffset,
	rs.rs_endbase,
	gsm.vt_start as vt_sub_start,
	arg.acc_cycle_id,
	arg.RecordDate 
  from  
  %%TABLE_NAME%% arg with(READCOMMITTED)
  inner join t_gsubmember gsm on gsm.id_acc=arg.id_acc
  inner join t_sub sub on sub.id_group=gsm.id_group
  inner join t_vw_allrateschedules_po_icb rs with(noexpand) on rs.id_pi_template=arg.id_pi_template and rs.id_po = sub.id_po and rs.id_sub=sub.id_sub
  where  
  ((gsm.vt_start <= arg.RecordDate)  
  AND (arg.RecordDate <= gsm.vt_end))  
  union all
  select  
  /* Do group subscriptions separately from individual subs. */
  /* Non ICB case */
  rs.id_sched,  
  rs.dt_mod as dt_modified,  
  rs.id_paramtable,  
  rs.id_pricelist,  
  rs.id_sub,  
  rs.id_po,  
  rs.id_pi_instance,  
  arg.id_request, 
	rs.rs_begintype,
	rs.rs_beginoffset,
	rs.rs_beginbase,
	rs.rs_endtype,
	rs.rs_endoffset,
	rs.rs_endbase,
	gsm.vt_start as vt_sub_start,
	arg.acc_cycle_id,
	arg.RecordDate 
  from  
  %%TABLE_NAME%% arg with(READCOMMITTED)
  inner join t_gsubmember gsm on gsm.id_acc=arg.id_acc
  inner join t_sub sub on sub.id_group=gsm.id_group
  inner join t_vw_allrateschedules_po_noicb rs with(noexpand) on rs.id_pi_template=arg.id_pi_template and rs.id_po = sub.id_po 
  where  
  ((gsm.vt_start <= arg.RecordDate)  
  AND (arg.RecordDate <= gsm.vt_end))  
  union all 
  select  
  rs.id_sched,  
  rs.dt_mod as dt_modified,  
  rs.id_paramtable,  
  rs.id_pricelist,  
  rs.id_sub,  
  rs.id_po,  
  rs.id_pi_instance,  
  arg.id_request, 
	rs.rs_begintype,
	rs.rs_beginoffset,
	rs.rs_beginbase,
	rs.rs_endtype,
	rs.rs_endoffset,
	rs.rs_endbase,
  cast('2038-01-01' as datetime) as vt_sub_start,
	arg.acc_cycle_id,
	arg.RecordDate
  from  
  %%TABLE_NAME%% arg WITH(READCOMMITTED)  
  inner join t_vw_allrateschedules_pl rs with (noexpand) on rs.id_pi_template=arg.id_pi_template and rs.id_pricelist = arg.default_pl
  option(force order)
  		