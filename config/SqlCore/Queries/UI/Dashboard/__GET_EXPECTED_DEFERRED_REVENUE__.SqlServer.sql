DECLARE @endDate datetime = CAST(CAST(DATEADD(DAY, 1, %%END_DATE%%)AS DATE) AS DATETIME)

SELECT 
	 acc.am_currency
	,id_usage_interval = CASE
							WHEN udrc.id_usage_interval IS NOT NULL
								THEN udrc.id_usage_interval								
							WHEN frc.id_usage_interval IS NOT NULL
								THEN frc.id_usage_interval
							WHEN nrc.id_usage_interval IS NOT NULL
								THEN nrc.id_usage_interval
							WHEN nsc.id_usage_interval IS NOT NULL
								THEN nsc.id_usage_interval
							WHEN usg_ep.id_prop IS NOT NULL
								THEN acc.id_usage_interval
							WHEN dis_ep.id_prop IS NOT NULL
								THEN acc.id_usage_interval
							WHEN acr.id_usage_interval IS NOT NULL
								THEN acr.id_usage_interval
						 END
	,SubscriptionStart = CASE
							WHEN udrc.c_RCIntervalSubscriptionStart IS NOT NULL
								THEN udrc.c_RCIntervalSubscriptionStart
							WHEN frc.c_RCIntervalSubscriptionStart IS NOT NULL
								THEN frc.c_RCIntervalSubscriptionStart							
							WHEN nrc.c_NRCIntervalSubscriptionStart IS NOT NULL
								THEN nrc.c_NRCIntervalSubscriptionStart
							WHEN nsc.id_usage_interval IS NOT NULL
								THEN nsc.c_IssueTime
							WHEN usg_ep.id_prop IS NOT NULL
								THEN acc.dt_crt	
							WHEN dis_ep.id_prop IS NOT NULL
								THEN acc.dt_crt							
							WHEN acr.c_CreditTime IS NOT NULL
								THEN acr.c_CreditTime
						 END
	,SubscriptionEnd = CASE
							WHEN udrc.c_RCIntervalSubscriptionEnd IS NOT NULL
								THEN udrc.c_RCIntervalSubscriptionEnd
							WHEN frc.c_RCIntervalSubscriptionEnd IS NOT NULL
								THEN frc.c_RCIntervalSubscriptionEnd							
							WHEN nrc.c_NRCIntervalSubscriptionEnd IS NOT NULL
								THEN nrc.c_NRCIntervalSubscriptionEnd
							WHEN nsc.id_usage_interval IS NOT NULL
								THEN nsc.c_IssueTime
							WHEN usg_ep.id_prop IS NOT NULL
								THEN acc.dt_crt	
							WHEN dis_ep.id_prop IS NOT NULL
								THEN acc.dt_crt					
							WHEN acr.c_CreditTime IS NOT NULL
								THEN acr.c_CreditTime
						 END
	,c_ProratedIntervalStart = CASE
								WHEN udrc.c_ProratedIntervalStart IS NOT NULL
									THEN udrc.c_ProratedIntervalStart									
								WHEN frc.c_ProratedIntervalStart IS NOT NULL
									THEN frc.c_ProratedIntervalStart
								END
	,c_ProratedIntervalEnd = CASE
								WHEN udrc.c_ProratedIntervalEnd IS NOT NULL
									THEN udrc.c_ProratedIntervalEnd
								WHEN frc.c_ProratedIntervalEnd IS NOT NULL
									THEN frc.c_ProratedIntervalEnd
								WHEN NULL IS NULL
									THEN NULL
								END
	,c_ProratedDays = CASE 
					WHEN udrc.c_RCIntervalSubscriptionStart > @endDate
						THEN DATEDIFF(DAY, udrc.c_RCIntervalSubscriptionStart, udrc.c_RCIntervalSubscriptionEnd)+1
					WHEN udrc.c_RCIntervalSubscriptionStart <= @endDate
						THEN DATEDIFF(DAY, @endDate, udrc.c_RCIntervalSubscriptionEnd)+1
					WHEN frc.c_RCIntervalSubscriptionStart > @endDate
						THEN DATEDIFF(DAY, frc.c_RCIntervalSubscriptionStart, frc.c_RCIntervalSubscriptionEnd)+1
					WHEN frc.c_RCIntervalSubscriptionStart <= @endDate
						THEN DATEDIFF(DAY, @endDate, frc.c_RCIntervalSubscriptionEnd)+1
					WHEN nrc.c_NRCIntervalSubscriptionStart IS NOT NULL
						THEN 1
					WHEN nsc.c_IssueTime IS NOT NULL
						THEN 1
					WHEN usg_ep.id_prop IS NOT NULL
						THEN 1										
					WHEN acr.id_usage_interval IS NOT NULL
						THEN 1
				END
	,c_ProratedDailyRate = CASE
								WHEN udrc.c_ProratedDailyRate IS NOT NULL
									THEN udrc.c_ProratedDailyRate
								WHEN frc.c_ProratedDailyRate IS NOT NULL
									THEN frc.c_ProratedDailyRate
								WHEN nrc.c_NRCIntervalSubscriptionStart IS NOT NULL
									THEN acc.amount
								WHEN nsc.c_IssueTime IS NOT NULL
									THEN acc.amount
								WHEN usg_ep.id_prop IS NOT NULL
									THEN acc.amount					
								WHEN acr.id_usage_interval IS NOT NULL
									THEN acr.c_CreditAmount
								WHEN dis_ep.id_prop IS NOT NULL
									THEN acc.amount	
								END
	,c_IsLiabilityProduct = CASE
								WHEN udrc_ep.c_IsLiabilityProduct IS NOT NULL
									THEN udrc_ep.c_IsLiabilityProduct
								WHEN frc_ep.c_IsLiabilityProduct IS NOT NULL
									THEN frc_ep.c_IsLiabilityProduct								
								WHEN nrc_ep.c_IsLiabilityProduct IS NOT NULL
									THEN nrc_ep.c_IsLiabilityProduct
								END
	,c_RevenueCode = CASE
								WHEN udrc_ep.c_RevenueCode IS NOT NULL
									THEN udrc_ep.c_RevenueCode
								WHEN frc_ep.c_RevenueCode IS NOT NULL
									THEN frc_ep.c_RevenueCode
								WHEN nrc_ep.c_RevenueCode IS NOT NULL
									THEN nrc_ep.c_RevenueCode
								END
	,c_DeferredRevenueCode = CASE
								WHEN udrc_ep.c_DeferredRevenueCode IS NOT NULL
									THEN udrc_ep.c_DeferredRevenueCode
								WHEN frc_ep.c_DeferredRevenueCode IS NOT NULL
									THEN frc_ep.c_DeferredRevenueCode
								WHEN nrc_ep.c_DeferredRevenueCode IS NOT NULL
									THEN nrc_ep.c_DeferredRevenueCode
								END
	,acc.id_pi_template
FROM t_acc_usage AS acc
LEFT JOIN t_pv_UDRecurringCharge AS udrc ON acc.id_sess =  udrc.id_sess
LEFT JOIN t_pv_FlatRecurringCharge AS frc ON acc.id_sess =  frc.id_sess
LEFT JOIN t_pv_NonRecurringCharge AS nrc ON acc.id_sess =  nrc.id_sess
LEFT JOIN t_pv_NonStandardCharge AS nsc ON acc.id_sess =  nsc.id_sess
LEFT JOIN t_pv_AccountCredit AS acr ON acc.id_sess =  acr.id_sess
INNER JOIN t_usage_interval AS ui ON acc.id_usage_interval = ui.id_interval
LEFT JOIN t_ep_unit_dependent_recurring AS udrc_ep ON udrc_ep.id_prop = acc.id_pi_template
LEFT JOIN t_ep_recurring AS frc_ep ON frc_ep.id_prop = acc.id_pi_template
LEFT JOIN t_ep_nonrecurring AS nrc_ep ON nrc_ep.id_prop = acc.id_pi_template
LEFT JOIN t_ep_usage AS usg_ep ON usg_ep.id_prop = acc.id_pi_template
LEFT JOIN t_ep_discount AS dis_ep ON dis_ep.id_prop = acc.id_pi_template
WHERE
	(acr.c_CreditTime >= @endDate OR nsc.c_IssueTime >= @endDate OR udrc.c_RCIntervalSubscriptionEnd >= @endDate OR frc.c_RCIntervalSubscriptionEnd >= @endDate OR nrc.c_NRCIntervalSubscriptionEnd >= @endDate OR acc.dt_crt >= @endDate)
	AND (acr.id_usage_interval IS NOT NULL OR dis_ep.id_prop IS NOT NULL OR usg_ep.id_prop IS NOT NULL OR nsc.id_usage_interval IS NOT NULL OR udrc_ep.c_IsLiabilityProduct = 'N' OR frc_ep.c_IsLiabilityProduct = 'N' OR nrc_ep.c_IsLiabilityProduct = 'N')
	AND am_currency like '%' + '%%CURRENCY%%' + '%'
	AND (nsc.id_usage_interval IS NOT NULL OR udrc_ep.c_RevenueCode like '%' + '%%REVENUECODE%%' + '%' OR frc_ep.c_RevenueCode like '%' + '%%REVENUECODE%%' + '%' OR nrc_ep.c_RevenueCode like '%' + '%%REVENUECODE%%' + '%')
	AND (nsc.id_usage_interval IS NOT NULL OR udrc_ep.c_DeferredRevenueCode like '%' + '%%DEFREVENUECODE%%' + '%' OR frc_ep.c_DeferredRevenueCode like '%' + '%%DEFREVENUECODE%%' + '%' OR nrc_ep.c_DeferredRevenueCode like '%' + '%%DEFREVENUECODE%%' + '%')
	AND (%%PRODUCTID%% IS NULL OR (%%PRODUCTID%% IS NOT NULL AND id_pi_template = %%PRODUCTID%%))
	AND (NOT EXISTS (select 1 from t_be_sys_rep_accountingcycle)
			OR
			EXISTS (
				SELECT 1
			  FROM t_be_sys_rep_accountingcycle cycl
			  LEFT JOIN t_be_sys_rep_accountingcycl cyclto ON cycl.c_AccountingCycle_Id = cyclto.c_AccountingCycle_Id
			  LEFT JOIN t_account_ancestor tanc ON tanc.id_ancestor = cyclto.c_AccountId or cyclto.c_AccountId is NULL
			  WHERE cycl.c_AccountingCycle_Id like '%%ACCOUNTINGCYCLEID%%'
			  AND tanc.id_descendent = acc.id_payee
			  AND (
						cycl.c_IsDefault = 'T' 
						AND (cyclto.c_AccountId IS NOT NULL
								OR
								(cyclto.c_AccountId IS NULL
									AND
									NOT EXISTS (
											SELECT 1
										  FROM t_be_sys_rep_accountingcycle iNcycl
										  INNER JOIN t_be_sys_rep_accountingcycl iNcyclto ON iNcycl.c_AccountingCycle_Id = iNcyclto.c_AccountingCycle_Id
										  INNER JOIN t_account_ancestor iNtanc ON iNtanc.id_ancestor = iNcyclto.c_AccountId
										  WHERE iNcycl.c_IsDefault = 'F'
										  AND iNtanc.id_descendent = acc.id_payee
										)
								)
								)
						)
		  			OR (cycl.c_IsDefault = 'F' AND cyclto.c_AccountId IS NOT NULL)
		  ))