
				create procedure RemoveGroupSubMember(
				@id_acc int,
				@p_substartdate datetime,
				@id_group int,
				@b_overrideDateCheck varchar,
        @p_systemdate datetime,
				@status int OUTPUT
				)
				as
				begin
				declare @startdate datetime
				declare @varMaxDateTime datetime
				select @varMaxDateTime = dbo.MTMaxDate()
				select @status = 0

				if (@b_overrideDateCheck = 'N')

					begin

					-- find the start date of the group subscription membership
					-- that exists at some point in the future.

						select @startdate  = vt_start from t_gsubmember
						where id_acc = @id_acc 
									AND id_group = @id_group 
									AND vt_start > @p_systemdate

						if (@startdate is null)
							begin
								select @status = -486604776
								return
							end
					end

				-- The logic here is the following:
				-- We have a parameter called p_substartdate. We need it to identify the proper record to delete,
				-- in case we have multiple participations for the same account on a group sub.
				-- But this parameter is optional to the object - so if it is not passed in, we will delete
				-- all participations of this account. Otherwise, we delete just the participation with the provided
				-- start date.
 				if (@p_substartdate = dbo.MTMaxDate())
					begin
					  delete from t_gsubmember where id_acc = @id_acc and id_group = @id_group
						update t_gsubmember_historical set tt_end = dbo.subtractsecond(@p_systemdate)
							where id_acc = @id_acc 
										and id_group = @id_group
										and tt_end = @varMaxDateTime
					end
				else
					begin
					  delete from t_gsubmember where id_acc = @id_acc and id_group = @id_group and @p_substartdate = vt_start
						update t_gsubmember_historical set tt_end = dbo.subtractsecond(@p_systemdate)
						where id_acc = @id_acc 
							and id_group = @id_group
							and tt_end = @varMaxDateTime
							and @p_substartdate = vt_start
					end
					
				-- If-else structure above is not very elegant, both options very similar, but I will not get fancy right now
				-- done

				select @status = 1

				end		 
		 