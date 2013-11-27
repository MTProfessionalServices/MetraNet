
/* ===========================================================
   Insert all accounts that have ever been a payer at some point in time 
   during the usage interval into the t_billgroup_source_acc table
   =========================================================== */
begin   
INSERT INTO t_billgroup_source_acc (id_materialization, id_acc)
   SELECT  %%ID_MATERIALIZATION%%,
           pa.AccountID
   FROM vw_paying_accounts pa
   WHERE pa.IntervalID = %%ID_INTERVAL%% AND
               pa.State = 'O';
execute immediate 'analyze table t_billgroup_constraint_tmp compute statistics';
execute immediate 'analyze table t_billgroup_source_acc compute statistics';
end;
