
				CREATE PROCEDURE Rev_UpdateStateFromPFBToClosed (
					@id_billgroup INT,
					@ref_date DATETIME,
					@system_date datetime,
					@status INT OUTPUT)
				AS
 				BEGIN
					DECLARE @ref_date_mod DATETIME, 
						@varMaxDateTime DATETIME,
						@ref_date_modSOD DATETIME

					SELECT @status = -1
					-- Set the maxdatetime into a variable
					SELECT @varMaxDateTime = dbo.MTMaxDate()

					IF (@ref_date IS NULL)
					BEGIN
						SELECT @ref_date_mod = @system_date
					END
					ELSE
					BEGIN
						SELECT @ref_date_mod = @ref_date
					END

					SELECT @ref_date_modSOD = dbo.mtstartofday(@ref_date_mod)

					-- Save those id_acc whose state MAY be reversed to a temp table 
					CREATE TABLE #updatestate_0 (id_acc int, vt_start datetime, tt_start datetime)

					INSERT INTO #updatestate_0 (id_acc, vt_start, tt_start)
					SELECT bg.id_acc, ash.vt_start, ash.tt_start
					FROM t_billgroup_member bg
					INNER JOIN t_billgroup_materialization bgm 
						ON bg.id_materialization = bgm.id_materialization
					INNER JOIN t_usage_interval ui 
						ON ui.id_interval = bgm.id_usage_interval
					INNER JOIN t_account_state_history ash
						ON ash.id_acc = bg.id_acc
						AND ash.status = 'CL'
						AND ash.tt_end = @varMaxDateTime 
						AND ash.tt_start > ui.dt_end
					WHERE bg.id_billgroup = @id_billgroup
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Add the payees for the payers selected in the previous step
					INSERT INTO #updatestate_0 (id_acc, vt_start, tt_start)
					SELECT pa.id_payee, ash.vt_start, ash.tt_start
					FROM t_billgroup_member bg
					INNER JOIN t_billgroup_materialization bgm 
						ON bg.id_materialization = bgm.id_materialization
					INNER JOIN t_usage_interval ui 
						ON ui.id_interval = bgm.id_usage_interval
					INNER JOIN t_payment_redirection pa 
					  ON pa.id_payer = bg.id_acc
					INNER JOIN t_account_state_history ash
						ON ash.id_acc = pa.id_payee
						AND ash.status = 'CL'
						AND ash.tt_end = @varMaxDateTime 
						AND ash.tt_start > ui.dt_end
					WHERE bg.id_billgroup = @id_billgroup AND
					      pa.id_payee NOT IN (SELECT id_acc FROM #updatestate_0)
 					if (@@error <>0)
					begin
	  					RETURN
					end


					-- Make sure these 'CL' id_accs were immediately from the 'PF' status
					-- And save those id_acc whose state WILL be updated to a temp 
					CREATE TABLE #updatestate_1(id_acc int, tt_end datetime)

					INSERT INTO #updatestate_1 (id_acc, tt_end)
					SELECT tmp.id_acc, ash.tt_end
					FROM #updatestate_0 tmp
					INNER JOIN t_account_state_history ash
						ON ash.id_acc = tmp.id_acc
						AND ash.status = 'PF'
						AND ash.vt_start < tmp.vt_start
						AND ash.vt_end = @varMaxDateTime 
						AND ash.tt_end = DATEADD(ms, -10, tmp.tt_start)
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- follow same pattern for t_gsubmember_historical and t_gsubmember.
					declare @varSystemGMTDateTime datetime
					SELECT @varSystemGMTDateTime = @system_date
					declare @rowcnt int
					SELECT @rowcnt = count(*)
					FROM #updatestate_1
 					if (@@error <>0)
					begin
	  					RETURN
					end

					IF @rowcnt > 0
					BEGIN
					-- ------------------------------------------------------------
					-- ------------------- reverse t_sub & t_sub_history ------------------
					-- ------------------------------------------------------------

						-- Find those records that were updated by the PFBToCL 
						-- and have not yet been updated again
						-- and thus can be reversed
						SELECT sh2.id_sub, sh2.vt_end, sh2.tt_end
						INTO #updatesub_1
						FROM (SELECT sh.id_sub, sh.tt_start
							FROM t_sub_history sh
							INNER JOIN #updatestate_1 tmp
								ON tmp.id_acc = sh.id_acc
								AND sh.vt_end = DATEADD(s, -1, @ref_date_modSOD)
								AND sh.tt_end = @varMaxDateTime
							) rev
						INNER JOIN t_sub_history sh2
							ON sh2.id_sub = rev.id_sub
							AND sh2.tt_end = DATEADD(ms, -10, rev.tt_start)
 						if (@@error <>0)
						begin
	  						RETURN
						end

						UPDATE t_sub_history
						SET tt_end = DATEADD(ms, -10, @system_date)
						FROM t_sub_history sh
						INNER JOIN #updatesub_1 tmp
							ON tmp.id_sub = sh.id_sub
							AND sh.tt_end = @varMaxDateTime
 						if (@@error <>0)
						begin
	  						RETURN
						end

						INSERT INTO t_sub_history
						(id_sub,id_sub_ext,id_acc,id_po,dt_crt,id_group,vt_start,vt_end,tt_start,tt_end )
						SELECT sh.id_sub,sh.id_sub_ext,sh.id_acc,sh.id_po,
							sh.dt_crt,sh.id_group,sh.vt_start,sh.vt_end,
							@system_date,@varMaxDateTime
						FROM t_sub_history sh
						INNER JOIN #updatesub_1 tmp
							ON tmp.id_sub = sh.id_sub
							AND tmp.tt_end = sh.tt_end
 						if (@@error <>0)
						begin
	  						RETURN
						end

						UPDATE t_sub
						SET vt_end = tmp.vt_end
						FROM t_sub sh
						INNER JOIN #updatesub_1 tmp
							ON tmp.id_sub = sh.id_sub
 						if (@@error <>0)
						begin
	  						RETURN
						end
					-- ------------------------------------------------------------
					-- ------------------- t_sub & t_sub_history ------------------
					-- ------------------------------------------------------------

					-- ------------------------------------------------------------
					-- ------------ reverse t_gsubmember & t_gsubmember_historical --------
					-- ------------------------------------------------------------

						-- Find those records that were updated by the PFBToCL 
						-- and have not yet been updated again
						-- and thus can be reversed
						SELECT gh2.id_group, gh2.id_acc, gh2.vt_start, gh2.vt_end, gh2.tt_end
						INTO #updategsub_1
						FROM (SELECT gh.id_group, gh.id_acc, gh.vt_start, gh.vt_end, gh.tt_start
							FROM t_gsubmember_historical gh
							INNER JOIN #updatestate_1 tmp
								ON tmp.id_acc = gh.id_acc
								AND gh.vt_end = DATEADD(s, -1, @ref_date_modSOD)
								AND gh.tt_end = @varMaxDateTime
							) rev
						INNER JOIN t_gsubmember_historical gh2
							ON gh2.id_group = rev.id_group
							AND gh2.id_acc = rev.id_acc
							AND gh2.vt_start = rev.vt_start
							AND gh2.tt_end = DATEADD(ms, -10, rev.tt_start)
 						if (@@error <>0)
						begin
	  						RETURN
						end

						UPDATE t_gsubmember_historical
						SET tt_end = DATEADD(ms, -10, @system_date)
						FROM t_gsubmember_historical gh
						INNER JOIN #updategsub_1 tmp
							ON tmp.id_group = gh.id_group
							AND tmp.id_acc = gh.id_acc
							AND tmp.vt_start = gh.vt_start
							AND gh.tt_end = @varMaxDateTime
 						if (@@error <>0)
						begin
	  						RETURN
						end

						INSERT INTO t_gsubmember_historical
						(id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
						SELECT gh.id_group, gh.id_acc, gh.vt_start, gh.vt_end,
							@system_date,@varMaxDateTime
						FROM t_gsubmember_historical gh
						INNER JOIN #updategsub_1 tmp
							ON tmp.id_group = gh.id_group
							AND tmp.id_acc = gh.id_acc
							AND tmp.vt_start = gh.vt_start
							AND tmp.tt_end = gh.tt_end
 						if (@@error <>0)
						begin
	  						RETURN
						end

						UPDATE t_gsubmember
						SET vt_end = tmp.vt_end
						FROM t_gsubmember gh
						INNER JOIN #updategsub_1 tmp
							ON tmp.id_group = gh.id_group
							AND tmp.id_acc = gh.id_acc
							AND tmp.vt_start = gh.vt_start
 						if (@@error <>0)
						begin
	  						RETURN
						end

					-- ------------------------------------------------------------
					-- ------------ t_gsubmember & t_gsubmember_historical --------
					-- ------------------------------------------------------------
					END
					-- Reverse actions for the identified id_accs
					EXEC Reverse_UpdateStateRecordSet @system_date, @status OUTPUT

					--select @status = 1
					DROP TABLE #updatestate_0
					DROP TABLE #updatestate_1

					RETURN
				END
				