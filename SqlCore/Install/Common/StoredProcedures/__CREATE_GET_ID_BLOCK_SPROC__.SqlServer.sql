
    CREATE PROC GetIdBlock @block_size INT, 
                            @sequence_name NVARCHAR(20), 
    						@block_start INT OUTPUT 
    AS 
      DECLARE @block_next INT 

      /* Note: Always throws exception on failure */ 
      BEGIN TRANSACTION 

      /* Init with failure value */ 
      SET @block_start = -99 

      UPDATE t_current_id 
      SET    @block_next = id_current = id_current + @block_size 
      WHERE  nm_current = @sequence_name 

      IF ( ( @@ERROR != 0 ) 
            OR ( @@ROWCOUNT != 1 ) ) 
        BEGIN 
            ROLLBACK TRANSACTION 

            RAISERROR(N'T_CURRENT_ID Update failed for [%s]', 
                      16, 
                      1, 
                      @sequence_name) 
        END 
      ELSE 
        BEGIN 
            SET @block_start = @block_next - @block_size 

            COMMIT TRANSACTION 
        END 
    