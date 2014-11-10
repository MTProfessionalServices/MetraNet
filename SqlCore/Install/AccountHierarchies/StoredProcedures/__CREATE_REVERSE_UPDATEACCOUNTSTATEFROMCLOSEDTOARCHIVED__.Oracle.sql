
				CREATE or replace PROCEDURE Rev_UpdStateFromClosedToArchiv (
					system_date date, /* no longer used, 2-21-2003*/
					dt_start date,
					dt_end date,
					age int,
					status out INT )
				AS
					varMaxDateTime date;
                Begin


					status := -1;

					/* Use the true current GMT time for the tt_ dates
					-- SELECT @varSystemGMTDateTimeSOD = dbo.mtstartofday(system_date)
					-- Set the maxdatetime into a variable*/
					varMaxDateTime := dbo.MTMaxDate;

					/* ======================================================================
					 Identify the id_accs whose state need to be reversed to 'CL' from 'AR'

					 Save the id_acc*/

                    execute immediate 'truncate table tmp_updatestate_0';
                    execute immediate 'truncate table tmp_updatestate_00';
					execute immediate 'truncate TABLE tmp_updatestate_1';

					begin
					INSERT INTO  tmp_updatestate_0 (id_acc)
					SELECT DISTINCT ast.id_acc 
					FROM t_account_state ast
					WHERE ast.status = 'CL' 
					AND ast.vt_start BETWEEN (dbo.mtstartofday(dt_start) - age) AND 
					                         (dbo.subtractsecond(dbo.mtstartofday(dt_end) + 1) - age);
 					exception
                        when others then
	  					RETURN;
					end;

					/* Currently have 'AR' state*/
					begin
					INSERT INTO  tmp_updatestate_00 (id_acc, vt_start, tt_start)
					SELECT tmp.id_acc, ash.vt_start, ash.tt_start
					FROM tmp_updatestate_0 tmp
					INNER JOIN t_account_state_history ash
						ON ash.id_acc = tmp.id_acc
						AND ash.status = 'AR'
						AND ash.tt_end = varMaxDateTime 
						AND ash.vt_end = varMaxDateTime ;
 					exception
                        when others then
	  					RETURN;
					end;

					/* Make sure these 'AR' id_accs were immediately from the 'CL' status
					 And save these id_accs whose state WILL be updated to a temp */
					begin
					INSERT INTO tmp_updatestate_1 (id_acc, tt_end)
					SELECT tmp.id_acc, ash.tt_end
					FROM tmp_updatestate_00 tmp
					INNER JOIN t_account_state_history ash
						ON ash.id_acc = tmp.id_acc
						AND ash.status = 'CL'
						AND ash.vt_start < tmp.vt_start
						AND ash.vt_end = varMaxDateTime 
						AND ash.tt_end = dbo.subtractsecond(tmp.tt_start);
 					exception
                        when others then
	  					RETURN;
					end;

					/* Reverse actions for the identified id_accs*/
					Reverse_UpdateStateRecordSet (system_date, status);

					execute immediate 'truncate TABLE tmp_updatestate_00';
					execute immediate 'truncate TABLE tmp_updatestate_0';
					execute immediate 'truncate TABLE tmp_updatestate_1';
					
					/*select status=1*/
					RETURN;
				END;
				