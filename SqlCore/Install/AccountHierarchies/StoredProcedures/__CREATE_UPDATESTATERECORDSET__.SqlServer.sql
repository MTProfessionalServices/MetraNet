
				CREATE PROCEDURE UpdateStateRecordSet (
					@system_date DATETIME,
					@start_date_mod DATETIME,
					@from_status CHAR(2),
					@to_status CHAR(2),
					@status INT OUTPUT)
				AS
 				BEGIN
					DECLARE @varMaxDateTime DATETIME,
						@varSystemGMTDateTime DATETIME,
						@varSystemGMTDateTimeSOD DATETIME,
						@start_date_modSOD DATETIME
					DECLARE @table_formerge TABLE (id_acc INT, status CHAR(2), vt_start DATETIME) 

					-- Set the maxdatetime into a variable
					SELECT @varMaxDateTime = dbo.MTMaxDate()
					-- Use the true current GMT time for the tt_ dates
					SELECT @varSystemGMTDateTime = @system_date
					SELECT @varSystemGMTDateTimeSOD = dbo.mtstartofday(@system_date)
					SELECT @start_date_modSOD = dbo.mtstartofday(@start_date_mod)
					SELECT @status = -1

					--CREATE TABLE #updatestate_1 (id_acc INT)

					-- Update the tt_end field of the t_account_state_history record 
					-- for the accounts
					UPDATE t_account_state_history 
					SET tt_end = DATEADD(ms, -10, @varSystemGMTDateTime)
					WHERE vt_end = @varMaxDateTime
					AND tt_end = @varMaxDateTime
					AND status = @from_status
					AND EXISTS (SELECT NULL FROM #updatestate_1 tmp 
						    WHERE tmp.id_acc = t_account_state_history.id_acc)
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Insert the to-be-updated Current records into the History table 
					-- for the accounts, exclude the one that needs to be override
					INSERT INTO t_account_state_history
					SELECT 
						ast.id_acc,
						ast.status,
						ast.vt_start,
						dbo.subtractsecond(@start_date_modSOD),
						@varSystemGMTDateTime,
						@varMaxDateTime
					FROM t_account_state ast, #updatestate_1 tmp
					WHERE ast.id_acc = tmp.id_acc
					AND ast.vt_end = @varMaxDateTime
					AND ast.status = @from_status
					AND @start_date_mod between ast.vt_start and ast.vt_end
					-- exclude the one that needs to be override
					AND ast.vt_start <> @start_date_modSOD
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Update the vt_end field of the Current records for the accounts
					-- when the new status is on a different day
					UPDATE t_account_state 
					SET vt_end = dbo.subtractsecond(@start_date_modSOD)
					FROM t_account_state, #updatestate_1 tmp
					WHERE tmp.id_acc = t_account_state.id_acc
					AND t_account_state.vt_end = @varMaxDateTime
					AND t_account_state.status = @from_status 
					AND @start_date_mod between t_account_state.vt_start and t_account_state.vt_end
					AND t_account_state.vt_start <> @start_date_modSOD
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- MERGE: Identify if needs to be merged with the previous record 
					INSERT INTO @table_formerge
					SELECT tmp.id_acc, status, vt_start
					FROM t_account_state ast, #updatestate_1 tmp
					WHERE ast.id_acc = tmp.id_acc
					AND ast.status = @to_status
					AND ast.vt_end = dateadd(second,-1,@start_date_modSOD)
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- MERGE: Remove the to-be-merged records
					DELETE t_account_state
					FROM t_account_state, @table_formerge mrg
					WHERE t_account_state.id_acc = mrg.id_acc
					AND t_account_state.status = mrg.status
					AND t_account_state.vt_start = mrg.vt_start
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Remove the Current records for the accounts if the new 
					-- status is from the same day
					DELETE t_account_state
					FROM t_account_state, #updatestate_1 tmp
					WHERE t_account_state.id_acc = tmp.id_acc
					AND t_account_state.vt_end = @varMaxDateTime
					AND t_account_state.status = @from_status
					AND t_account_state.vt_start = @start_date_modSOD
 					if (@@error <>0)
					begin
	  					RETURN
					end

					DELETE t_account_state_history
					FROM t_account_state_history, @table_formerge mrg
					WHERE t_account_state_history.id_acc = mrg.id_acc
					AND t_account_state_history.status = mrg.status
					AND t_account_state_history.vt_start = mrg.vt_start
					AND t_account_state_history.tt_end = @varMaxDateTime
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Insert new records to the Current table
					INSERT INTO t_account_state (
						id_acc,
						status,
						vt_start,
						vt_end)
					SELECT tmp.id_acc,
						@to_status,
						CASE WHEN mrg.vt_start IS NULL 
							THEN @start_date_modSOD
							ELSE mrg.vt_start END,
						@varMaxDateTime
					FROM #updatestate_1 tmp LEFT OUTER JOIN @table_formerge mrg
						ON mrg.id_acc = tmp.id_acc
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Insert new records to the History table

					INSERT INTO t_account_state_history (
						id_acc,
						status,
						vt_start,
						vt_end,
						tt_start,
						tt_end)
					SELECT tmp.id_acc,
						@to_status,
						CASE WHEN mrg.vt_start IS NULL 
							THEN @start_date_modSOD
							ELSE mrg.vt_start END,
						@varMaxDateTime,
						@varSystemGMTDateTime,
						@varMaxDateTime
					FROM #updatestate_1 tmp LEFT OUTER JOIN @table_formerge mrg
						ON mrg.id_acc = tmp.id_acc
 					if (@@error <>0)
					begin
	  					RETURN
					end

					select @status = 1
					RETURN
				END
				