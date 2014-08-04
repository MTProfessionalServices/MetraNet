select 1 from dual
/* The above query has be removed once we have Subscription table implemented*/
/* Subscription table is not implemented yet, so the query was commented out*/
/*SELECT c.AccountId as Account,
       trunc(st.StartDate,'MON')
  FROM Customer c
       join Subscription st on c.AccountId = st.AccountId
 WHERE st.StartDate IS NOT NULL
   AND st.StartDate >= add_months(GETUTCDATE(), -13)
   AND st.StartDate <= add_months(GETUTCDATE(), -1)*/