             
              CREATE OR REPLACE PROCEDURE WFRetNonblockInstanceStateIds
              (p_id_owner nvarchar2,
               p_dt_ownedUntil date,
               p_now date,
              p_result out sys_refcursor
              )
              AS
              BEGIN
              OPEN p_result FOR               
              /* gkc 9/27/07 added for update nowait to lock the rows */
              SELECT id_instance FROM t_wf_InstanceState /* WITH (TABLOCK,UPDLOCK,HOLDLOCK) */
               WHERE n_blocked=0 AND n_status<>1 AND n_status<>3 AND n_status<>2  /* not n_blocked and not completed and not terminated and not suspended */
                 AND ( id_owner IS NULL OR dt_ownedUntil<to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss'))
                 FOR update
                 NOWAIT;
		 		
              if (SQL%ROWCOUNT > 0) THEN 
                  BEGIN
                  /* lock the table entries that are returned */
                    Update t_wf_InstanceState  
                        set id_owner = p_id_owner,
                            dt_ownedUntil = p_dt_ownedUntil
                    WHERE n_blocked=0 AND n_status<>1 AND n_status<>3 AND n_status<>2
                      AND ( id_owner IS NULL OR dt_ownedUntil<to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') );              	
                  END;
              END IF;
                       
            END WFRetNonblockInstanceStateIds;                             
            