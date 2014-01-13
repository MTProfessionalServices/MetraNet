
            CREATE PROCEDURE [dbo].[WorkflowInsertCompletedScope]
              @id_instance nvarchar(36),
              @id_completedScope nvarchar(36),
              @state image
              As

              SET TRANSACTION ISOLATION LEVEL READ COMMITTED
              SET NOCOUNT ON

		              UPDATE [dbo].[t_wf_CompletedScope] WITH(ROWLOCK UPDLOCK) 
		                  SET state = @state,
		                  dt_modified = getutcdate()
		                  WHERE id_completedScope=@id_completedScope 

		              IF ( @@ROWCOUNT = 0 )
		              BEGIN
			              --Insert Operation
			              INSERT INTO [dbo].[t_wf_CompletedScope] WITH(ROWLOCK)
			              VALUES(@id_instance, @id_completedScope, @state, getutcdate()) 
		              END

		              RETURN
              RETURN
        