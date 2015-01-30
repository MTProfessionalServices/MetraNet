
				CREATE PROCEDURE UpdateStateFromClosedToPFB (
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
					declare @ref_date_mod DATETIME

					select @status = -1

					-- Use the true current GMT time for the tt_ dates
					SELECT @varSystemGMTDateTime = @system_date

					-- Set the maxdatetime into a variable
					select @varMaxDateTime = dbo.MTMaxDate()

					select @varSystemGMTBDateTime = dbo.mtstartofday(@dt_start - 1)
					select @varSystemGMTEDateTime = DATEADD(s, -1, dbo.mtstartofday(@dt_end) + 1)

					-- Save those id_acc whose state MAY be updated to a temp table (had usage the previous day)
					create table #updatestate_0 (id_acc int)
					INSERT INTO #updatestate_0 (id_acc)
					SELECT DISTINCT id_acc 
					FROM (SELECT id_acc FROM t_acc_usage au
					      WHERE au.dt_crt between @varSystemGMTBDateTime and @varSystemGMTEDateTime) ttt
					-- Also save id_acc that had adjustments in the approved state
					UNION
					SELECT DISTINCT id_acc_payer AS id_acc 
  					FROM (SELECT id_acc_payer FROM t_adjustment_transaction ajt
					      WHERE  ajt.c_status = 'A' AND 
					      ajt.dt_modified between @varSystemGMTBDateTime and @varSystemGMTEDateTime) ttt
					-- Save those id_acc whose state WILL be updated to a temp 
					-- table (has CL state)
					create table #updatestate_1(id_acc int)
					INSERT INTO #updatestate_1 (id_acc)
					SELECT tmp0.id_acc 
					FROM t_account_state ast, #updatestate_0 tmp0
					WHERE ast.id_acc = tmp0.id_acc
					AND ast.vt_end = @varMaxDateTime
					AND ast.status = 'CL'

					EXECUTE UpdateStateRecordSet
					@system_date,
					@varSystemGMTDateTime,
					'CL', 'PF',
					@status OUTPUT

					DROP TABLE #updatestate_0
					DROP TABLE #updatestate_1
					
					RETURN
				END
				