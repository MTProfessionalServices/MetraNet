
              Create or Replace Procedure WorkflowRetrieveInstanceState
              (p_id_instance nvarchar2,
               p_id_owner nvarchar2,
               p_dt_ownedUntil date,
               p_result out number ,
               p_currentOwnerID out nvarchar2,
               p_state out sys_refcursor)
               As
                p_Failed_Ownership nvarchar2(256);

                Begin
                  
                p_Failed_Ownership := 'Instance ownership conflict';
                p_result := 0;
                p_currentOwnerID := p_id_owner;
                
                /* Possible workflow n_status: 0 for executing; 1 for completed; 2 for suspended; 3 for terminated; 4 for invalid */

                if p_id_owner IS NOT NULL then	/* if id is null then just loading readonly state, so ignore the ownership check */
                    begin
                        Update t_wf_InstanceState  
                          set	id_owner = p_id_owner,
                          dt_ownedUntil = p_dt_ownedUntil
                        where id_instance = p_id_instance 
                        AND (id_owner = p_id_owner 
                         OR id_owner IS NULL 
                         OR dt_ownedUntil<to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss'));
						
                        if (Sql%ROWCOUNT = 0 ) then
                          BEGIN
                            BEGIN
                              select id_owner INTO p_currentOwnerID 
                                from t_wf_InstanceState 
                              Where id_instance = p_id_instance;
                            EXCEPTION
                              WHEN NO_DATA_FOUND THEN p_currentOwnerId := NULL;
                            END;  
						  
                            if (sql%ROWCOUNT = 0) then
                                p_result := -1;
                            else
                                p_result := -2;
                            end if;
                            GOTO DONE;
                          END;									                	
                        end if; 
                    end;
                end if; 
    
                open p_state for      	
                Select state from t_wf_InstanceState Where id_instance = p_id_instance;              
                p_result := sql%ROWCOUNT;

                if (p_result = 0) then 
                  begin
                    p_result := -1;
                    GOTO DONE;
                  end;
                end if; 
          	
            <<DONE>> 

	/*        COMMIT TRANSACTION */

            RETURN;
            END WorkflowRetrieveInstanceState;
            