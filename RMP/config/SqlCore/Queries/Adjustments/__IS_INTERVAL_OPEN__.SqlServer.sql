
			 SELECT CASE WHEN (dbo.IsIntervalOpen(%%ID_ACC%%, %%INTERVAL_ID%%) = 1)
			 THEN 'Y' ELSE 'N' END AS IsIntervalOpen
			