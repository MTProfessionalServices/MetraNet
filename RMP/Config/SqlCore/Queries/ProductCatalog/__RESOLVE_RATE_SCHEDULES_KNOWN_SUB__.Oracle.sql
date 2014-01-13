
		select  
		/* __RESOLVE_RATE_SCHEDULES_KNOWN_SUB__ */
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
		%%TABLE_NAME%% arg 
		inner join t_vw_allrateschedules_po rs on rs.id_pi_template=arg.id_pi_template 
		inner join t_sub sub on rs.id_po = sub.id_po and sub.id_sub = arg.id_sub
		where   
		/* Rate schedule is either non-ICB or is ICB on the correct subscription */
		(rs.id_sub is null or rs.id_sub = sub.id_sub) 
		AND arg.RecordDate  
		BETWEEN  
		nvl(dbo.MTComputeEffectiveBeginDate(rs.rs_begintype, rs.rs_beginoffset,rs.rs_beginbase, sub.vt_start, arg.acc_cycle_id),
		       to_date('1900-01-01','yyyy-mm-dd'))  
		AND  
	        nvl(dbo.MTComputeEffectiveEndDate(rs.rs_endtype, rs.rs_endoffset, rs.rs_endbase, sub.vt_start, arg.acc_cycle_id),
		       to_date('2036-01-01','yyyy-mm-dd'))
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
      to_date('2038-01-01','yyyy-mm-dd') as vt_sub_start,
      arg.acc_cycle_id,
      arg.RecordDate
      from  
      %%TABLE_NAME%% arg  
      inner join t_vw_allrateschedules_pl rs 
          on rs.id_pi_template = arg.id_pi_template 
          and rs.id_pricelist = arg.default_pl 
    