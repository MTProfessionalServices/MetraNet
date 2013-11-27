
		 create proc AddCalendarWeekday
			@id_calendar int,
			@n_weekday int,
			@n_code int,
			@id_day int OUTPUT
			as
				begin tran
					insert into t_calendar_day (id_calendar, n_weekday, n_code)
						values (@id_calendar, @n_weekday, @n_code)
					select @id_day = @@IDENTITY
				commit tran
		