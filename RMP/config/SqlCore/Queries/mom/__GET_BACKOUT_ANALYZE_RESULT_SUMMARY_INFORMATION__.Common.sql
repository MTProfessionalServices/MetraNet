  
				select 
          count(case when (tx_state = 'A') then 1 else null end) DatabaseSessionsToBackout,
          count(case when (tx_state = 'C') then 1 else null end) SessionsInHardClosedIntervals,
          count(case when (tx_state = 'E') then 1 else null end) FailedTransactionsToBackout,
          count(case when (tx_state = 'N') then 1 else null end) TransactionsVetoedByAdapters,
          count(case when (tx_state = 'S') then 1 else null end) TransactionsMarkedSynchronous
          from %%TABLE_NAME%%         
				