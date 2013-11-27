
CREATE TABLE t_billing_server_settings
(
	grace_daily_in_days             integer NOT NULL,
	grace_biweekly_in_days          integer NOT NULL,
	grace_weekly_in_days            integer NOT NULL,
	grace_semimonthly_in_days       integer NOT NULL,
	grace_monthly_in_days           integer NOT NULL,
	grace_quarterly_in_days         integer NOT NULL,
	grace_semiannual_in_days        integer NOT NULL,
  grace_annually_in_days          integer NOT NULL,
	is_grace_daily_enabled          integer NOT NULL,	
	is_grace_biweekly_enabled       integer NOT NULL,
	is_grace_weekly_enabled         integer NOT NULL,
	is_grace_semimonthly_enabled    integer NOT NULL,
	is_grace_monthly_enabled        integer NOT NULL,	
	is_grace_quarterly_enabled      integer NOT NULL,
	is_grace_semiannual_enabled     integer NOT NULL,
  is_grace_anually_enabled        integer NOT NULL,
	is_auto_run_eop_enabled         integer NOT NULL,
	is_auto_soft_close_bg_enabled   integer NOT NULL,
	is_block_new_accounts_enabled   integer NOT NULL,
	is_run_scheduled_adapters       integer NOT NULL,
	multicast_address               varchar2(40) NOT NULL,
	multicast_port                  integer NOT NULL,
	multicast_time_to_live          integer NOT NULL
)
			 