
            CREATE PROCEDURE [dbo].[WFRetNonblockInstanceStateIds]
              @id_owner nvarchar(36) = NULL,
              @dt_ownedUntil datetime = NULL,
              @now datetime
              AS
                  SELECT id_instance FROM [dbo].[t_wf_InstanceState] WITH (TABLOCK,UPDLOCK,HOLDLOCK)
                  WHERE n_blocked=0 AND n_status<>1 AND n_status<>3 AND n_status<>2 -- not n_blocked and not completed and not terminated and not suspended
 		              AND ( id_owner IS NULL OR dt_ownedUntil<getutcdate() )
                  if ( @@ROWCOUNT > 0 )
                  BEGIN
                      -- lock the table entries that are returned
                      Update [dbo].[t_wf_InstanceState]  
                      set id_owner = @id_owner,
	                  dt_ownedUntil = @dt_ownedUntil
                      WHERE n_blocked=0 AND n_status<>1 AND n_status<>3 AND n_status<>2
 		              AND ( id_owner IS NULL OR dt_ownedUntil<getutcdate() )
              	
                  END
        