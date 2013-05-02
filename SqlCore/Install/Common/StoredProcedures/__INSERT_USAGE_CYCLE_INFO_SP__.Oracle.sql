
      create procedure InsertUsageCycleInfo (p_id_cycle_type IN int,
        p_dom IN int, p_period_type IN char, p_id_usage_cycle OUT int)
      as
      begin
      insert into t_usage_cycle (id_usage_cycle, id_cycle_type, day_of_month,
        tx_period_type) values (seq_t_usage_cycle.NextVal, p_id_cycle_type,
        p_dom, p_period_type);
      if SQL%ROWCOUNT != 1 then
          p_id_usage_cycle := -99;
      end if;
      select seq_t_usage_cycle.CurrVal into p_id_usage_cycle from dual;
      exception
        when others
        then
          p_id_usage_cycle := -99;
      end;
       