
UPDATE t_message 
SET dt_assigned = NULL,
    id_pipeline = NULL 
FROM t_message msg
WHERE 
  msg.dt_assigned IS NOT NULL AND  /* -- the message has been routed */
  msg.dt_completed IS NULL AND     /* -- but not completed */
  msg.id_feedback IS NULL AND      /* -- and wasn't sent synchronously */
  DATEDIFF(s, msg.dt_assigned, %%%SYSTEMDATE%%%) > %%SUSPENDED_DURATION%%
  %%SUSPENDED_NORESUBMIT_FILTER%%

/*SELECT @@rowcount*/
			