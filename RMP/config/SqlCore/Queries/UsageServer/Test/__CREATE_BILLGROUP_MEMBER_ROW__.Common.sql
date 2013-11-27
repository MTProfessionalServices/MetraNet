
/* ===========================================================
Create a row in t_billgroup_member.
============================================================== */
INSERT INTO t_billgroup_member (id_billgroup, 
                                id_acc, 
                                id_materialization, 
                                id_root_billgroup) 
VALUES  
(%%ID_BILLGROUP%%, %%ID_ACC%%, %%ID_MATERIALIZATION%%, NULL)
 