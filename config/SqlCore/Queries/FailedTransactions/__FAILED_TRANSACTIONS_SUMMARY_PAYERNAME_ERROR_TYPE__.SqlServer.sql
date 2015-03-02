
        /*Summary by AccountName and Error Type*/
        select
			NEWID() as UniqueId, 
             (CASE WHEN id_PossiblePayerID = -1  THEN 'UNKNOWN' ELSE MAX(hn.hierarchyname) END) as PayerAccountHierarchyName,
            id_PossiblePayerID as PayerID,
			LEFT(tx_ErrorMessage, 8) as Error,
			MAX(tx_ErrorMessage) as ExampleError,
			COUNT(*) as Count
		from 
		  t_failed_transaction ft
		left join VW_HIERARCHYNAME hn on ft.id_PossiblePayerID = hn.id_acc
		  
		where 
		  State in ('N','I', 'C') and (
                                   (dt_start_resubmit IS NULL) 
                                   OR 
                                   (dt_start_resubmit < CAST ('%%DiffTime%%' as datetime2))
                                  ) 
		group by id_PossiblePayerID, LEFT(tx_ErrorMessage, 8)
		order by Count desc