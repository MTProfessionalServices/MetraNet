
 
        declare
          myClobVar clob := to_clob(%%TX_SC_SERIALIZED%%);
          begin

            insert into t_message
            (
              id_message, dt_crt, dt_metered, id_listener, id_feedback,
              tx_transactionid, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized,
              tx_ip_address
            ) 
            select
              %%ID_MESSAGE%%, %%%SYSTEMDATE%%%, %%DT_METERED%%, %%ID_LISTENER%%, %%ID_FEEDBACK%%,
              %%TX_TRANSACTIONID%%, %%TX_SC_USERNAME%%, %%TX_SC_PASSWORD%%, %%TX_SC_NAMESPACE%%, myClobVar,
              '%%TX_IP_ADDRESS%%'
            from dual;


          end;        

			