
				declare
					result number;
				BEGIN
					result := Export_SetReprtInstNextRunDate(V_REPORTINSTANCEID=>%%REPORT_INSTANCE_ID%%, V_SCHEDULEID=>%%SCHEDULE_ID%%, IV_SCHEDULETYPE=>%%SCHEDULE_TYPE%%, V_DTNOW=>%%DT_NOW%%, IV_DTSTART=>%%START_DATE%%);
				end;
			