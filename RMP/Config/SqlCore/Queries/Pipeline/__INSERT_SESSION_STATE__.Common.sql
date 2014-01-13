
INSERT INTO t_session_state (id_sess, dt_start, dt_end, tx_state) 
SELECT tx_FailureID, dt_FailureTime, %%MAX_DATE%%, 'F' 
FROM %%%NETMETERSTAGE_PREFIX%%%t_failed_session_state_stage %%%READCOMMITTED%%%
      