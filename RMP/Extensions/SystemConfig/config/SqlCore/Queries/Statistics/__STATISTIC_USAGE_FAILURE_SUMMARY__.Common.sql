
          select 
            count(*) "Total", 
            cast(count(*)*100.00/fail1.tot as numeric(5,2)) "Percentage", 
            UPPER(dbo.MTHexFormat(fail.n_code)) "Code", 
            fail.tx_errorcodemessage "Message" 
          from t_failed_transaction fail
          inner join (
                select count(*) tot 
                from t_failed_transaction fail1 
                where fail1.dt_MeteredTime between %%START_TIME%% and %%END_TIME%%
                ) fail1
            on fail.dt_MeteredTime between %%START_TIME%% and %%END_TIME%%
          group by fail.n_code,fail.tx_errorcodemessage, fail1.tot
          order by "Total" desc          
			 