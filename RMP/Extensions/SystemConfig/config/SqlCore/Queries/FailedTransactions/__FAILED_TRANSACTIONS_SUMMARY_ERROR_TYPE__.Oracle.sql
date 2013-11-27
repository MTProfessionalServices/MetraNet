
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
          State in ('N','I', 'C')
        group by SUBSTR(tx_ErrorMessage, 1, 8)
        order by Count desc            
            