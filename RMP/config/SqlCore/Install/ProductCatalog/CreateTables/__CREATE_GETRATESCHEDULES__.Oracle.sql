
            CREATE OR REPLACE PROCEDURE GetRateSchedules (
                id_acc IN INT,
                acc_cycle_id IN INT,
                default_pl IN INT,
                RecordDate IN DATE,
                id_pi_template IN INT,
                EFF_CUR OUT sys_refcursor)
            AS
                /* real stored procedure code starts here */
                /* only count rows on the final select. */
                winner_type INT;
                winner_row INT;
                winner_begin DATE;
                /* Don't actually need the @winner end since it is not used */
                /* to test overlapping effective dates */

                /* CursorVar CURSOR */
                COUNT INT;
                i INT := 0;
                tempID INT;
                tempStartType INT;
                temp_begin DATE;
                temp_b_offset INT;
                tempEndType INT;
                temp_end DATE;
                temp_e_offset INT;

                sub_begin DATE;
                sub_end DATE;

                /* unused stuff until temporary table insertion */
                id_sched INT;
                dt_mod DATE;
                id_po INT;
                id_paramtable INT;
                id_pricelist INT;
                id_sub INT;
                id_pi_instance INT;

                currentptable INT;
                currentpo INT;
                currentsub INT;

                /* winner variables */
                win_id_sched INT;
                win_dt_mod DATE;
                win_id_paramtable INT;
                win_id_pricelist INT;
                win_id_sub INT;
                win_id_po INT;
                win_id_pi_instance INT;

                /* declare our cursor. Is there anything special here for performance around STATIC vs. DYNAMIC? */
                CURSOR CursorVar  IS
                        /* this query is pretty tricky.  It is the union of all of the possible rate schedules */
                        /* on the resolved product offering AND the intersection of the  */
                        /* default account pricelist and parameter tables for the priceable item type. */
                        SELECT 						
                        T_RSCHED.id_sched,T_RSCHED.dt_mod,
                        tm.id_po,tm.id_pi_instance,tm.id_paramtable, tm.id_pricelist,tm.id_sub
                        ,te.n_begintype,te.dt_start, te.n_beginoffset,te.n_endtype,te.dt_end,te.n_endoffset
                        ,T_SUB.vt_start dt_start,T_SUB.vt_end dt_end
                        FROM T_PL_MAP tm
                        INNER JOIN T_SUB ON T_SUB.id_acc= GetRateSchedules.id_acc
                        INNER JOIN T_RSCHED ON T_RSCHED.id_pricelist = tm.id_pricelist AND T_RSCHED.id_pt =tm.id_paramtable AND
                        T_RSCHED.id_pi_template = GetRateSchedules.id_pi_template
                        INNER JOIN T_EFFECTIVEDATE te ON te.id_eff_date = T_RSCHED.id_eff_date
                        WHERE tm.id_po = T_SUB.id_po AND tm.id_pi_template = GetRateSchedules.id_pi_template 
                        AND (tm.id_acc = GetRateSchedules.id_acc OR tm.id_sub IS NULL)
                        AND (T_SUB.vt_start <= RecordDate AND RecordDate <= T_SUB.vt_end)
                        UNION ALL
                        SELECT tr.id_sched,tr.dt_mod,
                        NULL,NULL,map.id_pt,default_pl,NULL,
                        te.n_begintype,te.dt_start,te.n_beginoffset,te.n_endtype,te.dt_end,te.n_endoffset
                        ,NULL,NULL
                        FROM T_RSCHED tr
                        INNER JOIN T_EFFECTIVEDATE te ON te.id_eff_date = tr.id_eff_date
                        /* throw out any default account pricelist rate schedules that use subscription relative effective dates */
                        AND te.n_begintype <> 2
                        /* XXX fix this by passing in the instance ID */
                        INNER JOIN T_PI_TEMPLATE ON id_template = GetRateSchedules.id_pi_template
                        INNER JOIN T_PI_RULESETDEF_MAP map ON map.id_pi = T_PI_TEMPLATE.id_pi
                        WHERE tr.id_pt = map.id_pt AND tr.id_pricelist = default_pl AND tr.id_pi_template = GetRateSchedules.id_pi_template;
            /* 								order by tm.id_paramtable,tm.id_sub desc,tm.id_po desc; */
                        /* the ordering is very important.  The following algorithm depends on the fact */
                        /* that ICB rates will show up first (rows that don't have a NULL subscription value), */
                        /* normal product offering rates next, and thirdly the default account pricelist rate schedules */
                        
                BEGIN
                    OPEN CursorVar;
                    /* below line not required */
                    /* select @count = @@cursor_rows */
                    LOOP 
                            FETCH CursorVar INTO 
                            /* rate schedule stuff */
                            id_sched,dt_mod
                            /* plmap */
                            ,id_po,id_pi_instance,id_paramtable,id_pricelist,id_sub
                            /* effectivedate rate schedule */
                            ,tempStartType,temp_begin,temp_b_offset,tempEndType,temp_end,temp_e_offset
                            /* effective date from subscription */
                            ,sub_begin,sub_end;
                            
                            /* set @i = (select @i + 1) */
                            
                            IF(currentptable IS NULL) THEN
                                currentptable := id_paramtable;
                                currentpo := id_po;
                                currentsub := id_sub;
                            END IF;
                            
                            IF(currentpTable != id_paramtable OR currentsub != NVL(id_sub,-1) OR currentpo != NVL(id_po,-1)) THEN
                                IF winner_row IS NOT NULL THEN 
                                    /* insert winner record into table variable */
                                    INSERT INTO TEMPEFF VALUES (win_id_sched,win_dt_mod,win_id_paramtable,
                                    win_id_pricelist,win_id_sub,win_id_po,win_id_pi_instance);
                                END IF;
                                /* clear out winner values */
                                winner_type := NULL;
                                winner_row := NULL;
                                winner_begin := NULL;
                            END IF;
                            /* set our current parametertable */
                            currentpTable := id_paramtable;
                            currentpo := id_po;
                            currentsub := id_sub;
                            
                            /* step : convert non absolute dates into absolute dates.  Only have to  */
                            /* deal with subscription relative and usage cycle relative */
                            
                            /* subscription relative.  Add the offset of the rate schedule effective date to the */
                            /* start date of the subscription.  This code assumes that subscription effective dates */
                            /* are absolute or have already been normalized */
                            
                            IF(tempStartType = 2) THEN 
                                temp_begin := sub_begin + temp_b_offset;
                            END IF;
                            IF(tempEndType = 2) THEN 
                                temp_end := Dbo.MTEndOfDay(temp_e_offset + sub_begin);
                            END IF;
                            
                            
                            /* usage cycle relative */
                            /* The following query will only return a result if both the beginning  */
                            /* and the end start dates are somewhere in the past.  We find the date by */
                            /* finding the interval where our date lies and adding 1 second the end of that  */
                            /* interval to give us the start of the next.  If the startdate query returns NULL, */
                            /* we can simply reject the result since the effective date is in the future.  It is  */
                            /* OK for the enddate to be NULL.  Note: We expect that we will always be able to find */
                            /* an old interval in t_usage_interval and DO NOT handle purged records */
                            
                            IF(tempStartType = 3) THEN 
                                temp_begin := Dbo.NextDateAfterBillingCycle(id_acc,temp_begin);
                            END IF;

                            IF(tempStartType = 3 AND temp_begin IS NULL) THEN 
                                /* restart to the beginning of the while loop */
                                NULL;
                            ELSE	
                                       
                                
                                IF(tempEndType = 3) THEN 
                                    temp_end := Dbo.NextDateAfterBillingCycle(id_acc,temp_end);
                                END IF;
                                
                                /* step : perform date range check */
                                IF( RecordDate >= NVL(temp_begin,RecordDate) AND RecordDate <= NVL(temp_end,RecordDate)) THEN 
                                /* step : check if there is an existing winner */
                                    
                                    /* if no winner always populate */
                                    IF( (winner_row IS NULL) OR
                                    /* start into the complicated winner logic used when there are multiple */
                                    /* effective dates that apply.  The winner is the effective date with the latest */
                                    /* start date */
                                    
                                    /* Anything overrides a NULL start date */
                                    (tempStartType != 4 AND winner_type = 4) OR
                                    /* subscription relative overrides anything else */
                                    (winner_type != 2 AND tempStartType = 2) OR
                                    /* check for duplicate subscription relative, pick one with latest start date */
                                    (winner_type = 2 AND tempStartType = 2 AND winner_begin < temp_begin) OR
                                    /* check if usage cycle or absolute, treat as equal */
                                    ((winner_type = 1 OR winner_type = 3) AND (tempStartType = 1 OR tempStartType = 3) 
                                    AND winner_begin < temp_begin)
                                    ) THEN /* end if */
                                    
                                    winner_type := tempStartType;
                                    winner_row := i;
                                    winner_begin := temp_begin;
                                    
                                    win_id_sched := id_sched;
                                    win_dt_mod := dt_mod;
                                    win_id_paramtable := id_paramtable;
                                    win_id_pricelist := id_pricelist;
                                    win_id_sub := id_sub;
                                    win_id_po := id_po;
                                    win_id_pi_instance := id_pi_instance;
                                    END IF;
                                END IF;
                            END IF;	
                    END LOOP;
                    
                    
                    
                    
                    
                    
                    /* step : Dump the last remaining winner into the temporary table */
                    IF winner_row IS NOT NULL THEN 
                        INSERT INTO TEMPEFF VALUES (win_id_sched,win_dt_mod,win_id_paramtable,
                        win_id_pricelist,win_id_sub,win_id_po,win_id_pi_instance);
                    END IF;
                    
                    CLOSE CursorVar;
                    /* DEALLOCATE @CursorVar */
                    
                    /* step : if we have any results, get the results from the temp table */
                    /* SET NOCOUNT OFF */
                    OPEN EFF_CUR FOR SELECT * FROM TEMPEFF;
            END GetRateSchedules;
	 