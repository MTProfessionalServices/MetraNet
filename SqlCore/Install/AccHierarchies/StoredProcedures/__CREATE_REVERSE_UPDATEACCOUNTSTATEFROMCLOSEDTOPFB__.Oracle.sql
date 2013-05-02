
				CREATE OR REPLACE PROCEDURE Rev_Updatestatefromclosedtopfb (
					system_date DATE,
					dt_start DATE,
					dt_end DATE,
					status OUT INT )
				AS
					varMaxDateTime        DATE;
					varSystemGMTDateTime  DATE; 
					varSystemGMTBDateTime DATE;  
					varSystemGMTEDateTime DATE; 
                BEGIN

					status := -1;

					/* Use the true current GMT time for the tt_ dates*/
					varSystemGMTDateTime := system_date;

					/* Set the maxdatetime into a variable*/
					varMaxDateTime := Dbo.Mtmaxdate;

					varSystemGMTBDateTime := Dbo.mtstartofday(dt_start - 1);
					varSystemGMTEDateTime := Dbo.Subtractsecond(Dbo.mtstartofday(dt_end) + 1);

                    EXECUTE IMMEDIATE 'truncate TABLE tmp_updatestate_00';
					EXECUTE IMMEDIATE 'truncate table tmp_updatestate_0';
					EXECUTE IMMEDIATE 'truncate TABLE tmp_updatestate_1';


					/* ======================================================================
					 Identify the id_accs whose state need to be reversed to 'CL' from 'PF'

					-- Save those id_acc whose state MAY be updated to a temp table
					-- (had usage between dt_start and dt_end)*/
					
					BEGIN
                        INSERT INTO  TMP_UPDATESTATE_0 (id_acc)
                        SELECT DISTINCT id_acc 
                        FROM (SELECT id_acc FROM T_ACC_USAGE au
                              WHERE au.dt_crt BETWEEN varSystemGMTBDateTime AND varSystemGMTEDateTime) ttt
                        /* consider adjustments as well as usage*/
                        UNION 
                          SELECT DISTINCT id_acc_payer AS id_acc
                        FROM (SELECT id_acc_payer FROM T_ADJUSTMENT_TRANSACTION ajt
                        WHERE  ajt.c_status = 'A' AND 
                            ajt.dt_modified BETWEEN varSystemGMTBDateTime AND varSystemGMTEDateTime) ttt;
 					EXCEPTION
                        WHEN OTHERS THEN
	  					RETURN;
					END;

					/* Currently have 'PF' state*/
                    BEGIN
					INSERT INTO  tmp_updatestate_00 (id_acc, vt_start, tt_start)
					SELECT tmp.id_acc, ash.vt_start, ash.tt_start
					FROM TMP_UPDATESTATE_0 tmp
					INNER JOIN T_ACCOUNT_STATE_HISTORY ash
						ON ash.id_acc = tmp.id_acc
						AND ash.status = 'PF'
						AND ash.tt_end = varMaxDateTime 
						AND ash.tt_start >= system_date;
 					EXCEPTION
                        WHEN OTHERS THEN
	  					RETURN;
					END;

					/* Make sure these 'PF' id_accs were immediately from the 'CL' status
					 And save these id_accs whose state WILL be updated to a temp */
                    BEGIN
					INSERT INTO TMP_UPDATESTATE_1 (id_acc, tt_end)
					SELECT tmp.id_acc, ash.tt_end
					FROM tmp_updatestate_00 tmp
					INNER JOIN T_ACCOUNT_STATE_HISTORY ash
						ON ash.id_acc = tmp.id_acc
						AND ash.status = 'CL'
						AND ash.vt_start < tmp.vt_start
						AND ash.vt_end = varMaxDateTime 
						AND ash.tt_end = Dbo.Subtractsecond(tmp.tt_start);
 					EXCEPTION
                        WHEN OTHERS THEN
	  					RETURN;
					END;

					/* Reverse actions for the identified id_accs*/
					Reverse_Updatestaterecordset( system_date, status );

					EXECUTE IMMEDIATE 'truncate TABLE tmp_updatestate_00';
					EXECUTE IMMEDIATE 'truncate table tmp_updatestate_0';
					EXECUTE IMMEDIATE 'truncate TABLE tmp_updatestate_1';
					
					/*select status:=1;*/
					RETURN;
				END;

				