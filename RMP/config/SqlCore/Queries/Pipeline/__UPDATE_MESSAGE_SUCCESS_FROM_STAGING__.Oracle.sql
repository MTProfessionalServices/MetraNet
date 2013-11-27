
begin
UPDATE t_message SET dt_completed = %%%SYSTEMDATE%%% WHERE id_message = %%ID_MESSAGE%%;

UPDATE t_session_state 
SET dt_end = %%%SYSTEMDATE%%% 
WHERE 
EXISTS (
  SELECT 1 FROM %%%NETMETERSTAGE_PREFIX%%%t_resubmit_transaction_stage stg
	WHERE stg.id_sess=t_session_state.id_sess
)
AND
dt_end = %%MAX_DATE%%;

INSERT INTO t_session_state (id_sess, dt_start, dt_end, tx_state)
SELECT stg.id_sess, %%%SYSTEMDATE%%%, %%MAX_DATE%%, 'S'
FROM 
%%%NETMETERSTAGE_PREFIX%%%t_resubmit_transaction_stage stg ;
end;
			