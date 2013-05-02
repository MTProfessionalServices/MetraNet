
			begin
			
			/* ESR-6006 update the t_mv_payer_interval with the latest t_dm_account.id_dm_acc row   */
			update t_mv_payer_interval
        set (id_dm_acc) = ( select new_id_dm_acc
                            from (select a.id_acc, a.id_dm_acc, b.id_usage_interval, max(d.id_dm_acc) new_id_dm_acc
                                    from ( /* the missing list of id_dm_acc from t_mv_payer_interval */
                                    select distinct b.id_acc, b.id_dm_acc
                                            from t_mv_payer_interval b
                                              where not exists (select 1 from t_dm_account a where a.id_dm_acc = b.id_dm_acc)
                                          ) a
                            inner join t_mv_payer_interval b on a.id_acc = b.id_acc and a.id_dm_acc = b.id_dm_acc
                            inner join t_usage_interval c on b.id_usage_interval = c.id_interval
                            inner join t_dm_account d on b.id_se = d.id_acc and c.dt_start < d.vt_end and c.dt_end > d.vt_start
                            group by a.id_acc, a.id_dm_acc, b.id_usage_interval
                          ) b
      where t_mv_payer_interval.id_acc = b.id_acc
        and t_mv_payer_interval.id_dm_acc = b.id_dm_acc
        and t_mv_payer_interval.id_usage_interval = b.id_usage_interval);


			/* ESR-6006 update the t_mv_payee_session with the latest t_dm_account.id_dm_acc row   */ 
      update t_mv_payee_session
        set (id_dm_acc) = (select new_id_dm_acc
                            from (select a.id_acc, a.id_dm_acc, min(d.vt_start) vt_start, max(d.vt_end) vt_end, max(d.id_dm_acc) new_id_dm_acc
                                    from ( /* the missing list of id_dm_acc from t_mv_payer_interval */
                                    select distinct b.id_acc, b.id_dm_acc
                                      from t_mv_payee_session b
                                         where not exists (select 1 from t_dm_account a where a.id_dm_acc = b.id_dm_acc)
                                  ) a
                            inner join t_mv_payee_session b on a.id_acc = b.id_acc and a.id_dm_acc = b.id_dm_acc
                            inner join t_dm_account d on b.id_se = d.id_acc and b.dt_session < d.vt_end and b.dt_session > d.vt_start
                            group by a.id_acc, a.id_dm_acc
                          ) b
      where t_mv_payee_session.id_acc = b.id_acc
        and t_mv_payee_session.id_dm_acc = b.id_dm_acc
        and t_mv_payee_session.dt_session > b.vt_start
        and t_mv_payee_session.dt_session < b.vt_end);			
        			
			end;
		