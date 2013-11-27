
begin
  /* ===========================================================
  Delete from t_billgroup_member_tmp and t_billgroup_source_acc
  ============================================================== */
  DELETE 
  FROM t_billgroup_member_tmp
  WHERE id_materialization = %%ID_MATERIALIZATION%% AND
        id_acc IN (%%ACCOUNT_LIST%%);
        
  DELETE 
  FROM t_billgroup_source_acc
  WHERE id_materialization = %%ID_MATERIALIZATION%% AND
        id_acc IN (%%ACCOUNT_LIST%%);

end;      
 