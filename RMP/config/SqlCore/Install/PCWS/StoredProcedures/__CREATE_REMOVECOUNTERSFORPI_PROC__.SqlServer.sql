
				CREATE procedure RemoveCountersForPI( @piID int )
				AS
				BEGIN
					DECLARE counterCursor cursor for select id_counter from t_counter_map with(updlock) where id_pi = @piID
					OPEN counterCursor
					
					DECLARE @counterId int
					fetch next from counterCursor into @counterId
					
					while @@FETCH_STATUS = 0
					BEGIN
						delete from t_counter_param_predicate where id_counter_param in
							(select id_counter_param from t_counter_params where id_counter = @counterId)
						
						delete from t_counter_param_map where id_counter_param in 
							(select id_counter_param from t_counter_params where id_counter = @counterId)
						
						delete from t_counter_params where id_counter = @counterId
						
						delete from t_counter_map where id_counter = @counterId
							
						delete from t_counter where id_prop = @counterId
						
						
						
						delete from t_base_props where id_prop = @counterId
						
						fetch next from counterCursor into @counterId
					END
					
					Close counterCursor
					Deallocate counterCursor
					
				END
