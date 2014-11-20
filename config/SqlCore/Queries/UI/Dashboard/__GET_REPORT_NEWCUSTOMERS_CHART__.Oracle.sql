SELECT 
      trunc(c.StartDate,'MON') as "Date",
			COUNT(c.MetraNetId) AS CustomerCount			 
FROM Customer c
WHERE c.StartDate >= %%FROM_DATE%% AND c.StartDate < %%TO_DATE%%
GROUP BY trunc(c.StartDate,'MON')

