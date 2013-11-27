
				create or replace procedure AddCalendarHoliday(
				temp_id_calendar t_calendar_day.ID_CALENDAR%type,
				temp_n_code t_calendar_day.N_CODE%type,
				temp_nm_name t_calendar_holiday.NM_NAME%type,
				temp_n_day t_calendar_holiday.N_DAY%type,
				temp_n_weekday t_calendar_day.N_WEEKDAY%type,
				temp_n_weekofmonth t_calendar_holiday.N_WEEKOFMONTH%type,
				temp_n_month t_calendar_holiday.N_MONTH%type,
				temp_n_year t_calendar_holiday.N_YEAR%type,
				temp_id_day out t_calendar_holiday.ID_DAY%type)
				as
				begin
					insert into t_calendar_day (id_day,id_calendar,n_weekday, n_code) /* holidays have n_weekday == NULL */
					values (seq_t_calendar_day.nextval,temp_id_calendar,temp_n_weekday, temp_n_code);
					select seq_t_calendar_day.currval into temp_id_day from dual;
					insert into t_calendar_holiday (id_holiday,id_day, nm_name, n_day, n_weekofmonth, n_month, n_year)
					values (seq_t_calendar_holiday.nextval,temp_id_day,temp_nm_name, temp_n_day, temp_n_weekofmonth,temp_n_month, temp_n_year);
				end;
		