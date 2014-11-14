SELECT 
      trunc(c.StartDate,'MON') as "Date",
			COUNT(c.MetraNetId) AS CustomerCount			 
FROM Customer c
WHERE c.StartDate >= add_months(GETUTCDATE(), -13)
   AND c.StartDate <= add_months(GETUTCDATE(), -1)
GROUP BY trunc(c.StartDate,'MON')

