
				CREATE OR REPLACE PROCEDURE UpdateStateRecordSet (
					system_date IN DATE,
					start_date_mod IN DATE,
					from_status IN CHAR,
					to_status IN CHAR,
					out_status OUT NUMBER)
				AS
					varMaxDateTime DATE;
					varSystemGMTDateTime DATE;
					varSystemGMTDateTimeSOD DATE;
					start_date_modSOD DATE;
 				BEGIN

					/* Set the maxdatetime into a variable*/
					varMaxDateTime := dbo.MTMaxDate;
					/* Use the true current GMT time for the tt_ dates*/
					varSystemGMTDateTime := system_date;
					varSystemGMTDateTimeSOD := dbo.mtstartofday(system_date);
					start_date_modSOD := dbo.mtstartofday(start_date_mod);
					out_status := -1;

					/* Update the tt_end field of the t_account_state_history record 
					 for the accounts*/
                    begin
                        UPDATE t_account_state_history 
                        SET tt_end = dbo.subtractsecond(varSystemGMTDateTime)
                        WHERE vt_end = varMaxDateTime
                        AND tt_end = varMaxDateTime
                        AND status = from_status
                        AND EXISTS (SELECT NULL FROM tmp_updatestate_1 tmp 
                                WHERE tmp.id_acc = t_account_state_history.id_acc);

                        /* Insert the to-be-updated Current records into the History table 
                         for the accounts, exclude the one that needs to be override*/
                            INSERT INTO t_account_state_history
                            SELECT 
                                ast.id_acc,
                                ast.status,
                                ast.vt_start,
                                start_date_modSOD+numtodsinterval(-1,'second'),
                                varSystemGMTDateTime,
                                varMaxDateTime
                            FROM t_account_state ast, tmp_updatestate_1 tmp
                            WHERE ast.id_acc = tmp.id_acc
                            AND ast.vt_end = varMaxDateTime
                            AND ast.status = from_status
                            AND start_date_mod between ast.vt_start and ast.vt_end
                            /* exclude the one that needs to be override*/
                            AND ast.vt_start <> start_date_modSOD;

                        /* Update the vt_end field of the Current records for the accounts
                         when the new status is on a different day*/
                            UPDATE t_account_state 
                            SET vt_end = start_date_modSOD+numtodsinterval(-1,'second')
                            WHERE t_account_state.vt_end = varMaxDateTime
                            AND t_account_state.status = from_status 
                            AND start_date_mod between t_account_state.vt_start and t_account_state.vt_end
                            AND t_account_state.vt_start <> start_date_modSOD
                            AND EXISTS (SELECT NULL FROM tmp_updatestate_1 tmp 
                                    WHERE tmp.id_acc = t_account_state.id_acc);
                    

                        /* MERGE: Identify if needs to be merged with the previous record */
                        EXECUTE IMMEDIATE ('TRUNCATE TABLE TMP_UPDATESTATE_FORMERGE');
                        INSERT INTO TMP_UPDATESTATE_FORMERGE
                        SELECT tmp.id_acc, ast.status, ast.vt_start
                        FROM t_account_state ast, tmp_updatestate_1 tmp
                        WHERE ast.id_acc = tmp.id_acc
                        AND ast.status = to_status
                        AND ast.vt_end = start_date_modSOD+numtodsinterval(-1,'second');
                    
                        /* MERGE: Remove the to-be-merged records*/
                        DELETE FROM t_account_state
                        WHERE EXISTS (SELECT NULL FROM TMP_UPDATESTATE_FORMERGE mrg 
                                WHERE t_account_state.id_acc = mrg.id_acc
                                AND t_account_state.status = mrg.status
                                AND t_account_state.vt_start = mrg.vt_start);

                        /* Remove the Current records for the accounts if the new 
                         status is from the same day*/
                        DELETE FROM t_account_state
                        WHERE t_account_state.vt_end = varMaxDateTime
                        AND t_account_state.status = from_status
                        AND t_account_state.vt_start = start_date_modSOD
                        AND EXISTS (SELECT NULL FROM tmp_updatestate_1 tmp 
                                WHERE t_account_state.id_acc = tmp.id_acc);

                        DELETE FROM t_account_state_history
                        WHERE EXISTS (SELECT NULL FROM TMP_UPDATESTATE_FORMERGE mrg 
                                WHERE t_account_state_history.id_acc = mrg.id_acc
                                AND t_account_state_history.status = mrg.status
                                AND t_account_state_history.vt_start = mrg.vt_start)
                        AND t_account_state_history.tt_end = varMaxDateTime;

                        /* Insert new records to the Current table*/
                        INSERT INTO t_account_state (
                            id_acc,
                            status,
                            vt_start,
                            vt_end)
                        SELECT tmp.id_acc,
                            to_status,
                            CASE WHEN mrg.vt_start IS NULL 
                                THEN start_date_modSOD
                                ELSE mrg.vt_start END,
                            varMaxDateTime
                        FROM tmp_updatestate_1 tmp LEFT OUTER JOIN TMP_UPDATESTATE_FORMERGE mrg
                            ON mrg.id_acc = tmp.id_acc;

    					/* Insert new records to the History table*/
                        INSERT INTO t_account_state_history (
                            id_acc,
                            status,
                            vt_start,
                            vt_end,
                            tt_start,
                            tt_end)
                        SELECT tmp.id_acc,
                            to_status,
                            CASE WHEN mrg.vt_start IS NULL 
                                THEN start_date_modSOD
                                ELSE mrg.vt_start END,
                            varMaxDateTime,
                            varSystemGMTDateTime,
                            varMaxDateTime
                        FROM tmp_updatestate_1 tmp LEFT OUTER JOIN TMP_UPDATESTATE_FORMERGE mrg
                            ON mrg.id_acc = tmp.id_acc;
    
                    exception
                        when others then
                        return;
                    end;

					out_status := 1;
					RETURN;
				END;
				