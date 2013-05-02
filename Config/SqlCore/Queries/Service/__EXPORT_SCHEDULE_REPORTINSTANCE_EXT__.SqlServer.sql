
					exec export_ScheduleReportInstance 
								@ReportInstanceId 		= %%ID_REP_INSTANCE%%,
								@scheduletype 			= %%SCHEDULE_TYPE%%,
								@ExecuteTime 			= %%EXECUTE_TIME%%,
								@RepeatHours 			= %%REPEAT_HOURS%%,
								@ExecuteStartTime 		= %%START_TIME_BOUNDARY%%,
								@ExecuteEndTime 		= %%END_TIME_BOUNDARY%%,
								@SkipFirstDayOfMonth 	= %%SKIP_FIRST_DAY_OF_MONTH%%,
								@SkipLastDayOfMonth 	= %%SKIP_LAST_DAY_OF_MONTH%%,
								@DaysInterval 			= %%DAYS_INTERVAL%%,
								@ExecuteWeekDays 		= %%EXECUTE_WEEK_DAYS%%,		-- Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN
								@SkipWeekDays			= %%SKIP_WEEK_DAYS%%,			-- Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN
								@ExecuteMonthDay		= %%EXECUTE_ON_MONTH_DAY%%,		-- Day of the month when to execute
								@ExecuteFirstDayOfMonth	= %%EXEC_FIRST_DAY_OF_MONTH%%,	-- Execute on the first day of the month
								@ExecuteLastDayOfMonth	= %%EXEC_LAST_DAY_OF_MONTH%%,		-- Execute on the last day of the month
								@SkipTheseMonths		= %%SKIP_THESE_MONTHS%%,			-- comma seperated set of months that have to be skipped for the monthly schedule executes
								@monthtodate			= %%MONTH_TO_DATE%%,
								@ValidateOnly			= 0,
								@IdRpSchedule			= %%ID_RP_SCHEDULE%%,
								@ScheduleId				= 0
								
			