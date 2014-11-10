
				CREATE proc UpdateStateFromPFBToClosed (
					@id_billgroup INT,
					@ref_date DATETIME,
					@system_date datetime,
					@status INT OUTPUT)
				AS
 				BEGIN
					DECLARE @ref_date_mod DATETIME, @varMaxDateTime DATETIME, @ref_date_modSOD DATETIME

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

					-- Save those id_acc whose state MAY be updated to a temp table 
					-- (had usage the previous day)
					CREATE TABLE #updatestate_0 (id_acc int)
					INSERT INTO #updatestate_0 (id_acc)
					SELECT id_acc 
					FROM t_billgroup_member
					WHERE id_billgroup = @id_billgroup
          /* ESR-4670 */
          create clustered index idx_1 on #updatestate_0(id_acc)

          -- Add the payees for the payers
          INSERT INTO #updatestate_0 (id_acc)
	        SELECT pa.id_payee 
	        FROM t_billgroup_member bgm
          INNER JOIN t_payment_redirection pa ON pa.id_payer = bgm.id_acc
          WHERE bgm.id_billgroup = @id_billgroup AND
                @ref_date_mod between pa.vt_start AND pa.vt_end AND
                pa.id_payee NOT IN (SELECT id_acc FROM #updatestate_0)

					-- Save those id_acc whose state WILL be updated to a temp 
					-- table (has PF state)
					CREATE TABLE #updatestate_1(id_acc int)
					INSERT INTO #updatestate_1 (id_acc)
					SELECT tmp0.id_acc 
					FROM t_account_state ast, #updatestate_0 tmp0
					WHERE ast.id_acc = tmp0.id_acc
					AND ast.vt_end = @varMaxDateTime
					AND ast.status = 'PF'
					AND @ref_date_mod BETWEEN vt_start and vt_end

                    /* ESR-4670 */
					create clustered index idx_2 on #updatestate_1(id_acc)

					-- ------------------------------------------------------------
					-- ------------------- t_sub & t_sub_history ------------------
					-- ------------------------------------------------------------
					-- update all of the current subscriptions in t_sub_history 
					-- where the account ID matches and tt_end = dbo.mtmaxdate().  
					-- Set tt_end = systemtime.

					-- add a new record to t_sub_history where vt_end is the account 
					-- close date.
					-- Update the end date of the relevant subscriptions in t_sub 
					-- where id_acc = closed accounts
					-- Set vt_end = account close date.

					-- follow same pattern for t_gsubmember_historical and t_gsubmember.
					declare @varSystemGMTDateTime datetime
					SELECT @varSystemGMTDateTime = @system_date
					declare @rowcnt int
					SELECT @rowcnt = count(*)
					FROM #updatestate_1

					IF @rowcnt > 0
					BEGIN
					UPDATE t_sub_history 
					SET tt_end = DATEADD(ms, -10, @varSystemGMTDateTime)
					WHERE 
					/* ESR-5758 make predicate simpler per code review CR-779 */ 
					@ref_date_mod <= vt_end					       
					AND tt_end = @varMaxDateTime
					AND EXISTS (SELECT NULL FROM #updatestate_1 tmp
							WHERE tmp.id_acc = t_sub_history.id_acc)

					INSERT INTO t_sub_history (
						id_sub,
						id_sub_ext,
						id_acc,
						id_po,
						dt_crt,
						id_group,
						vt_start,
						vt_end,
						tt_start,
						tt_end )
					SELECT 
						sub.id_sub,
						sub.id_sub_ext,
						sub.id_acc,
						sub.id_po,
						sub.dt_crt,
						sub.id_group,
						sub.vt_start,
						--@ref_date_mod,
						/* ESR-5758 cover the case where an account starts a subscription and account is closed pending the final bill on the same day */ 
						case when dbo.subtractsecond(@ref_date_modSOD) < sub.vt_start 
							then                               
								@ref_date_modSOD
							else 
								dbo.subtractsecond(@ref_date_modSOD) 
						end,            
						@varSystemGMTDateTime,
						@varMaxDateTime
					FROM t_sub sub, #updatestate_1 tmp
					WHERE sub.id_acc = tmp.id_acc
					/* ESR-5758 make predicate simpler per code review CR-779 */ 
					AND @ref_date_mod <= vt_end					       

					-- Update the vt_end field of the Current records for the accounts
					UPDATE t_sub 
					SET vt_end = 
					/* ESR-5758 cover the case where an account starts a subscription and account is closed pending the final bill on the same day */ 
					(case when dbo.subtractsecond(@ref_date_modSOD) < vt_start 
					then                               
						@ref_date_modSOD
					else 
						dbo.subtractsecond(@ref_date_modSOD)
					end)
					WHERE 					
					/* ESR-5758 make predicate simpler per code review CR-779 */ 
					@ref_date_mod <= vt_end					
					AND EXISTS (SELECT NULL FROM #updatestate_1 tmp
							WHERE tmp.id_acc = t_sub.id_acc)
					-- ------------------------------------------------------------
					-- ------------------- t_sub & t_sub_history ------------------
					-- ------------------------------------------------------------

					-- ------------------------------------------------------------
					-- ------------ t_gsubmember & t_gsubmember_historical --------
					-- ------------------------------------------------------------
					UPDATE t_gsubmember_historical 
					SET tt_end = DATEADD(ms, -10, @varSystemGMTDateTime)
					WHERE 
					/* ESR-5758 make predicate simpler per code review CR-779 */ 
					@ref_date_mod <= vt_end					
					AND tt_end = @varMaxDateTime
					AND EXISTS (SELECT NULL FROM #updatestate_1 tmp
							WHERE tmp.id_acc = t_gsubmember_historical.id_acc)

					INSERT INTO t_gsubmember_historical (
						id_group,
						id_acc,
						vt_start,
						vt_end,
						tt_start,
						tt_end)
					SELECT 
						gsub.id_group,
						gsub.id_acc,
						gsub.vt_start,
						dbo.subtractsecond(@ref_date_modSOD),
						@varSystemGMTDateTime,
						@varMaxDateTime
					FROM t_gsubmember gsub, #updatestate_1 tmp
					WHERE gsub.id_acc = tmp.id_acc
					/* ESR-5758 make predicate simpler per code review CR-779 */ 
					AND @ref_date_mod <= vt_end

					-- Update the vt_end field of the Current records for the accounts
					UPDATE t_gsubmember 
					SET vt_end = dbo.subtractsecond(@ref_date_modSOD)
					WHERE 
					/* ESR-5758 make predicate simpler per code review CR-779 */ 
					@ref_date_mod <= vt_end										
					AND EXISTS (SELECT NULL FROM #updatestate_1 tmp
							WHERE tmp.id_acc = t_gsubmember.id_acc)
					END
					-- ------------------------------------------------------------
					-- ------------ t_gsubmember & t_gsubmember_historical --------
					-- ------------------------------------------------------------
					EXECUTE UpdateStateRecordSet
					@system_date,
					@ref_date_mod,
					'PF', 'CL',
					@status OUTPUT

					DROP TABLE #updatestate_0
					DROP TABLE #updatestate_1

					RETURN
				END
				