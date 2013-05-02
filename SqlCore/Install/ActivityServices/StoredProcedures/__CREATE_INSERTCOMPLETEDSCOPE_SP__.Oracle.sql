
        CREATE OR REPLACE PROCEDURE WorkflowInsertCompletedScope
        (p_id_instance nvarchar2,
        p_id_completedScope nvarchar2,
        p_state blob)
        As
        BEGIN

            /* gkc 9/27/07 if entry exists update else insert */
            MERGE INTO t_wf_CompletedScope twc 
            USING t_wf_CompletedScope twc1
            ON (twc1.id_completedScope=p_id_completedScope)
            When Matched then 
              Update
                SET twc.state = p_state,
                    twc.dt_modified = to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')
            WHEN NOT MATCHED THEN 
                INSERT (twc.ID_INSTANCE,twc.ID_COMPLETEDSCOPE,twc.STATE,twc.DT_MODIFIED)
                VALUES(p_id_instance, p_id_completedScope, p_state, to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss'));   
        END WorkflowInsertCompletedScope;
        