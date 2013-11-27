
				create proc GetRateFrom_%%TABLE_NAME%%(@id_po_sched int,
					@id_pl_sched int,
					@id_ICB_sched int,
					-- generated inputs
					%%SPROC_INPUTS%%  -- 	@c_totalBytes_in numeric(18,9),@c_totalSongs_in numeric(18,9),
					-- generated outputs
					%%SPROC_OUTPUTS%% -- 	@c_rate_out numeric(18,9) OUTPUT,	@c_ConnectionFee_out numeric(18,9) OUTPUT)
				as

					select %%OUTPUT_ASSIGNMENTS%% -- @c_rate_out = list.c_rate,@c_ConnectionFee_out = list.c_ConnectionFee
					from (
						select  TOP 1 id_sched,n_order,
						rank = case id_sched 
							-- pricelist chaining rules would mean that we would
							-- omit either po & default PL or just default PL
							when @id_ICB_sched then 1 -- ICB
							when @id_po_sched then 2 -- PO
							when @id_pl_sched then 3 -- default account PL
							else 10
						end,
						%%ACTIONS%% -- c_rate,c_ConnectionFee
						from %TABLE_NAME%% -- t_pt_songdownloads 
						where
						-- static rules
						%%STATIC_RULES%%
						-- @c_totalBytes_in < c_TotalBytes AND
						%%DYNAMIC_RULES%%
						-- dynamic rules
						-- (c_totalSongs_op = '<' AND @c_totalSongs_in < c_TotalSongs) OR
						--(c_totalSongs_op = '>' AND @c_totalSongs_in > c_TotalSongs) OR
						-- (c_totalSongs_op = '<=' AND @c_totalSongs_in <= c_TotalSongs) OR
						-- (c_totalSongs_op = '>=' AND @c_totalSongs_in >= c_TotalSongs) OR
						-- (c_totalSongs_op = '!=' AND @c_totalSongs_in <> c_TotalSongs) AND
						id_sched in (@id_po_sched,@id_pl_sched,@id_ICB_sched)
					--	group by id_sched
						order by n_order,rank
						) list
			