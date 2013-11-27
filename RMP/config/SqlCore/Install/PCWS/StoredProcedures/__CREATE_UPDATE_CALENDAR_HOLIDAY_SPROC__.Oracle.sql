
		 create or replace procedure UpdateCalendarHoliday(
			p_id_holiday int,
			p_n_code int,
			p_n_day int,
			p_n_month int,
			p_n_year int,
			p_id_day out int)
			as
				l_nCode int;
				l_nDay int;
				l_nMonth int;
				l_nYear int;
			BEGIN
				
				select 
					cd.id_day,
					COALESCE(p_n_code, n_code),
					COALESCE(p_n_day, n_day),
					COALESCE(p_n_month, n_month),
					COALESCE(p_n_year, n_year)
				INTO
					p_id_day,
					l_nCode,
					l_nDay,
					l_nMonth,
					l_nYear
				from
					t_calendar_holiday ch
					inner join
					t_calendar_day cd on ch.id_day = cd.id_day
				where
					ch.id_holiday = p_id_holiday;
				
				update t_calendar_day set n_code = l_nCode where id_day = p_id_day;
				
				update t_calendar_holiday set n_day = l_nDay, n_month = l_nMonth, n_year = l_nYear
				where id_holiday = p_id_holiday;
			END;
		