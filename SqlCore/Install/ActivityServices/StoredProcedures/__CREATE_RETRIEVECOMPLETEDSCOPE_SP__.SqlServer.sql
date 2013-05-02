
            CREATE PROCEDURE WorkflowRetrieveCompletedScope
              @id_completedScope nvarchar(36),
              @result int output
              AS
              BEGIN
                  SELECT state FROM [dbo].[t_wf_CompletedScope] WHERE id_completedScope=@id_completedScope
	              set @result = @@ROWCOUNT;
              End
        