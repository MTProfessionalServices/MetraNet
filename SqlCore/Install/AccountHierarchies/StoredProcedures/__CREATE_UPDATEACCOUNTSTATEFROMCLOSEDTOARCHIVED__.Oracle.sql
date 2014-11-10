
				CREATE OR REPLACE PROCEDURE UpdStateFromClosedToArchived (
					system_date IN DATE,
                    dt_start date,
                    dt_end date,  
                    age int,          
                    status out INT)
				AS
					varMaxDateTime DATE;
					varSystemGMTDateTimeSOD DATE;
				Begin

					status := -1;

					/* Use the true current GMT time for the tt_ dates*/
					varSystemGMTDateTimeSOD := dbo.mtstartofday(system_date);

					/* Set the maxdatetime into a variable*/
					varMaxDateTime := dbo.MTMaxDate();

					/* Save the id_acc*/
					EXECUTE IMMEDIATE ('TRUNCATE TABLE tmp_updatestate_1');
					INSERT INTO tmp_updatestate_1 (id_acc)
					SELECT ast.id_acc 
					FROM t_account_state ast
					WHERE ast.vt_end = varMaxDateTime
					AND ast.status = 'CL' 
					AND ast.vt_start BETWEEN (dbo.mtstartofday(dt_start) - age) AND 
					                         (dbo.subtractsecond(dbo.mtstartofday(dt_end) + 1) - age);

					UpdateStateRecordSet (
					system_date, varSystemGMTDateTimeSOD, 'CL', 'AR', status);

					RETURN;
				END;
				