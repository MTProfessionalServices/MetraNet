
 		insert into %%TABLE_NAME%% (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
 		select 
 		seq_%%TABLE_NAME%%.NEXTVAL,
 		sess.id_source_sess, -- id_source_sess
 		NULL, -- tx_batch
 		NULL, -- id_sess
 		NULL, -- id_parent_sess,
 		NULL, -- root,
 		NULL, -- id_interval
 		NULL, -- id_view,
 		'%%STATE%%', -- tx_state
 		ss.id_svc, -- id_svc,
 		NULL,    -- id_parent_source_sess,
 		NULL,    -- id_payer
 		NULL, -- amount
 		NULL -- currency
    from t_message msg
    inner join t_session_set ss
    on msg.id_message = ss.id_message
    inner join t_session sess
    on ss.id_ss = sess.id_ss
    where sess.id_source_sess not in (select id_source_sess from %%TABLE_NAME%%)
    and ss.b_root = '1'
    %%WHERE_CLAUSE%%
      
  