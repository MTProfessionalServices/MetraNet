
update %%TABLE_NAME%% rr
set tx_state = 'S'
where exists (select 1 from t_message msg
inner join t_session_set ss
on msg.id_message = ss.id_message
inner join t_session sess      
on sess.id_ss = ss.id_ss
where sess.id_source_sess = rr.id_source_sess
and msg.id_feedback is not null)

  