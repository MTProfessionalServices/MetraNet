
          UPDATE t_recevent_run
          SET 
            dt_end = %%%SYSTEMDATE%%%,
            tx_status = '%%TX_STATUS%%',
            tx_detail = %%TX_DETAIL%%
          WHERE id_run = %%ID_RUN%%
        