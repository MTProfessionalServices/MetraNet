     
        select tx_type "DetailType", tx_detail "Detail", dt_crt "Timestamp" from t_recevent_run_details 
				where id_run = %%ID_RUN%%   
 			