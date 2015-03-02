
		/*Summary by Error Type with Max, Average and Min age in days*/
        select
			LEFT(tx_ErrorMessage, 8) as Error,
			MAX(tx_ErrorMessage) as ExampleError,
			COUNT(*) as Count,
			MAX(DATEDIFF(DAY, dt_MeteredTime, GETDATE())) as MaxAge,
			AVG(DATEDIFF(DAY, dt_MeteredTime, GETDATE())) as AverageAge,
			MIN(DATEDIFF(DAY, dt_MeteredTime, GETDATE())) as MinAge
		from 
		  t_failed_transaction 
		where 
		  State in ('N','I', 'C') and  (
                                     (dt_start_resubmit IS NULL) 
                                      OR 
                                     (dt_start_resubmit < CAST ('%%DiffTime%%' as datetime2))
                                    )
		group by LEFT(tx_ErrorMessage, 8)
		order by Count desc