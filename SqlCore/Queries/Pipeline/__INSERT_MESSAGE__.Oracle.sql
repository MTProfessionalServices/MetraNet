begin
insert into t_message (id_message, id_route, dt_crt, dt_metered, dt_assigned, 
  id_listener, id_pipeline, dt_completed, id_feedback, 
  tx_transactionid, tx_sc_username, tx_sc_password, 
  tx_sc_namespace, tx_sc_serialized, tx_ip_address)
    select  %%ID_MESSAGE%%, NULL, %%%SYSTEMDATE%%%, dt_metered, NULL, 
    id_listener, NULL, NULL, id_feedback, 
    tx_TransactionID, tx_sc_username, tx_sc_password, 
    tx_sc_namespace, tx_sc_serialized, tx_ip_address
    from t_message
    where id_message = %%ID_ORIGINAL_MESSAGE%% ;
    
    insert into t_message_mapping(id_message,id_origin_message)  
	 	  values(%%ID_MESSAGE%%,%%ID_ORIGINAL_MESSAGE%%) ;
end; 