
      UPDATE t_billing_server_settings
	  SET
	      grace_daily_in_days=%%GRACE_DAILY_IN_DAYS%%, 
          grace_biweekly_in_days=%%GRACE_BIWEEKLY_IN_DAYS%%, 
          grace_weekly_in_days=%%GRACE_WEEKLY_IN_DAYS%%, 
          grace_semimonthly_in_days=%%GRACE_SEMIMONTHLY_IN_DAYS%%, 
          grace_monthly_in_days=%%GRACE_MONTHLY_IN_DAYS%%, 
          grace_quarterly_in_days=%%GRACE_QUARTERLY_IN_DAYS%%, 
          grace_semiannual_in_days=%%GRACE_SEMIANNUAL_IN_DAYS%%, 
          grace_annually_in_days=%%GRACE_ANNUALLY_IN_DAYS%%, 
          is_grace_daily_enabled=%%IS_GRACE_DAILY_ENABLED%%, 
          is_grace_biweekly_enabled=%%IS_GRACE_BIWEEKLY_ENABLED%%, 
          is_grace_weekly_enabled=%%IS_GRACE_WEEKLY_ENABLED%%, 
          is_grace_semimonthly_enabled=%%IS_GRACE_SEMIMONTHLY_ENABLED%%, 
          is_grace_monthly_enabled=%%IS_GRACE_MONTHLY_ENABLED%%, 
          is_grace_quarterly_enabled=%%IS_GRACE_QUARTERLY_ENABLED%%, 
          is_grace_semiannual_enabled=%%IS_GRACE_SEMIANNUAL_ENABLED%%, 
          is_grace_anually_enabled=%%IS_GRACE_ANUALLY_ENABLED%%, 
          is_auto_run_eop_enabled=%%IS_AUTO_RUN_EOP_ENABLED%%, 
          is_auto_soft_close_bg_enabled=%%IS_AUTO_SOFT_CLOSE_BG_ENABLED%%, 
          is_block_new_accounts_enabled=%%IS_BLOCK_NEW_ACCOUNTS_ENABLED%%,
          is_run_scheduled_adapters=%%IS_RUN_SCHEDULED_ADAPTERS_ENABLED%%
      