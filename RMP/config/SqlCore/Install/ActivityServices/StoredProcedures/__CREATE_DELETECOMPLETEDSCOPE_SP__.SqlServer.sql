
            CREATE PROCEDURE [dbo].[WorkflowDeleteCompletedScope]
              @id_completedScope nvarchar(36)
              AS
              DELETE FROM [dbo].[t_wf_CompletedScope] WHERE id_completedScope=@id_completedScope
        