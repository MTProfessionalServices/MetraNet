
SELECT 
  msg.id_message "Message ID",
  msg.dt_metered "Metered On",
  msg.dt_assigned "Assigned On",
  pipeline.tx_machine "Assigned To",
  SUM(ss.session_count) "Session Count"
FROM t_message msg
INNER JOIN t_pipeline pipeline ON pipeline.id_pipeline = msg.id_pipeline
INNER JOIN t_session_set ss ON ss.id_message = msg.id_message
WHERE
  msg.dt_assigned IS NOT NULL AND  /* -- the message has been routed */
  msg.dt_completed IS NULL AND     /* -- but not completed */
  msg.id_feedback IS NULL AND      /* -- and wasn't sent synchronously */
 (%%%SYSTEMDATE%%% - msg.dt_assigned) > NUMTODSINTERVAL(%%SUSPENDED_DURATION%%, 'second')
GROUP BY msg.id_message, msg.dt_metered, msg.dt_assigned, pipeline.tx_machine
ORDER BY msg.dt_assigned DESC
			