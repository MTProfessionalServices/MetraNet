
        Create Or Replace Procedure WorkflowInsertInstanceState
          ( p_id_instance nvarchar2,
          p_state blob,
          p_n_status number,
          p_n_unlocked number,
          p_n_blocked number,
          p_tx_info nclob,
          p_id_owner nvarchar2,
          p_dt_ownedUntil date,
          p_dt_nextTimer date,
          p_result OUT number,
          p_currentOwnerID OUT nvarchar2
) 
AS
              p_InsertInstanceState_Failed nvarchar2(256);
              p_now date;
              p_cnt number; 
Begin
              p_result := 0;
              p_cnt := 0;
               
              p_InsertInstanceState_Failed := 'Instance ownership conflict';
              p_currentOwnerID := p_id_owner;
              p_now := to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss');

              /* SET TRANSACTION ISOLATION LEVEL READ COMMITTED; */
 
              IF p_n_status=1 OR p_n_status=3 then
                BEGIN            
	               DELETE FROM t_wf_InstanceState WHERE id_instance=p_id_instance AND ((id_owner = p_id_owner AND dt_ownedUntil>=p_now) OR (id_owner IS NULL AND p_id_owner IS NULL ));
	               IF (sql%rowcount  = 0 ) then 
	                   begin
		                    
                      BEGIN
    		                select id_owner  INTO p_currentOwnerID from t_wf_InstanceState Where id_instance = p_id_instance;
                      EXCEPTION
                        WHEN NO_DATA_FOUND THEN p_currentOwnerId := NULL;
                      END;
                      
		                  if ( p_currentOwnerID IS NOT NULL ) THEN
		                      begin	
                           /* gkc 9/27/07 leave out the RAISERERROR
                            cannot delete the instance state because of an ownership conflict
			                     RAISEERROR(p_local_str_InsertInstanceState_Failed_Ownership, 16, -1)	*/			
			                     p_result := -2;
			                     Return;
		                      end;
		                  end if;
	                   end;
	               else
	                   BEGIN
		                  DELETE FROM t_wf_CompletedScope WHERE id_instance=p_id_instance;
	                   end;
	               end if; 
                END;
                         
              ELSE 
                BEGIN                                
                    /* if not exists ( Select 1 from t_wf_InstanceState Where id_instance = p_id_instance ) then
                     gkc 9/27/07 when p_cnt = 0, is equivalent to NOT EXISTS (SELECT 1) in sql server */
                  BEGIN
                    Select 1 into p_cnt from t_wf_InstanceState Where id_instance = p_id_instance;                    
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN p_cnt := 0;
                  END;
                    
                   If p_cnt = 0 then 
		              BEGIN
			            /* Insert Operation */
			            IF p_n_unlocked = 0 then
			             begin
			               Insert INTO t_wf_InstanceState 
							(ID_INSTANCE,STATE,N_STATUS,N_UNLOCKED,N_BLOCKED,TX_INFO,DT_MODIFIED,ID_OWNER,DT_OWNEDUNTIL,DT_NEXTTIMER)
			               Values(p_id_instance,p_state,p_n_status,p_n_unlocked,p_n_blocked,p_tx_info,p_now,p_id_owner,p_dt_ownedUntil,p_dt_nextTimer);
			             end;
			            else
			             begin
			               Insert INTO t_wf_InstanceState 
							(ID_INSTANCE,STATE,N_STATUS,N_UNLOCKED,N_BLOCKED,TX_INFO,DT_MODIFIED,ID_OWNER,DT_OWNEDUNTIL,DT_NEXTTIMER)
			               Values(p_id_instance,p_state,p_n_status,p_n_unlocked,p_n_blocked,p_tx_info,p_now,p_id_owner,p_dt_ownedUntil,p_dt_nextTimer);
			             end;
			            END IF;
		              END; 
                    ELSE
                        BEGIN 
				     	IF p_n_unlocked = 0 then 
				            begin
					          Update t_wf_InstanceState  
					          Set state = p_state,
						          n_status = p_n_status,
						          n_unlocked = p_n_unlocked,
						          n_blocked = p_n_blocked,
						          tx_info = p_tx_info,
						          dt_modified = p_now,
						          dt_ownedUntil = p_dt_ownedUntil,
						          dt_nextTimer = p_dt_nextTimer
					          Where id_instance = p_id_instance AND ((id_owner = p_id_owner AND dt_ownedUntil>=p_now) OR (id_owner IS NULL AND p_id_owner IS NULL ));
					          if (sql%rowcount = 0) then
					           BEGIN
							  /* gkc 9/27/07 leave out the RAISERERROR
						           RAISERROR(p_local_str_InsertInstanceState_Failed_Ownership, 16, -1) */
                      BEGIN
						            select id_owner INTO p_currentOwnerID from t_wf_InstanceState Where id_instance = p_id_instance;
                      EXCEPTION
                        WHEN NO_DATA_FOUND THEN p_currentOwnerId := NULL;
                      END;
						          p_result := -2;
						          return;
					           END;
					          end if;
				            end;
				          else
				            	begin
					          		Update t_wf_InstanceState  
					          			Set state = p_state,
						          		n_status = p_n_status,
						          		n_unlocked = p_n_unlocked,
						          		n_blocked = p_n_blocked,
						          		tx_info = p_tx_info,
						          		dt_modified = p_now,
						          		id_owner = NULL,
						          		dt_ownedUntil = NULL,
						          		dt_nextTimer = p_dt_nextTimer
					          		Where id_instance = p_id_instance AND ((id_owner = p_id_owner AND dt_ownedUntil>=p_now) OR (id_owner IS NULL AND p_id_owner IS NULL ));                          			
									if ( sql%rowcount = 0) then 
					          			BEGIN
					          			    /* gkc 9/27/07 leave out the RAISERERROR
						          		     RAISERROR(p_local_str_InsertInstanceState_Failed_Ownership, 16, -1) */
                            BEGIN
						          			  select id_owner INTO p_currentOwnerID from t_wf_InstanceState Where id_instance = p_id_instance;
                            EXCEPTION
                              WHEN NO_DATA_FOUND THEN p_currentOwnerId := NULL;
                            END;
						          			p_result := -2;
						          			return;
					          			END;
					          			end if;									
      					        end;
                          end if;    
				        END;                           
                     end if;        				
                /* gkc 9/27/07 goes with outer begin */ 
                END;
              END IF;
          /* gkc 9/27/07 what about exception handling ?? */ 
          Return; 
END WorkflowInsertInstanceState;
      