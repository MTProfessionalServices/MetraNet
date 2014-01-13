
UPDATE t_message SET dt_completed = %%%SYSTEMDATE%%% WHERE id_message = %%ID_MESSAGE%%

UPDATE t_session_state 
SET t_session_state.dt_end = %%%SYSTEMDATE%%% 
FROM t_session_state 
INNER JOIN t_session s WITH(READCOMMITTED) ON s.id_source_sess = t_session_state.id_sess 
INNER JOIN t_session_set ss WITH(READCOMMITTED) ON ss.id_ss=s.id_ss
WHERE t_session_state.dt_end=%%MAX_DATE%%			
AND
ss.id_message=%%ID_MESSAGE%%

INSERT INTO t_session_state (id_sess, dt_start, dt_end, tx_state)
SELECT s.id_source_sess, %%%SYSTEMDATE%%%, %%MAX_DATE%%, 'S'
FROM 
t_session s WITH(READCOMMITTED) 
INNER JOIN t_session_set ss WITH(READCOMMITTED) ON ss.id_ss=s.id_ss
WHERE 
ss.id_message=%%ID_MESSAGE%%
			