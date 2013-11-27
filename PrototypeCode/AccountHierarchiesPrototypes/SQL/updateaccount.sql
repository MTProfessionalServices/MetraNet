				CREATE or REPLACE PROCEDURE UpdateStateFromPFBToClosed (
				  p_id_interval IN INTEGER,
				  p_id_acc IN INTEGER,
					p_new_status IN VARCHAR2,
					status OUT INTEGER)
				AS
				  intervalstatus VARCHAR2(255);
					cursor_id_acc int; 
				BEGIN
				  status := 0;
					BEGIN
					  SELECT
						  tx_interval_status INTO intervalstatus
						FROM
						  t_usage_interval
						WHERE
						  t_usage_interval.id_interval = p_id_interval;
						IF (intervalstatus != 'H') THEN 
						-- no need to do anything here (INTERVAL_NOT_HARD_CLOSED)
						  status := -469368826;
							RETURN;
						END IF;
					END;

					BEGIN
						declare cursor cursorvar IS 
						SELECT 
							astate.id_acc 
						FROM 
				  		t_usage_interval ui
							-- join between t_acc_usage_interval and t_usage_interval
							inner JOIN t_acc_usage_interval aui ON 
					  		ui.id_interval = aui.id_usage_interval
							-- join between t_account_state and t_acc_usage_interval
							inner JOIN t_account_state astate ON 
					  		aui.id_acc = astate.id_acc 
						WHERE
				  		ui.id_interval = p_id_interval AND
							astate.status = 'PF';
						BEGIN      
				  		OPEN cursorvar;
							loop
							FETCH cursorvar into cursor_id_acc;
					  		exit when cursorvar%notfound;
								UpdateAccountState(cursor_id_acc,'CL',NULL);
							end loop;    
							CLOSE cursorvar;
						END;
      		END;
				END;
