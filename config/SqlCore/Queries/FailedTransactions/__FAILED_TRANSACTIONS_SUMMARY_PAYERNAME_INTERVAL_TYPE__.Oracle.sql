
 /* Summary by payer and show interval type */
        select /*TOP 1000*/
            MAX(hn.hierarchyname) as PayerAccountHierarchyName,  
            id_PossiblePayerID as PayerID,
            /*MAX(hn2.hierarchyname) as CorporateAccount,*/
            MAX(uc.id_cycle_type) as UsageCycleType,
            MAX(uct.tx_desc) as UsageCycleTypeName,
            (CASE WHEN MAX(uc.id_cycle_type) = 1 THEN MAX(uc.day_of_month) ELSE NULL END) as UsageCycleValue,
            COUNT(*) as Count
        from 
          t_failed_transaction ft
         inner join VW_HIERARCHYNAME hn on ft.id_PossiblePayerID = hn.id_acc 
         inner join t_acc_usage_cycle auc on auc.id_acc = ft.id_PossiblePayerID 
         inner join t_usage_cycle uc on auc.id_usage_cycle = uc.id_usage_cycle 
         inner join t_usage_cycle_type uct on uc.id_cycle_type = uct.id_cycle_type  
        where
          /*at.b_IsCorporate = 1 and*/
          State in ('N','I', 'C') and  (
                                        (dt_start_resubmit IS NULL) 
                                        OR 
                                        (dt_start_resubmit < TO_TIMESTAMP ('%%DiffTime%%','MM/dd/yyyy hh24:mi:ss.ff'))
                                        ) 
        group by id_PossiblePayerID
   union all 
 	      select /*TOP 1000*/ 
	            N'UNKNOWN' as PayerAccountHierarchyName, 
	            id_PossiblePayerID as PayerID, 
	            null as UsageCycleType, 
	            NULL as UsageCycleTypeName, 
 	            NULL as UsageCycleValue, 
 	            COUNT(*) as Count 
 	        from  
 	          t_failed_transaction ft 
 	        where 
 	          /*at.b_IsCorporate = 1 and*/ 
 	          State in ('N','I', 'C') and (
                                          	(dt_start_resubmit IS NULL) 
                                          	OR 
                                          	(dt_start_resubmit < TO_TIMESTAMP ('%%DiffTime%%','MM/dd/yyyy hh24:mi:ss.ff'))
                                          )
 	           And Id_Possiblepayerid = -1 
 	        group by id_PossiblePayerID 
 	        order by Count DESC     