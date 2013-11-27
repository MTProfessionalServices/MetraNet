
SELECT
  tx_type Type,
  tx_detail Detail
FROM t_recevent_run_details
WHERE id_run = %%ID_RUN%%
ORDER BY dt_crt DESC    
		