
				CREATE OR REPLACE PROCEDURE UpdateStateFromClosedToPFB (
					system_date IN date,
                    dt_start date,
                    dt_end date,  
                    status out INT )
				AS
					varMaxDateTime date;
					varSystemGMTDateTime date;
					varSystemGMTBDateTime date ;
					varSystemGMTEDateTime date;
					ref_date_mod date;
				Begin

					status := -1;

					/* Use the true current GMT time for the tt_ dates*/
					varSystemGMTDateTime := system_date;

					/* Set the maxdate into a variable*/
					varMaxDateTime := dbo.MTMaxDate();

					varSystemGMTBDateTime := dbo.mtstartofday(dt_start - 1);
					varSystemGMTEDateTime := dbo.subtractsecond(dbo.mtstartofday(dt_end) + 1);

					/* Save those id_acc whose state MAY be updated to a temp table (had usage the previous day)*/
					EXECUTE IMMEDIATE ('TRUNCATE TABLE tmp_updatestate_0');
					INSERT INTO tmp_updatestate_0 (id_acc)
					SELECT DISTINCT id_acc 
					FROM (SELECT id_acc FROM t_acc_usage au
					      WHERE au.dt_crt between varSystemGMTBDateTime and varSystemGMTEDateTime) ttt
					/* Also save id_acc that had adjustments in the approved state*/
					UNION
					SELECT DISTINCT id_acc_payer AS id_acc 
  					FROM (SELECT id_acc_payer FROM t_adjustment_transaction ajt
					      WHERE  ajt.c_status = 'A' AND 
					      ajt.dt_modified between varSystemGMTBDateTime and varSystemGMTEDateTime) ttt;
					/* Save those id_acc whose state WILL be updated to a temp 
					 table (has CL state)*/
					EXECUTE IMMEDIATE ('TRUNCATE TABLE tmp_updatestate_1');
					INSERT INTO tmp_updatestate_1 (id_acc)
					SELECT tmp0.id_acc 
					FROM t_account_state ast, tmp_updatestate_0 tmp0
					WHERE ast.id_acc = tmp0.id_acc
					AND ast.vt_end = varMaxDateTime
					AND ast.status = 'CL';

					UpdateStateRecordSet (
					system_date, varSystemGMTDateTime, 'CL', 'PF', status);

					RETURN;
				END;
				