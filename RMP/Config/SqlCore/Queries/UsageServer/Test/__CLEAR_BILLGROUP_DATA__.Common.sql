
begin
  /* ===========================================================
  Clear data from billing group tables for the given set of intervals.
  ============================================================== */
  /* delete from t_billgroup_member */
  DELETE FROM t_billgroup_member 
  WHERE EXISTS (SELECT 1
                FROM t_billgroup bg 
                INNER JOIN t_usage_interval ui
                  ON ui.id_interval = bg.id_usage_interval
                WHERE bg.id_usage_interval IN (%%INTERVALS%%));
     
  /* delete from t_billgroup_member_history */
  DELETE t_billgroup_member_history
  WHERE EXISTS (SELECT 1 
                FROM t_billgroup_materialization bm
                INNER JOIN t_usage_interval ui
                 ON ui.id_interval = bm.id_usage_interval
                WHERE bm.id_usage_interval IN (%%INTERVALS%%));

  /*  delete from t_billgroup_materialization */
  DELETE FROM t_billgroup_materialization
  WHERE id_usage_interval IN (%%INTERVALS%%);

  /* delete from t_billgroup */
  DELETE FROM t_billgroup
  WHERE id_usage_interval IN (%%INTERVALS%%);
  
  /* delete from t_billgroup_constraint */
  DELETE FROM t_billgroup_constraint
  WHERE id_usage_interval IN (%%INTERVALS%%);
  
  DELETE t_billgroup_source_acc;
  DELETE t_billgroup_member_tmp;
  DELETE t_billgroup_tmp;
  DELETE t_billgroup_constraint_tmp;

end;
 