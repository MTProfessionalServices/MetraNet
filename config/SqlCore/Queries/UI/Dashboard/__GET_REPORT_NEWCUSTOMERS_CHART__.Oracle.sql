SELECT c.MetraNetId as Account,
       trunc(c.StartDate,'MON') as "Date"
  FROM Customer c
 WHERE c.StartDate >= add_months(GETUTCDATE(), -13)
   AND c.StartDate <= add_months(GETUTCDATE(), -1)
