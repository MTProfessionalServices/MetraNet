
        /*Summary by AccountName and Error Type*/
        select
            RAWTOHEX(SYS_GUID()) as UniqueId, 
             (CASE WHEN id_PossiblePayerID = -1  THEN N'UNKNOWN' ELSE MAX(hn.hierarchyname) END) as PayerAccountHierarchyName,
            id_PossiblePayerID as PayerID,
            SUBSTR(tx_ErrorMessage, 1, 8) as Error,
            MAX(tx_ErrorMessage) as ExampleError,
            COUNT(*) as Count
        from 
          t_failed_transaction ft
        left join VW_HIERARCHYNAME hn on ft.id_PossiblePayerID = hn.id_acc
        where 
          State in ('N','I', 'C')
        group by id_PossiblePayerID, SUBSTR(tx_ErrorMessage, 1, 8)
        order by Count desc
            