
begin
  /* ===========================================================
  Clear data before starting unit tests.
  ============================================================== */
  /* delete from t_acc_usage_interval */
  DELETE from t_acc_usage_interval
  where exists (
    select 1 
    from t_usage_interval ui  
    INNER JOIN t_usage_cycle uc  
      ON uc.id_usage_cycle = ui.id_usage_cycle  
    INNER JOIN t_usage_cycle_type uct  
      ON uct.id_cycle_type = uc.id_cycle_type  
    where ui.id_interval = t_acc_usage_interval.id_usage_interval
      and (%%USAGE_PREDICATE%%)
    );
        
  /* delete from t_acc_usage */
  DELETE from t_acc_usage
  where exists (
    select 1 
    from t_usage_interval ui  
    INNER JOIN t_usage_cycle uc  
      ON uc.id_usage_cycle = ui.id_usage_cycle  
    INNER JOIN t_usage_cycle_type uct  
      ON uct.id_cycle_type = uc.id_cycle_type  
    where ui.id_interval = t_acc_usage.id_usage_interval
      and (%%USAGE_PREDICATE%%)
    );

  /* delete from t_svc_testservice */
  DELETE from t_svc_testservice
  where exists (
    select 1 
    from t_usage_interval ui  
    INNER JOIN t_usage_cycle uc  
      ON uc.id_usage_cycle = ui.id_usage_cycle  
    INNER JOIN t_usage_cycle_type uct  
      ON uct.id_cycle_type = uc.id_cycle_type  
    where ui.id_interval = t_svc_testservice.c__intervalID  
      and (%%USAGE_PREDICATE%%)
    );

  /* delete from t_billgroup_member */
  DELETE from t_billgroup_member
  where exists (
    select 1
    from t_billgroup bg 
    INNER JOIN t_usage_interval ui
      ON ui.id_interval = bg.id_usage_interval
    where bg.id_billgroup = t_billgroup_member.id_billgroup
      and (%%BILLING_GROUP_PREDICATE%%)
    );
     
  /* delete from t_billgroup_member_history */
  DELETE t_billgroup_member_history
  where exists (
    select 1 
    from t_billgroup_materialization bm
    INNER JOIN t_usage_interval ui
      ON ui.id_interval = bm.id_usage_interval
    where bm.id_materialization = t_billgroup_member_history.id_materialization
      and (%%BILLING_GROUP_PREDICATE%%)
    );

  /*  delete from t_billgroup_materialization */
  DELETE from t_billgroup_materialization
  where exists (
    select 1 
    from t_usage_interval ui
    where ui.id_interval = t_billgroup_materialization.id_usage_interval
      and (%%BILLING_GROUP_PREDICATE%%)
    );

  /* delete from t_billgroup */
  DELETE from t_billgroup
  where exists (
    select 1
    from t_usage_interval ui
    where ui.id_interval = t_billgroup.id_usage_interval
      and (%%BILLING_GROUP_PREDICATE%%)
    );
  
  DELETE t_billgroup_source_acc;
  DELETE t_billgroup_member_tmp;
  DELETE t_billgroup_tmp;

end;
 