
		 create proc UpdateCalendarHoliday
			@id_holiday int,
			@n_code int,
			@n_day int,
			@n_month int,
			@n_year int,
			@id_day int output
			as
			begin tran
				declare @nCode int, @nDay int, @nMonth int, @nYear int
				
				select 
					@id_day = cd.id_day,
					@nCode = COALESCE(@n_code, n_code),
					@nDay = COALESCE(@n_day, n_day),
					@nMonth = COALESCE(@n_month, n_month),
					@nYear = COALESCE(@n_year, n_year)
				from
					t_calendar_holiday ch
					inner join
					t_calendar_day cd on ch.id_day = cd.id_day
				where
					ch.id_holiday = @id_holiday
				
				update t_calendar_day set n_code = @nCode where id_day = @id_day
				
				update t_calendar_holiday set n_day = @nDay, n_month = @nMonth, n_year = @nYear
				where id_holiday = @id_holiday

			commit tran
		