
				CREATE PROCEDURE Rev_Updatestatefromclosedtopfb(
					@system_date datetime,
					@dt_start datetime,
					@dt_end datetime,
					@status INT output)
				AS
				Begin
					declare @varMaxDateTime datetime
					declare @varSystemGMTDateTime datetime 
					declare @varSystemGMTBDateTime datetime  
					declare @varSystemGMTEDateTime datetime 

					select @status = -1

					-- Use the true current GMT time for the tt_ dates
					SELECT @varSystemGMTDateTime = @system_date

					-- Set the maxdatetime into a variable
					select @varMaxDateTime = dbo.MTMaxDate()

					select @varSystemGMTBDateTime = dbo.mtstartofday(@dt_start - 1)
					select @varSystemGMTEDateTime = DATEADD(s, -1, dbo.mtstartofday(@dt_end) + 1)

					-- ======================================================================
					-- Identify the id_accs whose state need to be reversed to 'CL' from 'PF'

					-- Save those id_acc whose state MAY be updated to a temp table
					-- (had usage between @dt_start and @dt_end)
					CREATE TABLE #updatestate_00 (id_acc int)
					INSERT INTO  #updatestate_00 (id_acc)
					SELECT DISTINCT id_acc 
					FROM (SELECT id_acc FROM t_acc_usage au
					      WHERE au.dt_crt between @varSystemGMTBDateTime and @varSystemGMTEDateTime) ttt
					-- consider adjustments as well as usage
					UNION 
					  SELECT DISTINCT id_acc_payer AS id_acc
  					FROM (SELECT id_acc_payer FROM t_adjustment_transaction ajt
					WHERE  ajt.c_status = 'A' AND 
						ajt.dt_modified between @varSystemGMTBDateTime and @varSystemGMTEDateTime) ttt
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Currently have 'PF' state
					CREATE TABLE #updatestate_0 (id_acc int, vt_start datetime, tt_start datetime)
					INSERT INTO  #updatestate_0 (id_acc, vt_start, tt_start)
					SELECT tmp.id_acc, ash.vt_start, ash.tt_start
					FROM #updatestate_00 tmp
					INNER JOIN t_account_state_history ash
						ON ash.id_acc = tmp.id_acc
						AND ash.status = 'PF'
						AND ash.tt_end = @varMaxDateTime 
						AND ash.tt_start >= @system_date
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Make sure these 'PF' id_accs were immediately from the 'CL' status
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
				