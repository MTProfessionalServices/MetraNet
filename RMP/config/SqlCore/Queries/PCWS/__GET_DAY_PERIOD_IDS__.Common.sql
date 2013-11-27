
				Select cp.id_period "PeriodID", cp.n_begin "StartTime", cp.n_end "EndTime", cp.n_code "Code"
				From t_calendar_periods cp %%UPDLOCK%%
				Where cp.id_day = %%DAY_ID%%
				