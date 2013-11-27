
/* ===========================================================
Delete a row in t_billgroup_member_tmp.
============================================================== */
DELETE 
FROM t_billgroup_member_tmp
WHERE id_materialization = %%ID_MATERIALIZATION%% AND
      id_acc = %%ID_ACC%%
 