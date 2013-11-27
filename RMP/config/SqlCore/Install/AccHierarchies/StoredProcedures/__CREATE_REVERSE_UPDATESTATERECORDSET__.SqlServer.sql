
				CREATE PROCEDURE Reverse_UpdateStateRecordSet (
          @CurrentSystemGMTDateTime DATETIME,
					@status INT output)
				AS
				Begin
					declare @varMaxDateTime datetime

					select @status = -1

					-- Set the maxdatetime into a variable
					select @varMaxDateTime = dbo.MTMaxDate()

					-- Reverse actions for the identified id_accs

					-- Remove the existing set of states for these id_accs
					DELETE FROM t_account_state
					WHERE id_acc IN (SELECT id_acc from #updatestate_1)
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Add the reversed set of states back for these id_accs
					INSERT INTO t_account_state (id_acc,status,vt_start,vt_end)
					SELECT tmp.id_acc, ash.status, ash.vt_start, ash.vt_end 
					FROM t_account_state_history ash
					INNER JOIN #updatestate_1 tmp
						ON ash.id_acc = tmp.id_acc
						AND tmp.tt_end BETWEEN ash.tt_start AND ash.tt_end
 					if (@@error <>0)
					begin
	  					RETURN
					end
					
					-- Update the tt_end in history
					UPDATE t_account_state_history
					SET tt_end = DATEADD(ms, -10, @CurrentSystemGMTDateTime)
					FROM t_account_state_history ash
					INNER JOIN #updatestate_1 tmp
						ON tmp.id_acc = ash.id_acc
						AND ash.tt_end = @varMaxDateTime 
 					if (@@error <>0)
					begin
	  					RETURN
					end

					-- Record these changes to the history table
					INSERT INTO t_account_state_history
					(id_acc,status,vt_start,vt_end,tt_start,tt_end)
					SELECT tmp.id_acc, ash.status, ash.vt_start, ash.vt_end, 
						@CurrentSystemGMTDateTime, @varMaxDateTime 
					FROM t_account_state_history ash
					INNER JOIN #updatestate_1 tmp
						ON tmp.id_acc = ash.id_acc
						AND tmp.tt_end BETWEEN ash.tt_start AND ash.tt_end
 					if (@@error <>0)
					begin
	  					RETURN
					end

					select @status=1
					RETURN
				END
				