/* Subscription table is not implemented yet, so the query was commented out*/
/*       st.FeeCurrency as CurrencyCode,
       SUM(sm.MRRBase + sm.MRRNew + sm.MRRRenewal + sm.MRRPriceChange + sm.MRRChurn + sm.MRRCancellation) as Amount
FROM SubscriptionsByMonth sm
		join Subscription st on sm.SubscriptionId = st.SubscriptionId
		join Customer c on st.AccountId = c.AccountId
WHERE sm.Month IS NOT NULL
AND sm.Month >= add_months(GETUTCDATE(), -13)
AND sm.Month < trunc(add_months(GETUTCDATE(), 12),'MON')
GROUP BY trunc(sm.Month,'MON'), st.FeeCurrency*/
