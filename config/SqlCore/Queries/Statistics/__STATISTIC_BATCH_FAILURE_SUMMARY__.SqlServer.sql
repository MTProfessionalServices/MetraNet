
            select 
              count(*) "Total",
              cast(count(*)*100.00/fail1.tot as numeric(5,2)) "Percentage",
              UPPER(dbo.MTHexFormat(fail.n_code)) "Code",
              fail.tx_errorcodemessage "Message"
            from t_failed_transaction fail 
            inner join t_batch batch on fail.tx_batch_encoded = batch.tx_batch_encoded 
            inner join (
                  select tx_batch_encoded, count(*) tot 
                  from t_failed_transaction fail1 
                  group by tx_batch_encoded
                  ) fail1 
              on fail.tx_batch_encoded = fail1.tx_batch_encoded
            where fail.tx_batch = %%ID_BATCH%%
            group by fail.n_code,fail.tx_errorcodemessage,fail1.tot
            order by "Total" desc
			 