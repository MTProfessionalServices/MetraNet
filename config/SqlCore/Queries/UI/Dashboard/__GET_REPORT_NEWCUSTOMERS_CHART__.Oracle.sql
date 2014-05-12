SELECT c.AccountId as Account,
       trunc(st.StartDate,'MON')
  FROM Customer c
       join SubscriptionTable st on c.AccountId = st.AccountId
 WHERE st.StartDate IS NOT NULL
   AND st.StartDate >= add_months(GETUTCDATE(), -13)
   AND st.StartDate <= add_months(GETUTCDATE(), -1)