
              Create Or Replace Procedure WorkflowUnlockInstanceState
              (p_id_instance IN nvarchar2,
               p_id_owner nvarchar2)
            As
            BEGIN
                
                Update t_wf_InstanceState  
                Set 	id_owner = NULL,
                      dt_ownedUntil = NULL
                Where id_instance = p_id_instance AND ((id_owner = p_id_owner AND dt_ownedUntil>=to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) OR (id_owner IS NULL AND p_id_owner IS NULL )); 
            END WorkflowUnlockInstanceState;              
            