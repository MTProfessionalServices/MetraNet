
 		  insert into %%TABLE_NAME%% (id, id_source_sess, tx_batch, id_sess, 
 		          id_parent_sess, root, id_interval, id_view, tx_state, id_svc, 
 		          id_parent_source_sess, id_payer, amount, currency)
 		  select 
			  seq_%%TABLE_NAME%%.NEXTVAL,
			  au.tx_uid, -- id_source_sess
			  au.tx_batch, -- tx_batch
			  au.id_sess, -- id_sess
			  au.id_parent_sess, -- id_parent_sess,
			  NULL, -- root
			  au.id_usage_interval, -- id_interval
			  au.id_view, -- id_view
			  '%%STATE%%', -- tx_state
			  au.id_svc, -- id_svc
			  NULL, -- id_parent_source_sess
			  au.id_acc, -- id_payer
			  au.amount,
			  au.am_currency
		  from t_acc_usage au
		  %%JOIN_CLAUSE%% 
		  where au.tx_UID not in (select id_source_sess from %%TABLE_NAME%%)
		  %%WHERE_CLAUSE%%  
		  