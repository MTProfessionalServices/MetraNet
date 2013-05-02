
          select 
          grace_daily_in_days, 
          grace_biweekly_in_days, 
          grace_weekly_in_days, 
          grace_semimonthly_in_days, 
          grace_monthly_in_days, 
          grace_quarterly_in_days, 
          grace_semiannual_in_days, 
          grace_annually_in_days, 
          is_grace_daily_enabled, 
          is_grace_biweekly_enabled, 
          is_grace_weekly_enabled, 
          is_grace_semimonthly_enabled, 
          is_grace_monthly_enabled, 
          is_grace_quarterly_enabled, 
          is_grace_semiannual_enabled, 
          is_grace_anually_enabled, 
          is_auto_run_eop_enabled, 
          is_auto_soft_close_bg_enabled, 
          is_block_new_accounts_enabled,
          is_run_scheduled_adapters, 
          multicast_address, 
          multicast_port, 
          multicast_time_to_live 
          from t_billing_server_settings
	