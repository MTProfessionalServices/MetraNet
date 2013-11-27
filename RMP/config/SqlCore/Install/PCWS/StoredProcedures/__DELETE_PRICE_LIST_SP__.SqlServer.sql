
		create procedure sp_DeletePricelist 
		(
			@a_plID int,
			@status INT OUTPUT
		)
		as
		begin
			declare @n_pl_maps as int
			declare @n_def_acc as int

			declare @CursorVar CURSOR 
			declare @count as int
			declare @i as int
			declare @id_rs as int
			
			set @n_pl_maps = (select count(*) from t_pl_map where id_pricelist = @a_plID)
			if (@n_pl_maps > 0)
			begin
				select @status = 1
				return
			end

			set @n_def_acc = (select count(*) from t_av_internal where c_pricelist = @a_plID)
			if (@n_def_acc > 0)
			begin
				select @status = 2
				return
			end
			
			set @i = 0
			set @CursorVar = CURSOR STATIC

			for select id_sched from t_rsched
					where id_pricelist = @a_plID
			open @CursorVar
			select @count = @@cursor_rows
			while @i < @count 
				begin
					fetch next from @CursorVar into @id_rs
					set @i = (select @i + 1)
					exec sp_DeleteRateSchedule @id_rs
				end
			close @CursorVar
			deallocate @CursorVar

			delete from t_pricelist where id_pricelist = @a_plID
			delete from t_ep_pricelist where id_prop = @a_plID
			execute DeleteBaseProps @a_plID
			
			select @status = 0
			return (0)
		end
		