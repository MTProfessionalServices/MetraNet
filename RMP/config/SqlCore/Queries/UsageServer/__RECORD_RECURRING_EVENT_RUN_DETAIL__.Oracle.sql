
INSERT INTO t_recevent_run_details
( 
  id_detail,
  id_run,
  tx_type,
  tx_detail,
  dt_crt
)
VALUES 
(seq_t_recevent_run_details.nextval,
  %%ID_RUN%%,
  '%%TX_TYPE%%',
  substr('%%TX_DETAIL%%',1,2000),
  %%%SYSTEMDATE%%%
)
