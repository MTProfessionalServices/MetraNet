
		 create proc AddCalendarPeriod
			@id_day int,
			@n_begin int,
			@n_end int,
			@n_code int,
			@id_period int OUTPUT
			as
			begin tran
				insert into t_calendar_periods (id_day, n_begin, n_end, n_code)
					values (@id_day, @n_begin, @n_end, @n_code)
				select @id_period = @@IDENTITY
			commit tran
		