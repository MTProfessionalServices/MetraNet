
        /*Summary by AccountName and Error Type*/
        select
              Rawtohex(Sys_Guid()) As Uniqueid, 
 	            MAX(hn.hierarchyname) as PayerAccountHierarchyName, 
 	            id_PossiblePayerID as PayerID, 
 	            SUBSTR(tx_ErrorMessage, 1, 8) as Error, 
 	            Max(Tx_Errormessage) As Exampleerror, 
 	            COUNT(ft.id_failed_transaction) as Count 
 	        from 
 	             t_failed_transaction ft 
 	        join VW_HIERARCHYNAME hn on ft.id_PossiblePayerID = hn.id_acc 
 	        where 
 	             State in ('N','I', 'C') and (
                                              (dt_start_resubmit IS NULL) 
                                              OR 
                                              (dt_start_resubmit < TO_TIMESTAMP (%%DiffTime%%,'MM/dd/yyyy hh24:mi:ss.ff'))
                                             ) 
       Group By Id_Possiblepayerid, Substr(Tx_Errormessage, 1, 8) 
       
       Union all 
 	      select 
 	            Rawtohex(Sys_Guid()) As Uniqueid, 
 	            N'UNKNOWN' as PayerAccountHierarchyName, 
 	            id_PossiblePayerID as PayerID, 
 	            SUBSTR(tx_ErrorMessage, 1, 8) as Error, 
 	            Max(Tx_Errormessage) As Exampleerror, 
 	            COUNT(ft.id_failed_transaction) as Count 
 	        from 
 	            t_failed_transaction ft 
 	       where 
 	            State In ('N','I', 'C') and (
                                           	  (dt_start_resubmit IS NULL) 
                                               OR 
                                              (dt_start_resubmit < TO_TIMESTAMP (%%DiffTime%%,'MM/dd/yyyy hh24:mi:ss.ff'))
                                            ) 
 	         And Id_Possiblepayerid = -1 
 	    Group By Id_Possiblepayerid, Substr(Tx_Errormessage, 1, 8) 
 	    order by Count DESC  
            