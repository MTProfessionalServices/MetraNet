
            Create Procedure [dbo].[WFRetAllInstanceDescriptions]
            As
	            SELECT id_instance, tx_info, n_status, dt_nextTimer, n_blocked
	            FROM [dbo].[t_wf_InstanceState]
        