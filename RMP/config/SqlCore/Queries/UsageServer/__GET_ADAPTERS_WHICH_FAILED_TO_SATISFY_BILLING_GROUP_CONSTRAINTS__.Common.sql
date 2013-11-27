
/* ===========================================================
Returns the adapter names for those adapters which failed to satisfy the billing group
constraints for the billing group assignments in t_billgroup_member_tmp 
for the given id_materialization
=========================================================== */
SELECT DISTINCT(re.tx_name) AdapterName           
FROM t_billgroup_member_tmp bgmt
INNER JOIN t_recevent re 
  ON re.id_event = bgmt.id_event
WHERE bgmt.id_materialization = %%ID_MATERIALIZATION%%
ORDER BY re.tx_name
   