               
              Create or Replace Procedure WFRetAllInstanceDescriptions
              (p_result out sys_refcursor) 
              As 
              Begin
                /* gkc 9/27/07 add a parm type of cursor to record set */
                open p_result for 
                SELECT id_instance, tx_info, n_status, dt_nextTimer, n_blocked
                FROM t_wf_InstanceState;                
              END WFRetAllInstanceDescriptions;                           
        