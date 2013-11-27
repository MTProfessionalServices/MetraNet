
INNER JOIN t_acc_usage
  ON t_acc_usage.id_payee = tmp_2.id_acc AND
     t_acc_usage.dt_session BETWEEN tmp_2.dt_effdisc_start AND tmp_2.dt_effdisc_end
