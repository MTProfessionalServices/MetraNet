
				CREATE PROCEDURE CheckForNotClosedDescendents (
					@id_acc INT,
					@ref_date DATETIME,
					@status INT output)
				AS
					BEGIN
						select @status = 1
						begin

						-- select accounts that have status less than closed
						SELECT @status =	count(*) 
						FROM 
				  		t_account_ancestor aa
							-- join between t_account_state and t_account_ancestor
							INNER JOIN t_account_state astate ON aa.id_descendent = astate.id_acc 
						WHERE
							aa.id_ancestor = @id_acc AND
				  		astate.status <> 'CL' AND
				  		@ref_date between astate.vt_start and astate.vt_end AND
				  		@ref_date between aa.vt_start and aa.vt_end
				  		-- success is when no rows found
   						if (@status is null)
							   begin
         				  select @status = 1
         					return
					        end
					  end
					END
				