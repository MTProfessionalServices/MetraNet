     
        select dt_change "Date", tx_action "Action", tx_operator "User", 
				tx_comment "Comment", tx_status "Status" from t_batch_history where id_batch= %%ID_BATCH%%
 			