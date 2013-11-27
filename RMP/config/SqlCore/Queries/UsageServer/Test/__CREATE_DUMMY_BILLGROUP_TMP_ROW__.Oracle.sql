
/* ===========================================================
Create a row in t_billgroup_tmp.
============================================================== */
INSERT INTO t_billgroup_tmp 
(id_materialization, tx_name, id_billgroup)
select %%ID_MATERIALIZATION%%, '%%TX_NAME%%', SEQ_T_BILLGROUP_TMP.NextVal from dual
 