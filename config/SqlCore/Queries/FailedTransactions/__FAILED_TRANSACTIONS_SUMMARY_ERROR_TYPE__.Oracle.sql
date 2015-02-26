
        /*Summary by Error Type with Max, Average and Min age in days*/
        select
            SUBSTR(tx_ErrorMessage, 1, 8) as Error,
            MAX(tx_ErrorMessage) as ExampleError,
            COUNT(*) as Count,
            FLOOR(MAX(SYSDATE - dt_MeteredTime)) as MaxAge,
            FLOOR(AVG(SYSDATE - dt_MeteredTime)) as AverageAge,
            FLOOR(MIN(SYSDATE - dt_MeteredTime)) as MinAge
        from 
          t_failed_transaction 
        where 
          State in ('N','I', 'C') and  (
                                         (dt_start_resubmit IS NULL) 
                                         OR 
                                         (dt_start_resubmit < TO_TIMESTAMP ('%%DiffTime%%','MM/dd/yyyy hh24:mi:ss.ff'))
                                        )
        group by SUBSTR(tx_ErrorMessage, 1, 8)
        order by Count desc            
            