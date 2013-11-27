
/* ===========================================================
Returns the given id_billgroup if it exists in t_recevent_inst
=========================================================== */
SELECT id_arg_billgroup
FROM t_recevent_inst
WHERE id_arg_billgroup = %%ID_BILLGROUP%% 
GROUP BY id_arg_billgroup   
   