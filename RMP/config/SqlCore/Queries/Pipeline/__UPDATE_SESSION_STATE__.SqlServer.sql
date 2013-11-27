
UPDATE t_session_state 
SET t_session_state.dt_end = tmp.dt_FailureTime 
FROM t_session_state 
INNER JOIN %%%NETMETERSTAGE_PREFIX%%%t_failed_session_state_stage tmp WITH(READCOMMITTED) ON tmp.tx_FailureID = t_session_state.id_sess 
WHERE t_session_state.dt_end=%%MAX_DATE%%			
      