
UPDATE t_message msg
SET dt_assigned = NULL,
    id_pipeline = NULL 
WHERE 
  msg.dt_assigned IS NOT NULL AND  /* -- the message has been routed */
  msg.dt_completed IS NULL AND     /* -- but not completed */
  msg.id_feedback IS NULL AND      /* -- and wasn't sent synchronously */
  (%%%SYSTEMDATE%%% - msg.dt_assigned) > NUMTODSINTERVAL(%%SUSPENDED_DURATION%%, 'second')
  %%SUSPENDED_NORESUBMIT_FILTER%%
			