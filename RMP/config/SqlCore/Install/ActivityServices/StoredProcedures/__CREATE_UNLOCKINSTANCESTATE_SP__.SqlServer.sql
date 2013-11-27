
            Create Procedure [dbo].[WorkflowUnlockInstanceState]
                @id_instance nvarchar(36),
                @id_owner nvarchar(36) = NULL
                As

                SET TRANSACTION ISOLATION LEVEL READ COMMITTED
                set nocount on

		                Update [dbo].[t_wf_InstanceState]  
		                Set id_owner = NULL,
			                dt_ownedUntil = NULL
		                Where id_instance = @id_instance AND ((id_owner = @id_owner AND dt_ownedUntil>=getutcdate()) OR (id_owner IS NULL AND @id_owner IS NULL ))
        