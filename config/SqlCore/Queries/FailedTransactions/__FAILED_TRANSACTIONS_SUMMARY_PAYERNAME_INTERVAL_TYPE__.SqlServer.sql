
 /* Summary by payer and show interval type */
        select /*TOP 1000*/
             (CASE WHEN id_PossiblePayerID = -1  THEN 'UNKNOWN PAYER' ELSE MAX(hn.hierarchyname) END) as PayerAccountHierarchyName,
            id_PossiblePayerID as PayerID,
            /*MAX(hn2.hierarchyname) as CorporateAccount,*/
            MAX(uc.id_cycle_type) as UsageCycleType,
            MAX(uct.tx_desc) as UsageCycleTypeName,
            (CASE WHEN MAX(uc.id_cycle_type) = 1 THEN MAX(uc.day_of_month) ELSE '' END) as UsageCycleValue,
			COUNT(*) as Count
		from 
		  t_failed_transaction ft
		left join VW_HIERARCHYNAME hn on ft.id_PossiblePayerID = hn.id_acc
		left join t_acc_usage_cycle auc on auc.id_acc = ft.id_PossiblePayerID
		left join t_usage_cycle uc on auc.id_usage_cycle = uc.id_usage_cycle
		left join t_usage_cycle_type uct on uc.id_cycle_type = uct.id_cycle_type
		/*Corporate Account Name*/
		/*left join t_account_ancestor aa on id_PossiblePayerID = aa.id_descendent
		left join VW_HIERARCHYNAME hn2 on aa.id_ancestor = hn2.id_acc
		left join t_account a on aa.id_ancestor = a.id_acc
		left join t_account_type at on at.id_type = a.id_type*/
		where
		  /*at.b_IsCorporate = 1 and*/
		  State in ('N','I', 'C') and  (
                                    (dt_start_resubmit IS NULL) 
                                     OR 
                                    (dt_start_resubmit < CAST ('%%DiffTime%%' as datetime2))
                                   ) 
		group by id_PossiblePayerID
		order by Count desc