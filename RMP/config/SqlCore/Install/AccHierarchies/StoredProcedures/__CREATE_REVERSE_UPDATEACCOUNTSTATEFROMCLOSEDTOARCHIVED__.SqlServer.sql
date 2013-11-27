
				CREATE PROCEDURE Rev_UpdStateFromClosedToArchiv (
					@system_date datetime, -- no longer used, 2-21-2003
					@dt_start datetime,
					@dt_end datetime,
					@age int,
					@status INT output)
				AS
				Begin
					declare @varMaxDateTime datetime
					-- declare @varSystemGMTDateTimeSOD datetime

					SELECT @status = -1

					-- Use the true current GMT time for the tt_ dates
					-- SELECT @varSystemGMTDateTimeSOD = dbo.mtstartofday(@system_date)

					-- Set the maxdatetime into a variable
					SELECT @varMaxDateTime = dbo.MTMaxDate()

					-- ======================================================================
					-- Identify the id_accs whose state need to be reversed to 'CL' from 'AR'

					-- Save the id_acc
					CREATE TABLE #updatestate_00 (id_acc int)
					INSERT INTO  #updatestate_00 (id_acc)
					SELECT DISTINCT ast.id_acc 
					FROM t_account_state ast
					WHERE ast.status = 'CL' 
					AND ast.vt_start BETWEEN (dbo.mtstartofday(@dt_start) - @age) AND 
					                         (DATEADD(s, -1, dbo.mtstartofday(@dt_end) + 1) - @age)
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Currently have 'AR' state
					CREATE TABLE #updatestate_0 (id_acc int, vt_start datetime, tt_start datetime)
					INSERT INTO  #updatestate_0 (id_acc, vt_start, tt_start)
					SELECT tmp.id_acc, ash.vt_start, ash.tt_start
					FROM #updatestate_00 tmp
					INNER JOIN t_account_state_history ash
						ON ash.id_acc = tmp.id_acc
						AND ash.status = 'AR'
						AND ash.tt_end = @varMaxDateTime 
						AND ash.vt_end = @varMaxDateTime 
						--AND ash.tt_start >= @system_date
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Make sure these 'AR' id_accs were immediately from the 'CL' status
					-- And save these id_accs whose state WILL be updated to a temp 
					CREATE TABLE #updatestate_1(id_acc int, tt_end datetime)
					INSERT INTO #updatestate_1 (id_acc, tt_end)
					SELECT tmp.id_acc, ash.tt_end
					FROM #updatestate_0 tmp
					INNER JOIN t_account_state_history ash
						ON ash.id_acc = tmp.id_acc
						AND ash.status = 'CL'
						AND ash.vt_start < tmp.vt_start
						AND ash.vt_end = @varMaxDateTime 
						AND ash.tt_end = DATEADD(ms, -10, tmp.tt_start)
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Reverse actions for the identified id_accs
					EXEC Reverse_UpdateStateRecordSet @system_date, @status OUTPUT

					DROP TABLE #updatestate_0
					DROP TABLE #updatestate_00
					DROP TABLE #updatestate_1
					
					--select @status=1
					RETURN
				END
				