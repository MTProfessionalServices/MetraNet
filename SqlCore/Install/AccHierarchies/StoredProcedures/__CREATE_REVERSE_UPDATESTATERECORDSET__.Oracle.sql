
				CREATE or replace PROCEDURE Reverse_UpdateStateRecordSet (
          CurrentSystemGMTDateTime DATE,
					status out INT )
				AS
					varMaxDateTime date;
                Begin

					status := -1;

					/* Set the maxdatetime into a variable*/
					varMaxDateTime := dbo.MTMaxDate;

					/* Reverse actions for the identified id_accs

					 Remove the existing set of states for these id_accs*/
					begin
					DELETE FROM t_account_state
					WHERE id_acc IN (SELECT id_acc from TMP_UPDATESTATE_1);
					exception
						when others then
						RETURN;
					end;

					/* Add the reversed set of states back for these id_accs*/
					begin
					INSERT INTO t_account_state (id_acc,status,vt_start,vt_end)
					SELECT tmp.id_acc, ash.status, ash.vt_start, ash.vt_end 
					FROM t_account_state_history ash
					INNER JOIN TMP_UPDATESTATE_1 tmp
						ON ash.id_acc = tmp.id_acc
						AND tmp.tt_end BETWEEN ash.tt_start AND ash.tt_end;
					exception
						when others then
						RETURN;
					end;

					
					/* Update the tt_end in history*/
					begin
					UPDATE t_account_state_history ash
					SET tt_end = dbo.subtractsecond(CurrentSystemGMTDateTime)
					where 
						ash.tt_end = varMaxDateTime
					and exists 
						(select 1
						FROM TMP_UPDATESTATE_1 tmp
							where tmp.id_acc = ash.id_acc); 
					exception
						when others then
						RETURN;
					end;

					/* Record these changes to the history table*/
					begin
					INSERT INTO t_account_state_history
					(id_acc,status,vt_start,vt_end,tt_start,tt_end)
					SELECT tmp.id_acc, ash.status, ash.vt_start, ash.vt_end, 
						CurrentSystemGMTDateTime, varMaxDateTime 
					FROM t_account_state_history ash
					INNER JOIN TMP_UPDATESTATE_1 tmp
						ON tmp.id_acc = ash.id_acc
						AND tmp.tt_end BETWEEN ash.tt_start AND ash.tt_end;
					exception
						when others then
						RETURN;
					end;

					status:=1;
					RETURN;
				END;
				