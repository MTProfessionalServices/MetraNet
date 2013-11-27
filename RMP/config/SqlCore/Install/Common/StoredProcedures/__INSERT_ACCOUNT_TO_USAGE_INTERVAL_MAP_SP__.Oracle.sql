
      create procedure InsertAcctToIntervalMapping
        (p_id_acc IN int, p_id_interval IN int)
      as
      v_id_acc number(10);
      begin
      v_id_acc := 0;
      select id_acc into v_id_acc from t_acc_usage_interval
        where id_acc = p_id_acc and id_usage_interval = p_id_interval;
      exception
        when NO_DATA_FOUND
        then
          insert into t_acc_usage_interval (id_acc, id_usage_interval, tx_status)
                                        values (p_id_acc, p_id_interval, 'O') ;
      end;
       