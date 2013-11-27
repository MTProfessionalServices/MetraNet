
SELECT 
  s.id_ss,
  s.id_source_sess,
  svc.id_parent_source_sess,
  svc.id_external,
  m.dt_metered,
  m.tx_transactionid,
  m.tx_sc_username,
  m.tx_sc_password,
  m.tx_sc_namespace,
  m.tx_sc_serialized,
  svc.c__CollectionID,
  m.tx_ip_address,
  %%SVC_COLUMNS%%
FROM t_session_set ss
/* removed "inner LOOP join".  sqlserver specific; */
INNER JOIN t_message m ON m.id_message = ss.id_message
INNER JOIN t_session s ON s.id_ss = ss.id_ss
INNER JOIN %%SVC_TABLE%% svc ON s.id_source_sess = svc.id_source_sess
WHERE m.id_message = %%ID_MESSAGE%%
			