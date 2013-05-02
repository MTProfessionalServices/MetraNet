
create global temporary table tmp_newruns (
  id_run_temp INT NOT NULL,
  id_run_parent INT, 
  id_run_child INT,
  tx_type VARCHAR2(14), 
  dt_start DATE)
		