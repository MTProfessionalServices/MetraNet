
begin
UPDATE t_message SET dt_completed = %%%SYSTEMDATE%%% WHERE id_message = %%ID_MESSAGE%%;

UPDATE t_session_state 
SET t_session_state.dt_end = %%%SYSTEMDATE%%%
where t_session_state.dt_end = %%MAX_DATE%%
AND exists (select 1 from t_session s,t_session_set ss where s.id_source_sess = t_session_state.id_sess 
AND ss.id_ss=s.id_ss
AND ss.id_message=%%ID_MESSAGE%%);

INSERT INTO t_session_state (id_sess, dt_start, dt_end, tx_state)
SELECT s.id_source_sess, %%%SYSTEMDATE%%%, %%MAX_DATE%%, 'S'
FROM 
t_session s
INNER JOIN t_session_set ss ON ss.id_ss=s.id_ss
WHERE 
ss.id_message = %%ID_MESSAGE%%;

end;
			