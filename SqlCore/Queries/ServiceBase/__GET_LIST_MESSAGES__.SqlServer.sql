
               WITH ls_messages (id) 
 	               AS  
 	                 (SELECT DISTINCT id_origin_message 
 	                    FROM t_message_mapping %%LOCK%% 
 	                   WHERE id_origin_message in (%%ID_MESSAGES%%) 
 	                  UNION ALL  
 	                  SELECT id_message  
 	                    FROM t_message_mapping AS mm %%LOCK%%  
 	              INNER JOIN ls_messages AS ls  
 	                      ON ls.id = mm.id_origin_message) 
 	             SELECT * 
 	         FROM ls_messages   
        