
INSERT INTO t_recevent_run_details
(
  id_run,
  tx_type,
  tx_detail,
  dt_crt
)
VALUES 
(
  %%ID_RUN%%,
  '%%TX_TYPE%%',
  substring('%%TX_DETAIL%%',1,2000),
  %%%SYSTEMDATE%%%
)
