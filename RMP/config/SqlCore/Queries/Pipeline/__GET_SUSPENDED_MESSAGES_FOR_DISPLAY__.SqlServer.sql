
SELECT 
  msg.id_message 'Message ID',
  msg.dt_metered 'Metered On',
  msg.dt_assigned 'Assigned On',
  pipeline.tx_machine 'Assigned To',
  SUM(ss.session_count) 'Session Count'
FROM t_message msg WITH (READCOMMITTED)
INNER JOIN t_pipeline pipeline WITH (READCOMMITTED) ON pipeline.id_pipeline = msg.id_pipeline
INNER JOIN t_session_set ss WITH (READCOMMITTED) ON ss.id_message = msg.id_message
WHERE
  msg.dt_assigned IS NOT NULL AND  /* -- the message has been routed */
  msg.dt_completed IS NULL AND     /* -- but not completed */
  msg.id_feedback IS NULL AND      /* -- and wasn't sent synchronously */
  DATEDIFF(s, msg.dt_assigned, %%%SYSTEMDATE%%%) > %%SUSPENDED_DURATION%%
GROUP BY msg.id_message, msg.dt_metered, msg.dt_assigned, pipeline.tx_machine
ORDER BY msg.dt_assigned DESC
			