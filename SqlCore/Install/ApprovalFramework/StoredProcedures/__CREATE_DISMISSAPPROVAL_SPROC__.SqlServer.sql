

      CREATE PROCEDURE DismissApproval
      @id_approval INT,
      @Comment varchar(255),
      @status INT OUTPUT      
      AS
      BEGIN      
	      SET NOCOUNT ON
              Declare @SQLError int


              UPDATE t_approvals 
              SET c_CurrentState = 'Dismissed',
                  /* c_Comment = @Comment, */
		  c_ChangeLastModifiedDate = getdate()
	      WHERE id_approval = @id_approval

           SELECT @SQLError = @@ERROR
		

	   IF @SQLError <> 0 
	        BEGIN
			SELECT @Status = -1
                        RETURN -1
                END
            ELSE
		BEGIN
			SELECT @Status = 0
		END

      END

	 