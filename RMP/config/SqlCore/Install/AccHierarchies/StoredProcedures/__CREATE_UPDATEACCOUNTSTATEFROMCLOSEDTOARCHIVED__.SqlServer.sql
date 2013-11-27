
				CREATE PROCEDURE UpdStateFromClosedToArchived (
					@system_date datetime,
					@dt_start datetime,
					@dt_end datetime,
					@age int,
					@status INT output)
				AS
				Begin
					declare @varMaxDateTime datetime
					declare @varSystemGMTDateTimeSOD datetime

					SELECT @status = -1

					-- Use the true current GMT time for the tt_ dates
					SELECT @varSystemGMTDateTimeSOD = dbo.mtstartofday(@system_date)

					-- Set the maxdatetime into a variable
					SELECT @varMaxDateTime = dbo.MTMaxDate()

					-- Save the id_acc
					CREATE TABLE #updatestate_1(id_acc int)
					INSERT INTO #updatestate_1 (id_acc)
					SELECT ast.id_acc 
					FROM t_account_state ast
					WHERE ast.vt_end = @varMaxDateTime
					AND ast.status = 'CL' 
					AND ast.vt_start BETWEEN (dbo.mtstartofday(@dt_start) - @age) AND 
					                         (DATEADD(s, -1, dbo.mtstartofday(@dt_end) + 1) - @age)

					EXECUTE UpdateStateRecordSet
					@system_date,
					@varSystemGMTDateTimeSOD,
					'CL', 'AR',
					@status OUTPUT

					DROP TABLE #updatestate_1
					
					RETURN
				END
				