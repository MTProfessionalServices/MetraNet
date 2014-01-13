
        CREATE Or REPLACE PROCEDURE WorkflowDeleteCompletedScope
        (p_id_completedScope nvarchar2)
        AS
        Begin               
            DELETE FROM t_wf_CompletedScope WHERE id_completedScope=p_id_completedScope;
        END WorkflowDeleteCompletedScope;
        