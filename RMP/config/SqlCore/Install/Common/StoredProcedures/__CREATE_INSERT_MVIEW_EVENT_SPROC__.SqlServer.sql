
        	create procedure InsertIntoEventTable(@id_mv int,
				 	@description nvarchar(4000),
			 		@id_event int output)
			as
			insert into t_mview_event(id_mv, description) values(@id_mv, @description)
			set @id_event = @@identity

		