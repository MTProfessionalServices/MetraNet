
      insert into t_billing_server_settings values
	  (
	      %%GRACE_DAILY_IN_DAYS%%, 
          %%GRACE_BIWEEKLY_IN_DAYS%%, 
          %%GRACE_WEEKLY_IN_DAYS%%, 
          %%GRACE_SEMIMONTHLY_IN_DAYS%%, 
          %%GRACE_MONTHLY_IN_DAYS%%, 
          %%GRACE_QUARTERLY_IN_DAYS%%, 
          %%GRACE_SEMIANNUAL_IN_DAYS%%, 
          %%GRACE_ANNUALLY_IN_DAYS%%, 
          %%IS_GRACE_DAILY_ENABLED%%, 
          %%IS_GRACE_BIWEEKLY_ENABLED%%, 
          %%IS_GRACE_WEEKLY_ENABLED%%, 
          %%IS_GRACE_SEMIMONTHLY_ENABLED%%, 
          %%IS_GRACE_MONTHLY_ENABLED%%, 
          %%IS_GRACE_QUARTERLY_ENABLED%%, 
          %%IS_GRACE_SEMIANNUAL_ENABLED%%, 
          %%IS_GRACE_ANUALLY_ENABLED%%, 
          %%IS_AUTO_RUN_EOP_ENABLED%%, 
          %%IS_AUTO_SOFT_CLOSE_BG_ENABLED%%, 
          %%IS_BLOCK_NEW_ACCOUNTS_ENABLED%%,
          %%IS_RUN_SCHEDULED_ADAPTERS_ENABLED%%,
          '%%MULTICAST_ADDRESS%%', 
          %%MULTICAST_PORT%%, 
          %%MULTICAST_TIME_TO_LIVE%% 
	  )
      