
update %%TABLE_NAME%%
set tx_state = 'S'
from %%TABLE_NAME%% rr
inner join t_session sess WITH (READCOMMITTED)
on rr.id_source_sess = sess.id_source_sess
inner join t_session_set ss WITH (READCOMMITTED)
on sess.id_ss = ss.id_ss
inner join t_message msg WITH (READCOMMITTED)
on ss.id_message = msg.id_message
where msg.id_feedback is not null
  