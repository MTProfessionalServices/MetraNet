/* For a given account, what are the Analytics we want to show as a summary from the SalesSummary datamart */
/* TBD: MRR */
/*select id_acc, SUM(invoice_amount) as LTV, MAX(invoice_currency) as LTVCurrency, 1234.56 as MRR, 'USD' as 'MRRCurrency', 1012.34 as MRRPrevious from t_invoice
where id_acc = %%ACCOUNT_ID%%
group by id_acc


subscription datamart not ready and lack of data thus hardcoding wht is returned.
SELECT SUM(subSum.SubscriptionRevenue) as LTV ,SUM(subSum.MRR) as MRR,subSum.MRRBasePrimaryCurrency as 'Currency'
 FROM SubscriptionSummary subSum

*/




select %%ACCOUNT_ID%% as id_acc, 
				1313.55 as LTV, 
				1234.56 as MRR, 
				'USD' as Currency
/* When start use %%%NETMETERSTAGE_PREFIX%%% prefixes  (for detail see R:\config\SqlCore\Queries\ProductView\__DROP_PRODUCT_VIEW_STAGE_TABLE__.Oracle.sql)
*  the query should be move to COMMON
*/				
FROM SubscriptionDataMart..SubscriptionSummary

