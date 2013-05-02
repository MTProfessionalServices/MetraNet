
/* ===========================================================
Delete billing group data
=========================================================== */
create or replace procedure DeleteBillGroupData(p_tablename varchar2) as
v_sql varchar2(4000);
begin

  /* Hold the specified billing group id's in  @billgroups */
  delete from tmp_delete_billgroups;

   /* Insert the billgroup id's in the table specified by @tableName into @billgroups such         that pull lists come first */ 
   v_sql := 'INSERT INTO tmp_delete_billgroups
             SELECT t.id_billgroup, bg.id_usage_interval
             FROM ' || p_tablename || ' t 
             INNER JOIN t_billgroup bg
               ON bg.id_billgroup = t.id_billgroup
             ORDER BY bg.id_parent_billgroup DESC';
  
  execute immediate(v_sql);
  
  DELETE FROM t_billgroup_member bgm
  where exists (
    select 1 from t_billgroup bg
    INNER JOIN tmp_delete_billgroups bgt
      ON bgt.id_billgroup = bg.id_billgroup 
      AND bgt.id_usage_interval = bg.id_usage_interval
    where bg.id_billgroup = bgm.id_billgroup
    );
        
  DELETE FROM t_billgroup_member_history bgmh
  where exists (
    select 1 from t_billgroup bg
    INNER JOIN tmp_delete_billgroups bgt
      ON bgt.id_billgroup = bg.id_billgroup 
      AND bgt.id_usage_interval = bg.id_usage_interval
    where bg.id_billgroup = bgmh.id_billgroup
    );

  DELETE FROM t_billgroup bg 
  where exists (
    select 1 from tmp_delete_billgroups bgt
    where bgt.id_billgroup = bg.id_billgroup 
      AND bgt.id_usage_interval = bg.id_usage_interval
    );

  DELETE FROM t_recevent_run_details rrd 
  where exists (
    select 1 from t_recevent_run rr
    INNER JOIN t_recevent_inst ri ON ri.id_instance = rr.id_instance
    INNER JOIN tmp_delete_billgroups bgt ON bgt.id_billgroup = ri.id_arg_billgroup 
      AND bgt.id_usage_interval = ri.id_arg_interval
    where rr.id_run = rrd.id_run
    );

  DELETE FROM t_recevent_run_batch rrb 
  where exists (
    select 1 from t_recevent_run rr
    INNER JOIN t_recevent_inst ri
      ON ri.id_instance = rr.id_instance
    INNER JOIN tmp_delete_billgroups bgt
      ON bgt.id_billgroup = ri.id_arg_billgroup 
      AND bgt.id_usage_interval = ri.id_arg_interval
    where rr.id_run = rrb.id_run
    );

  DELETE FROM t_recevent_run_failure_acc rrf 
  where exists (
    select 1 from t_recevent_run rr
    INNER JOIN t_recevent_inst ri ON ri.id_instance = rr.id_instance
    INNER JOIN tmp_delete_billgroups bgt 
      ON bgt.id_billgroup = ri.id_arg_billgroup 
      AND bgt.id_usage_interval = ri.id_arg_interval
    where rr.id_run = rrf.id_run
    );

  DELETE FROM t_recevent_run rr 
  where exists (
    select 1 from t_recevent_inst ri
    INNER JOIN tmp_delete_billgroups bgt
      on bgt.id_billgroup = ri.id_arg_billgroup 
      AND bgt.id_usage_interval = ri.id_arg_interval
    where ri.id_instance = rr.id_instance
    );
  
  DELETE FROM t_recevent_inst_audit ria 
  where exists (
    select 1 from t_recevent_inst ri
    INNER JOIN tmp_delete_billgroups bgt 
      ON bgt.id_billgroup = ri.id_arg_billgroup 
      AND bgt.id_usage_interval = ri.id_arg_interval
    where ri.id_instance = ria.id_instance
    );

  DELETE from t_recevent_inst ri 
  where exists (
    select 1 from tmp_delete_billgroups bgt
    where bgt.id_billgroup = ri.id_arg_billgroup 
      AND bgt.id_usage_interval = ri.id_arg_interval
    );

  commit;
end DeleteBillGroupData;
