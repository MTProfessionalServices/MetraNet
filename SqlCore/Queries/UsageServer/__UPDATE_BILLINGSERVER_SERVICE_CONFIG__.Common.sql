
UPDATE t_billingserver 
  SET n_MaxConcurrentAdapters = %%MaxConcurrentAdapters%%,
      b_OnlyRunAssignedAdapters = '%%OnlyRunAssignedAdapters%%',
      n_ProcessEventsPeriod = %%ProcessEventsPeriod%%
  WHERE tx_machine like '%%TX_MACHINE%%'
			