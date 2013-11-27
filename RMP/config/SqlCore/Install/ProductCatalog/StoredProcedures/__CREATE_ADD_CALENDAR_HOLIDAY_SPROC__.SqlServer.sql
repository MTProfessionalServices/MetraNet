
		 create proc AddCalendarHoliday
			@id_calendar int,
			@n_code int,
			@nm_name NVARCHAR(255),
			@n_day int,
			@n_weekday int,
			@n_weekofmonth int,
			@n_month int,
			@n_year int,
			@id_day int OUTPUT
			as
			begin tran
				insert into t_calendar_day (id_calendar, n_weekday, n_code)
					values (@id_calendar, @n_weekday, @n_code)
				select @id_day = @@IDENTITY
				insert into t_calendar_holiday (id_day, nm_name, n_day, n_weekofmonth, n_month, n_year)
					values (@id_day, @nm_name, @n_day, @n_weekofmonth, @n_month, @n_year)
			commit tran
		