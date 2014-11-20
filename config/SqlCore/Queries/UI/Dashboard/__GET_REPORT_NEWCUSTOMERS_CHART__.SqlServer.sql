SELECT 
       CONVERT(DATE, CONCAT(DATEPART(month, c.StartDate),'-','01','-',DATEPART(year, c.StartDate)), 110) AS [Date],
			 COUNT(c.MetraNetId) AS CustomerCount
  FROM Customer c
 WHERE c.StartDate >= %%FROM_DATE%% AND c.StartDate < %%TO_DATE%%
GROUP BY CONVERT(DATE, CONCAT(DATEPART(month, c.StartDate),'-','01','-',DATEPART(year, c.StartDate)), 110)
