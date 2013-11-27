
/* ===========================================================
Returns the number of accounts for the given billing group name and given
materialization from t_billgroup_member_tmp
=========================================================== */
SELECT COUNT(id_acc) NumAccounts
FROM t_billgroup_member_tmp
WHERE id_materialization = %%ID_MATERIALIZATION%% AND
            tx_name = '%%TX_NAME%%'
   