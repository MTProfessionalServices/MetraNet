
/* ===========================================================
Clear data before starting unit tests.
============================================================== */
/* delete t_recevent_run_details */
begin

delete from t_recevent_run_details
where id_run in (
 select rrd.id_run
  FROM t_recevent_run_details rrd
  INNER JOIN t_recevent_run rr
    ON rr.id_run = rrd.id_run
  INNER JOIN t_recevent_inst ri
    ON ri.id_instance = rr.id_instance
  WHERE ri.id_arg_interval IN (%%INTERVALS%%));
  

/* delete t_recevent_run_batch  */
delete from t_recevent_run_batch
where id_run in (
  select rrb.id_run 
  FROM t_recevent_run_batch rrb
  INNER JOIN t_recevent_run rr
    ON rr.id_run = rrb.id_run
  INNER JOIN t_recevent_inst ri
    ON ri.id_instance = rr.id_instance
  WHERE ri.id_arg_interval IN (%%INTERVALS%%));
      
  /* delete t_recevent_run_failure_acc */
  DELETE from t_recevent_run_failure_acc
  where id_run in (
  select rrf.id_run
  FROM t_recevent_run_failure_acc rrf
  INNER JOIN t_recevent_run rr
    ON rr.id_run = rrf.id_run
  INNER JOIN t_recevent_inst ri
    ON ri.id_instance = rr.id_instance
  WHERE ri.id_arg_interval IN (%%INTERVALS%%));
             
  /* delete t_recevent_run */
  DELETE from t_recevent_run 
  where id_instance in (
  select rr.id_instance
  FROM t_recevent_run rr
  INNER JOIN t_recevent_inst ri
    ON ri.id_instance = rr.id_instance
  WHERE ri.id_arg_interval IN (%%INTERVALS%%));
             
  /* delete t_recevent_inst_audit */
  DELETE from t_recevent_inst_audit
  where id_instance in (
  select ria.id_instance
  FROM t_recevent_inst_audit ria
  INNER JOIN t_recevent_inst ri
    ON ri.id_instance = ria.id_instance
  WHERE ri.id_arg_interval IN (%%INTERVALS%%));
             
  /* delete t_recevent_inst */
  DELETE from t_recevent_inst
  WHERE id_arg_interval IN (%%INTERVALS%%);

end;
 