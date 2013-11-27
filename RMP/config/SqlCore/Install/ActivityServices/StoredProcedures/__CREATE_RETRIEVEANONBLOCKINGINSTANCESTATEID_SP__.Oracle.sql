
            CREATE OR REPLACE PROCEDURE WFRetNonblockInstanceStateId
            (p_id_owner nvarchar2,
            p_dt_ownedUntil date,
            p_id_instance OUT nvarchar2,
            p_found OUT number
            ) 
            AS
            BEGIN
                  /* Guarantee that no one else grabs this record between the select and update
                  SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
                   accept the default transaction isolation level of "Read Committed" 

                   Begin TRANASCTION    
                   gkc 9/27/07 get lock on ONE row... */
                  BEGIN
                    SELECT	id_instance into p_id_instance
                      FROM	t_wf_InstanceState
                      WHERE	n_blocked=0 
                        AND	n_status NOT IN ( 1,2,3 )
                        AND	(id_owner IS NULL OR dt_ownedUntil<to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss'))
                        AND rownum <=1
                        FOR update
                        NOWAIT;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN p_id_instance := NULL;
                  END;

                  /* what is going to release this lock?  */
                  IF p_id_instance IS NOT NULL then
                    BEGIN
                      UPDATE  t_wf_InstanceState  
                      SET	id_owner = p_id_owner,
                        dt_ownedUntil = p_dt_ownedUntil
                        WHERE	id_instance = p_id_instance;
			        
                      p_found := 1;
                    END;
                  ELSE
                    BEGIN
                      p_found := 0;
                    END;
                  END IF; 
        
                /*  gkc 9/27/07 ???? question do we want the commit to occur; 
                 COMMIT; */		
                END WFRetNonblockInstanceStateId;
              