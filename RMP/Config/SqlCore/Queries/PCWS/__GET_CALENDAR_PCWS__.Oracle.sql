
			  begin
			  
			  open :1 for
			  Select c.id_calendar "ID", bp.nm_name "Name", bp.nm_desc "Description"
			From t_calendar c inner join t_base_props bp on c.id_calendar = bp.id_prop
			Where c.id_calendar = %%CALENDAR_ID%%;

			open :2 for
			Select cd.id_day "DayID", cd.n_weekday "WeekdayID", cd.n_code "Code", ch.id_holiday "HolidayID",
				Ch.nm_name "HolidayName", ch.n_day "Day", ch.n_month "Month", ch.n_year "Year"
			From t_calendar_day cd left outer join t_calendar_holiday ch on cd.id_day = ch.id_day
			Where cd.id_calendar = %%CALENDAR_ID%%;

			open :3 for
			Select cp.id_day "DayID", cp.id_period "PeriodID", cp.n_begin "StartTime", cp.n_end "EndTime", cp.n_code "Code"
			From t_calendar_day cd inner join t_calendar_periods cp on cd.id_day = cp.id_day
			Where cd.id_calendar = %%CALENDAR_ID%%;

			open :4 for
			Select id_prop "ID", id_lang_code "LanguageCode", nm_desc "Description"
			From t_vw_base_props 
			where id_prop = %%CALENDAR_ID%%
			order by "ID", "LanguageCode";
			
			end;
			  