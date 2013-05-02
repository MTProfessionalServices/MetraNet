
				CREATE OR REPLACE PROCEDURE UpdateStateFromPFBToClosed (
					p_id_billgroup IN INT,
					ref_date IN DATE,
					system_date IN DATE,
					status OUT NUMBER)
				AS
					ref_date_mod DATE;
					varMaxDateTime DATE;
                    ref_date_modSOD DATE;
					varSystemGMTDateTime date;
					rowcnt int;
					/* ESR-5776 */  
					v_table_name varchar(30);
					v_sampling_ratio int;
 				BEGIN

					status := -1;																			   
					v_sampling_ratio := 20;
					
					
					
					/* Set the maxDATE into a variable*/
					varMaxDateTime := dbo.MTMaxDate;

					IF (ref_date IS NULL) THEN
						ref_date_mod := system_date;
					ELSE
						ref_date_mod := ref_date;
					END IF;

                    ref_date_modSOD := dbo.mtstartofday(ref_date_mod);

					/* Save those id_acc whose state MAY be updated to a temp table (had usage the previous day)*/
					EXECUTE IMMEDIATE ('TRUNCATE TABLE tmp_updatestate_0');
					INSERT INTO tmp_updatestate_0 (id_acc)
					SELECT id_acc
					FROM t_billgroup_member
					WHERE id_billgroup = p_id_billgroup;
					
					/* ESR-5776 analyze table */  
					v_table_name := 'tmp_updatestate_0';   
					mt_sys_analyze_table ( v_table_name ,v_sampling_ratio);
					

          /* Add the payees for the payers */
          INSERT INTO tmp_updatestate_0 (id_acc)
	        SELECT pa.id_payee 
	        FROM t_billgroup_member bgm
          INNER JOIN t_payment_redirection pa ON pa.id_payer = bgm.id_acc
          WHERE bgm.id_billgroup = p_id_billgroup AND
                ref_date_mod between pa.vt_start AND pa.vt_end AND
                pa.id_payee NOT IN (SELECT id_acc FROM tmp_updatestate_0);

					/* Save those id_acc whose state WILL be updated to a temp
					 table (has PF state)*/
					EXECUTE IMMEDIATE ('TRUNCATE TABLE tmp_updatestate_1');
					INSERT INTO tmp_updatestate_1 (id_acc)
					SELECT tmp0.id_acc
					FROM t_account_state ast, tmp_updatestate_0 tmp0
					WHERE ast.id_acc = tmp0.id_acc
					AND ast.vt_end = varMaxDateTime
					AND ast.status = 'PF'
					AND ref_date_mod BETWEEN vt_start AND vt_end;

					/* ESR-5776 analyze table */  
					v_table_name := 'tmp_updatestate_1';   
					mt_sys_analyze_table ( v_table_name ,v_sampling_ratio);

					varSystemGMTDateTime := system_date;
					select count(*) into rowcnt from tmp_updatestate_1;

					if (rowcnt > 0)
					then
					UPDATE t_sub_history
					SET tt_end = dbo.subtractsecond(varSystemGMTDateTime)
					WHERE
					/* ESR-5758 make predicate simpler per code review CR-779 */ 
					ref_date_mod <= vt_end
					AND tt_end = varMaxDateTime					       
					AND EXISTS (SELECT NULL FROM tmp_updatestate_1 tmp
							WHERE tmp.id_acc = t_sub_history.id_acc);

					INSERT INTO t_sub_history (
						id_sub,
						id_sub_ext,
						id_acc,
						id_po,
						dt_crt,
						id_group,
						vt_start,
						vt_end,
						tt_start,
						tt_end )
					SELECT
						sub.id_sub,
						sub.id_sub_ext,
						sub.id_acc,
						sub.id_po,
						sub.dt_crt,
						sub.id_group,
						sub.vt_start,
						/*ref_date_mod,*/
						/* ESR-5758 cover the case where an account starts a subscription and account is closed pending the final bill on the same day */ 
						case when dbo.subtractsecond(ref_date_modSOD) < sub.vt_start 
							then                               
								ref_date_modSOD
							else 
								dbo.subtractsecond(ref_date_modSOD) 
						end,						
						varSystemGMTDateTime,
						varMaxDateTime
					FROM t_sub sub, tmp_updatestate_1 tmp
					WHERE sub.id_acc = tmp.id_acc
					/* ESR-5758 make predicate simpler per code review CR-779 */ 
					AND ref_date_mod <= vt_end;

					/* Update the vt_end field of the Current records for the accounts*/
					UPDATE t_sub
					SET vt_end =
					/* ESR-5758 cover the case where an account starts a subscription and account is closed pending the final bill on the same day */ 
					(case when dbo.subtractsecond(ref_date_modSOD) < vt_start 
					then                               
						ref_date_modSOD
					else 
						dbo.subtractsecond(ref_date_modSOD)
					end)					
					WHERE 
					/* ESR-5758 make predicate simpler per code review CR-779 */
					ref_date_mod <= vt_end 
					AND EXISTS (SELECT NULL FROM tmp_updatestate_1 tmp
							WHERE tmp.id_acc = t_sub.id_acc);

					UPDATE t_gsubmember_historical
					SET tt_end = dbo.subtractsecond(varSystemGMTDateTime)
					WHERE 
					/* ESR-5758 make predicate simpler per code review CR-779 */ 
					ref_date_mod <= vt_end
					AND tt_end = varMaxDateTime
					AND EXISTS (SELECT NULL FROM tmp_updatestate_1 tmp
							WHERE tmp.id_acc = t_gsubmember_historical.id_acc);

					INSERT INTO t_gsubmember_historical (
						id_group,
						id_acc,
						vt_start,
						vt_end,
						tt_start,
						tt_end)
					SELECT
						gsub.id_group,
						gsub.id_acc,
						gsub.vt_start,
						ref_date_mod,
						varSystemGMTDateTime,
						varMaxDateTime
					FROM t_gsubmember gsub, tmp_updatestate_1 tmp
					WHERE gsub.id_acc = tmp.id_acc
					/* ESR-5758 make predicate simpler per code review CR-779 */ 
					AND ref_date_mod <= vt_end;
										
					/* Update the vt_end field of the Current records for the accounts*/
					UPDATE t_gsubmember
					SET vt_end = dbo.subtractsecond(ref_date_modSOD)
					WHERE 					
					/* ESR-5758 make predicate simpler per code review CR-779 */ 
					ref_date_mod <= vt_end					
					AND EXISTS (SELECT NULL FROM tmp_updatestate_1 tmp
							WHERE tmp.id_acc = t_gsubmember.id_acc);

					end if;
					UpdateStateRecordSet (system_date, ref_date_mod, 'PF', 'CL', status);

					RETURN;
				END;
				