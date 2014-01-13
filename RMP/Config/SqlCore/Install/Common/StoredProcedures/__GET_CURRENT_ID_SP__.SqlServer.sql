
			 CREATE PROC GetCurrentID @nm_current NVARCHAR(20), 
			                           @id_current INT OUTPUT 
			 AS 
			   DECLARE @id_next INT 

			   /* Note: Always throws exception on failure */ 
			   BEGIN TRANSACTION 

			   /* Init with failure value */ 
			   SET @id_current = -99 

			   UPDATE t_current_id 
			   SET    @id_next = id_current = id_current + 1 
			   WHERE  nm_current = @nm_current 

			   IF ( ( @@ERROR != 0 ) 
			         OR ( @@ROWCOUNT != 1 ) ) 
			     BEGIN 
			         ROLLBACK TRANSACTION 

			         RAISERROR(N'T_CURRENT_ID Update failed for [%s]', 
			                   16, 
			                   1, 
			                   @nm_current) 
			     END 
			   ELSE 
			     BEGIN 
			         SET @id_current = @id_next - 1 

			         COMMIT TRANSACTION 
			     END 
			 