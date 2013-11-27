
			  CREATE or replace procedure DeletePITemplate
				 (p_piTemplateID int, p_status out int )
				as
					l_aj_id int;
                    l_id_pi_template int;
                    l_sched_id int;
                    pt_status int;
                    l_kind int;
                    l_ep_tablename varchar2(200);
                    l_ep_delstmt varchar2(255);
					l_unit_name_id int;
					l_unit_disp_name_id int;
					l_adj_trans_count int;
                BEGIN
				
					/* Determine the PI instance kind */
                	Select  n_kind into l_kind from t_base_props where id_prop = p_piTemplateID;
					
					IF(l_kind = 10 or l_kind = 15) THEN
						p_status := -10;
						return;
					END IF;

					/* Check to see if adjustment transactions exist for any ajustment instances on this piInstance */
						select count(adjTrans.id_adj_trx) into l_adj_trans_count
						from
							t_adjustment_transaction adjTrans 
							inner join
							t_adjustment a on adjTrans.id_aj_instance = a.id_prop
						where
							a.id_pi_instance = p_piTemplateID;
							
					IF(l_adj_trans_count > 0) THEN
						p_status := -20;
						return;
					END IF;
					
					DECLARE CURSOR ajCursor IS
						select id_prop from t_adjustment where id_pi_template = p_piTemplateID;
		
										BEGIN
						OPEN ajCursor;
						IF ajCursor%ISOPEN THEN
							LOOP
								FETCH ajCursor into l_aj_id;
								EXIT WHEN ajCursor%NOTFOUND;
						
								DELETE FROM t_aj_template_reason_code_map where id_adjustment = l_aj_id;
								
								Delete from t_adjustment where id_prop = l_aj_id;
								
								DeleteBaseProps(l_aj_id);
							END LOOP;
						END IF;
						CLOSE ajCursor;
					END;

					/* Fetch all parameter tables.
					 Delete all remaining Rate Schedules (There should not be any rate schedules on non-shared pls because there
					 should not be any PI instances) */
					DECLARE CURSOR rsCursor IS
						SELECT	rs.id_sched
						FROM	t_rsched rs
						INNER JOIN t_pl_map pl ON (rs.id_pt = pl.id_paramtable)
						WHERE	pl.id_pi_template = p_piTemplateID;
	
					BEGIN
                        OPEN rsCursor;
                        IF rsCursor%ISOPEN THEN
                        LOOP
                            FETCH rsCursor INTO l_sched_id;
                            EXIT WHEN rsCursor%NOTFOUND;
                            DeleteRateSchedule(l_sched_id, pt_status);
                        END LOOP;
                        END IF;
                        CLOSE rsCursor;
                    END; 	

                	/* Delete PI Instance from PL Map removing it from the PO */
                	Delete from t_pl_map where id_pi_instance = p_piTemplateID;


                	/*	 Delete kind specific properties */
	               	IF(l_kind = 25)
                    THEN
                		Delete from t_recur_enum where id_prop = p_piTemplateID;
                	
						select n_unit_name, n_unit_display_name 
							into l_unit_name_id, l_unit_disp_name_id 
						from t_recur where id_prop = p_piTemplateID;
						
					Elsif(l_kind = 40 or l_kind = 15)
					THEN
						/* Delete counters */
						RemoveCountersForPI( p_piTemplateID );
					END IF;


			/* Delete Extended Properties */
			DECLARE CURSOR epTables IS SELECT nm_ep_tablename from t_ep_map where id_principal = case when (l_kind = 25) then 20 else l_kind END;
            BEGIN
                OPEN epTables;
                IF epTables%ISOPEN THEN
                LOOP
                    FETCH epTables INTO l_ep_tablename;
                    EXIT WHEN epTables%NOTFOUND;
                    l_ep_delstmt := 'DELETE FROM ' || l_ep_tablename || ' where id_prop = ' || CAST(p_piTemplateID AS varchar2);
                    EXECUTE IMMEDIATE l_ep_delstmt;
                    
                END LOOP;
                END IF;
                CLOSE epTables;
            END;			

			IF(l_kind=25)
			THEN
				delete from t_description where id_desc = l_unit_name_id;
				delete from t_description where id_desc = l_unit_disp_name_id;
			END IF;
			
			/* Delete base props */
			DeleteBaseProps(p_piTemplateID);		
			
			p_status := 0;
end;

