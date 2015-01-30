
CREATE OR REPLACE PROCEDURE REV_UPDATESTATEFROMPFBTOCLOSED (
					id_billgroup INT,
					ref_date DATE,
					system_date DATE,
					status OUT INT )
				AS
    ref_date_mod DATE;
	varMaxDateTime DATE;
	CurrentSystemGMTDateTime DATE;
	ref_date_modSOD DATE;
    varSystemGMTDateTime DATE;
    rowcnt INT;
BEGIN
    status := -1;
    
    /* Set the maxdatetime into a variable*/
	varMaxDateTime := Dbo.Mtmaxdate;
	CurrentSystemGMTDateTime := Dbo.Getutcdate;

	IF ref_date IS NULL THEN
		ref_date_mod := system_date;
	ELSE
		ref_date_mod := ref_date;
	END IF;

	ref_date_modSOD := Dbo.mtstartofday(ref_date_mod);

	/* Save those id_acc whose state MAY be reversed to a temp table */
	DELETE tmp_updatestate_00;
	
	INSERT INTO TMP_UPDATESTATE_00 (id_acc, vt_start, tt_start)
		SELECT bg.id_acc, ash.vt_start, ash.tt_start
			FROM t_billgroup_member bg
			INNER JOIN t_billgroup_materialization bgm
			ON bg.id_materialization = bgm.id_materialization
			INNER JOIN t_usage_interval ui
			ON ui.id_interval = bgm.id_usage_interval
			INNER JOIN t_account_state_history ash
			ON ash.id_acc = bg.id_acc
			AND ash.status = 'CL'
            AND ash.tt_end = varMaxDateTime
            AND ash.tt_start > UI.dt_end
			WHERE bg.id_billgroup = id_billgroup;
			
    INSERT INTO tmp_updatestate_00 (id_acc, vt_start, tt_start)
		SELECT pa.id_payee, ash.vt_start, ash.tt_start
			FROM t_billgroup_member bg
			INNER JOIN t_billgroup_materialization bgm
			ON bg.id_materialization = bgm.id_materialization
	       	INNER JOIN t_usage_interval ui
			ON ui.id_interval = bgm.id_usage_interval
			INNER JOIN t_payment_redirection pa
		    ON pa.id_payer = bg.id_acc
			INNER JOIN t_account_state_history ash
			ON ash.id_acc = pa.id_payee
			AND ash.status = 'CL'
			AND ash.tt_end = varMaxDateTime
			AND ash.tt_start > ui.dt_end
			WHERE bg.id_billgroup = id_billgroup AND
		    pa.id_payee NOT IN (SELECT id_acc FROM tmp_updatestate_00);	

    DELETE TMP_UPDATESTATE_1;

    INSERT INTO TMP_UPDATESTATE_1 (id_acc, tt_end)
		SELECT tmp.id_acc, ash.tt_end
			FROM TMP_UPDATESTATE_00 tmp
			INNER JOIN T_ACCOUNT_STATE_HISTORY ash
			ON ash.id_acc = tmp.id_acc
			AND ash.status = 'PF'
			AND ash.vt_start < tmp.vt_start
			AND ash.vt_end = varMaxDateTime
        	AND ash.tt_end = Dbo.Subtractsecond(tmp.tt_start);
 				
  	varSystemGMTDateTime := system_date;
    SELECT COUNT(*) INTO rowcnt
		FROM TMP_UPDATESTATE_1;
 	
	IF rowcnt > 0 THEN
		DELETE TMP_UPDATESUB_1;	
	    INSERT INTO TMP_UPDATESUB_1
           SELECT sh2.id_sub, sh2.vt_end, sh2.tt_end
             FROM (SELECT sh.id_sub, sh.tt_start
                      FROM T_SUB_HISTORY sh
                      INNER JOIN TMP_UPDATESTATE_1 tmp
                      ON tmp.id_acc = sh.id_acc
                      AND sh.vt_end = Dbo.Subtractsecond(ref_date_modSOD)
                      AND sh.tt_end = varMaxDateTime
                   ) rev
             INNER JOIN T_SUB_HISTORY sh2
             ON sh2.id_sub = rev.id_sub
             AND sh2.tt_end = Dbo.Subtractsecond(rev.tt_start);

        BEGIN
                UPDATE T_SUB_HISTORY sh
                   SET tt_end = Dbo.Subtractsecond(CurrentSystemGMTDateTime)
                   WHERE
                     sh.tt_end = varMaxDateTime
                     AND EXISTS (SELECT 1
                                 FROM TMP_UPDATESUB_1 tmp
                                 WHERE tmp.id_sub = sh.id_sub);
                INSERT INTO T_SUB_HISTORY
				    (id_sub,id_sub_ext,id_acc,id_po,dt_crt,id_group,vt_start,vt_end,tt_start,tt_end )
					SELECT sh.id_sub,sh.id_sub_ext,sh.id_acc,sh.id_po,
						sh.dt_crt,sh.id_group,sh.vt_start,sh.vt_end,
						CurrentSystemGMTDateTime,varMaxDateTime
					    FROM T_SUB_HISTORY sh
						INNER JOIN TMP_UPDATESUB_1 tmp
						ON tmp.id_sub = sh.id_sub
						AND tmp.tt_end = sh.tt_end;
              
                UPDATE T_SUB sh
					SET vt_end = (SELECT tmp.vt_end
					FROM TMP_UPDATESUB_1 tmp
					WHERE tmp.id_sub = sh.id_sub)
                    WHERE EXISTS(SELECT tmp.vt_end
                    FROM TMP_UPDATESUB_1 tmp
					WHERE tmp.id_sub = sh.id_sub);
				
                
                EXCEPTION
                  WHEN OTHERS THEN
                  BEGIN
                     status := SQLCODE;
                     ROLLBACK;
   			         RETURN;
                   END;
        END;
        /* follow same pattern for t_gsubmember_historical and t_gsubmember.*/
       	DELETE TMP_UPDATEGSUB_1;
        INSERT INTO TMP_UPDATEGSUB_1(id_group, id_acc, vt_start, vt_end, tt_end)
           SELECT gh2.id_group, gh2.id_acc, gh2.vt_start, gh2.vt_end, gh2.tt_end
			FROM (SELECT gh.id_group, gh.id_acc, gh.vt_start, gh.vt_end, gh.tt_start
		  		    FROM T_GSUBMEMBER_HISTORICAL gh
					INNER JOIN TMP_UPDATESTATE_1 tmp
					ON tmp.id_acc = gh.id_acc
					AND gh.vt_end = Dbo.Subtractsecond(ref_date_modSOD)
					AND gh.tt_end = varMaxDateTime
                 ) rev
			INNER JOIN T_GSUBMEMBER_HISTORICAL gh2
			ON gh2.id_group = rev.id_group
			AND gh2.id_acc = rev.id_acc
			AND gh2.vt_start = rev.vt_start
			AND gh2.tt_end = Dbo.Subtractsecond(rev.tt_start);

		BEGIN
           UPDATE T_GSUBMEMBER_HISTORICAL gh
			SET tt_end = Dbo.Subtractsecond(CurrentSystemGMTDateTime)
			 WHERE EXISTS (SELECT 1 FROM
						    TMP_UPDATEGSUB_1 tmp
							WHERE tmp.id_group = gh.id_group
							AND tmp.id_acc = gh.id_acc
							AND tmp.vt_start = gh.vt_start
                          )
             AND gh.tt_end = varMaxDateTime;
			
           INSERT INTO T_GSUBMEMBER_HISTORICAL
				(id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
				SELECT gh.id_group, gh.id_acc, gh.vt_start, gh.vt_end,
					CurrentSystemGMTDateTime,varMaxDateTime
				FROM T_GSUBMEMBER_HISTORICAL gh
				INNER JOIN TMP_UPDATEGSUB_1 tmp
				ON tmp.id_group = gh.id_group
				AND tmp.id_acc = gh.id_acc
				AND tmp.vt_start = gh.vt_start
				AND tmp.tt_end = gh.tt_end;
    	
            UPDATE T_GSUBMEMBER gh
				SET vt_end = ( SELECT tmp.vt_end FROM
				    TMP_UPDATEGSUB_1 tmp
				WHERE tmp.id_group = gh.id_group
				AND tmp.id_acc = gh.id_acc
				AND tmp.vt_start = gh.vt_start)
                WHERE EXISTS (SELECT tmp.vt_end FROM
                TMP_UPDATEGSUB_1 tmp
				WHERE tmp.id_group = gh.id_group
				AND tmp.id_acc = gh.id_acc
				AND tmp.vt_start = gh.vt_start);
		
            EXCEPTION
                WHEN OTHERS THEN
                begin
                   status := SQLCODE;
                   rollback;
	  		       RETURN;
	  		    end;
         END;	
                       			
	END IF;				            	
    /* apply the changes to the account status */
    
    Reverse_Updatestaterecordset (system_date, status);
    if (status <> 1) THEN
        rollback;
        return;
    end if;
    commit;

END;				