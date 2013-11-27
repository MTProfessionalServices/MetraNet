
				create or replace procedure AddCalendarPeriod(
				id_day t_calendar_periods.ID_DAY%type,
				n_begin t_calendar_periods.N_BEGIN%type,
				n_end t_calendar_periods.N_END%type,
				n_code t_calendar_periods.N_CODE%type,
				id_period out number)
				as
				begin 
					insert into t_calendar_periods (id_period,id_day, n_begin, n_end, n_code)
					values (seq_t_calendar_periods.nextval,id_day, n_begin,n_end, n_code);
					select seq_t_calendar_periods.currval into id_period from dual;
				end;
		