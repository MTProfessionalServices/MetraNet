
				create or replace procedure AddCalendarWeekday( 
				temp_id_calendar int,
				temp_n_weekday int,
				temp_n_code int,
				id_day OUT int)
				as
				begin
					insert into t_calendar_day (id_day,id_calendar, n_weekday, n_code)
					values (seq_t_calendar_day.nextval,temp_id_calendar,temp_n_weekday, temp_n_code);
					select seq_t_calendar_day.currval into id_day from dual;
			  end;
		