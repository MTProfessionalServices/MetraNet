
            CREATE PROCEDURE [dbo].[WFRetNonblockInstanceStateId]
              @id_owner nvarchar(36) = NULL,
              @dt_ownedUntil datetime = NULL,
              @id_instance nvarchar(36) = NULL output,
              @found int = 0 output
              AS
               BEGIN
		              --
		              -- Guarantee that no one else grabs this record between the select and update
		              SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
		              BEGIN TRANSACTION

              SET ROWCOUNT 1
		              SELECT	@id_instance = id_instance
		              FROM	[dbo].[t_wf_InstanceState] WITH (updlock) 
		              WHERE	n_blocked=0 
		              AND	n_status NOT IN ( 1,2,3 )
 		              AND	( id_owner IS NULL OR dt_ownedUntil<getutcdate() )
              SET ROWCOUNT 0

		              IF @id_instance IS NOT NULL
		               BEGIN
			              UPDATE	[dbo].[t_wf_InstanceState]  
			              SET		id_owner = @id_owner,
					              dt_ownedUntil = @dt_ownedUntil
			              WHERE	id_instance = @id_instance

			              SET @found = 1
		               END
		              ELSE
		               BEGIN
			              SET @found = 0
		               END

		              COMMIT TRANSACTION
               END
        