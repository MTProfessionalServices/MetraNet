          
          CREATE OR REPLACE PROCEDURE WorkflowRetrieveCompletedScope
          (p_id_completedScope nvarchar2,
           p_result OUT number,
           p_state OUT sys_refcursor
          )
          AS
          BEGIN

            open p_state for
            SELECT state FROM t_wf_CompletedScope WHERE id_completedScope=p_id_completedScope;
            p_result := sql%rowcount;
            
          END WorkflowRetrieveCompletedScope;
        