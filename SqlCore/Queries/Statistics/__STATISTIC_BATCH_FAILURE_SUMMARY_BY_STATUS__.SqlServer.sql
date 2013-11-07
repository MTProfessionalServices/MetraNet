
          select 
            count(*) "Total",
            case
              when state = 'N' Then 'Open'
              when state = 'R' Then 'Resubmitted'
              when state = 'U' Then 'Under Investigation'
              when state = 'P' Then 'Pending Deletion'
              when state = 'D' Then 'Deleted' /* No longer valid: Deleted failed trans are removed completely */
              end "State",
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
            group by state,
              fail.n_code,
              fail.tx_errorcodemessage, fail1.tot
            order by "Total" desc
			 