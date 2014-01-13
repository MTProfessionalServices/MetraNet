
INSERT INTO %%RERUN_TABLE%% 
(id_source_sess, tx_state, id_svc)
SELECT 
  s.id_source_sess,
  'NC',
  ss.id_svc
FROM t_message msg
INNER JOIN t_session_set ss ON ss.id_message = msg.id_message
INNER JOIN t_session s ON s.id_ss = ss.id_ss
WHERE
  msg.dt_assigned IS NOT NULL AND  /* -- the message has been routed */
  msg.dt_completed IS NULL AND     /* -- but not completed */
  msg.id_feedback IS NULL AND      /* -- and wasn't sent synchronously */
  DATEDIFF(s, msg.dt_assigned, %%%SYSTEMDATE%%%) > %%SUSPENDED_DURATION%% AND
  msg.id_message IN (%%MESSAGE_ID_LIST%%) AND
  ss.b_root = '1'  /*-- only inserts the root set, Analyze will figure out the rest */
			