     
        select tx_type "Type", dt_start "Start", dt_end "End", tx_status "Status", tx_detail "Details", tx_machine "Machine",
          (select count(*) from t_recevent_run_batch where id_run=%%ID_RUN%%) "BatchCount"
        from t_recevent_run where id_run= %%ID_RUN%%
 			