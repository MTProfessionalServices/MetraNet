
/* ===========================================================
Create a row in t_billgroup.
============================================================== */
INSERT INTO t_billgroup (id_billgroup, 
                         tx_name, 
                         tx_description, 
                         id_usage_interval, 
                         id_parent_billgroup, 
                         tx_type) 
VALUES  
(%%ID_BILLGROUP%%, '%%NAME%%', '%%DESCRIPTION%%', %%ID_USAGE_INTERVAL%%, NULL, 'Full')
 