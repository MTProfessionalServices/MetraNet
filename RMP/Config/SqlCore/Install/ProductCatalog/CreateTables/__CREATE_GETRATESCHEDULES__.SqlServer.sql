
					create proc GetRateSchedules @id_acc as int,
					@acc_cycle_id as int,
					@default_pl as int,
					@RecordDate as datetime,
					@id_pi_template as int
					as

						-- real stored procedure code starts here

						-- only count rows on the final select.
						SET NOCOUNT ON

						declare @winner_type as int
						declare @winner_row as int
						declare @winner_begin as datetime
						-- Don't actually need the @winner end since it is not used
						-- to test overlapping effective dates

						declare @CursorVar CURSOR
						declare @count as int
						declare @i as int
						set @i = 0

						declare @tempID as int
						declare @tempStartType as int
						declare @temp_begin as datetime
						declare @temp_b_offset as int
						declare @tempEndType as int
						declare @temp_end as datetime
						declare @temp_e_offset as int

						declare @sub_begin as datetime
						declare @sub_end as datetime

						-- unused stuff until temporary table insertion
						declare @id_sched as int
						declare @dt_mod as datetime
						declare @id_po as int
						declare @id_paramtable as int
						declare @id_pricelist as int
						declare @id_sub as int
						declare @id_pi_instance as int

						declare @currentptable as int
						declare @currentpo as int
						declare @currentsub as int

						-- winner variables
						declare @win_id_sched as int
						declare @win_dt_mod as datetime
						declare @win_id_paramtable as int
						declare @win_id_pricelist as int
						declare @win_id_sub as int
						declare @win_id_po as int
						declare @win_id_pi_instance as int

						declare @TempEff table (id_sched int not null,
							dt_modified datetime not null,
							id_paramtable int not null,
							id_pricelist int not null,
							id_sub int null,
							id_po int null,
							id_pi_instance int null)


						-- declare our cursor. Is there anything special here for performance around STATIC vs. DYNAMIC?
						set @CursorVar = CURSOR STATIC
							 FOR 
								-- this query is pretty tricky.  It is the union of all of the possible rate schedules
								-- on the resolved product offering AND the intersection of the 
								-- default account pricelist and parameter tables for the priceable item type.
								select
								t_rsched.id_sched,t_rsched.dt_mod,
								tm.id_po,tm.id_pi_instance,tm.id_paramtable, tm.id_pricelist,tm.id_sub
								,te.n_begintype,te.dt_start, te.n_beginoffset,te.n_endtype,te.dt_end,te.n_endoffset
								,t_sub.vt_start dt_start,t_sub.vt_end dt_end
								from t_pl_map tm
								INNER JOIN t_sub on t_sub.id_acc= @id_acc
								INNER JOIN t_rsched on t_rsched.id_pricelist = tm.id_pricelist AND t_rsched.id_pt =tm.id_paramtable AND
								t_rsched.id_pi_template = @id_pi_template
								INNER JOIN t_effectivedate te on te.id_eff_date = t_rsched.id_eff_date
								where tm.id_po = t_sub.id_po and tm.id_pi_template = @id_pi_template 
								and (tm.id_acc = @id_acc or tm.id_sub is null)
								-- make sure that subscription is currently in effect
								AND (t_sub.vt_start <= @RecordDate AND @RecordDate <= t_sub.vt_end)
								UNION ALL
								select tr.id_sched,tr.dt_mod,
								NULL,NULL,map.id_pt,@default_pl,NULL,
								te.n_begintype,te.dt_start,te.n_beginoffset,te.n_endtype,te.dt_end,te.n_endoffset
								,NULL,NULL
								from t_rsched tr
								INNER JOIN t_effectivedate te ON te.id_eff_date = tr.id_eff_date
								-- throw out any default account pricelist rate schedules that use subscription relative effective dates
								AND te.n_begintype <> 2
								-- XXX fix this by passing in the instance ID
								INNER JOIN t_pi_template on id_template = @id_pi_template
								INNER JOIN t_pi_rulesetdef_map map ON map.id_pi = t_pi_template.id_pi
								where tr.id_pt = map.id_pt AND tr.id_pricelist = @default_pl AND tr.id_pi_template = @id_pi_template
								-- the ordering is very important.  The following algorithm depends on the fact
								-- that ICB rates will show up first (rows that don't have a NULL subscription value),
								-- normal product offering rates next, and thirdly the default account pricelist rate schedules
								order by tm.id_paramtable,tm.id_sub desc,tm.id_po desc

						OPEN @CursorVar
						select @count = @@cursor_rows

						while @i < @count begin
							FETCH NEXT FROM @CursorVar into 
								-- rate schedule stuff
								@id_sched,@dt_mod
								-- plmap
								,@id_po,@id_pi_instance,@id_paramtable,@id_pricelist,@id_sub
								-- effectivedate rate schedule
								,@tempStartType,@temp_begin,@temp_b_offset,@tempEndType,@temp_end,@temp_e_offset
								-- effective date from subscription
								,@sub_begin,@sub_end

							set @i = (select @i + 1)

							if(@currentptable IS NULL) begin
								set @currentptable = @id_paramtable
								set @currentpo = @id_po
								set @currentsub = @id_sub
							end
							else if(@currentpTable != @id_paramtable
									 OR -- completely new parameter table
									@currentsub != IsNull(@id_sub,-1) OR -- ICB rates
									@currentpo != IsNull(@id_po,-1) -- default account PL
								) begin

								if @winner_row IS NOT NULL begin
									
									-- insert winner record into table variable
									insert into @TempEff values (@win_id_sched,@win_dt_mod,@win_id_paramtable,
									@win_id_pricelist,@win_id_sub,@win_id_po,@win_id_pi_instance)
								end
								-- clear out winner values
								set @winner_type = NULL
								set @winner_row = NULL
								set @winner_begin = NULL
							end
							-- set our current parametertable
							set @currentpTable = @id_paramtable
							set @currentpo = @id_po
							set @currentsub = @id_sub

							-- step : convert non absolute dates into absolute dates.  Only have to 
							-- deal with subscription relative and usage cycle relative

							-- subscription relative.  Add the offset of the rate schedule effective date to the
							-- start date of the subscription.  This code assumes that subscription effective dates
							-- are absolute or have already been normalized
							
							if(@tempStartType = 2) begin
								set @temp_begin = @sub_begin + @temp_b_offset
							end
							if(@tempEndType = 2) begin
								set @temp_end = dbo.MTEndOfDay(@temp_e_offset + @sub_begin)
							end


							-- usage cycle relative
							-- The following query will only return a result if both the beginning 
							-- and the end start dates are somewhere in the past.  We find the date by
							-- finding the interval where our date lies and adding 1 second the end of that 
							-- interval to give us the start of the next.  If the startdate query returns NULL,
							-- we can simply reject the result since the effective date is in the future.  It is 
							-- OK for the enddate to be NULL.  Note: We expect that we will always be able to find
							-- an old interval in t_usage_interval and DO NOT handle purged records
							
							if(@tempStartType = 3) begin
								set @temp_begin = dbo.NextDateAfterBillingCycle(@id_acc,@temp_begin)
								if(@temp_begin IS NULL) begin
									-- restart to the beginning of the while loop
									continue
								end
							end
							if(@tempEndType = 3) begin
								set @temp_end = dbo.NextDateAfterBillingCycle(@id_acc,@temp_end)
							end

							-- step : perform date range check
							if( @RecordDate >= IsNull(@temp_begin,@RecordDate) AND @RecordDate <= IsNull(@temp_end,@RecordDate)) begin
								-- step : check if there is an existing winner

								-- if no winner always populate
								if( (@winner_row IS NULL) OR
									-- start into the complicated winner logic used when there are multiple
									-- effective dates that apply.  The winner is the effective date with the latest
									-- start date

									-- Anything overrides a NULL start date
									(@tempStartType != 4 AND @winner_type = 4) OR
									-- subscription relative overrides anything else
									(@winner_type != 2 AND @tempStartType = 2) OR
									-- check for duplicate subscription relative, pick one with latest start date
									(@winner_type = 2 AND @tempStartType = 2 AND @winner_begin < @temp_begin) OR
									-- check if usage cycle or absolute, treat as equal
									((@winner_type = 1 OR @winner_type = 3) AND (@tempStartType = 1 OR @tempStartType = 3) 
									AND @winner_begin < @temp_begin)
									) -- end if
								begin
									set @winner_type = @tempStartType
									set @winner_row = @i
									set @winner_begin = @temp_begin

									set @win_id_sched = @id_sched
									set @win_dt_mod = @dt_mod
									set @win_id_paramtable = @id_paramtable
									set @win_id_pricelist =@id_pricelist
									set @win_id_sub =@id_sub
									set @win_id_po = @id_po
									set @win_id_pi_instance = @id_pi_instance
								end
							end
						end

						-- step : Dump the last remaining winner into the temporary table
						if @winner_row IS NOT NULL begin
							insert into @TempEff values (@win_id_sched,@win_dt_mod,@win_id_paramtable,
							@win_id_pricelist,@win_id_sub,@win_id_po,@win_id_pi_instance)
						end

						CLOSE @CursorVar
						DEALLOCATE @CursorVar

						-- step : if we have any results, get the results from the temp table
						SET NOCOUNT OFF
						select * from @TempEff
	 