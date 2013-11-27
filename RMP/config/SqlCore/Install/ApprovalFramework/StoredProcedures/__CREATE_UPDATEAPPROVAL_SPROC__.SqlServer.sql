

      CREATE PROCEDURE UpdateApproval
      @id_approval INT,
      @ApproverId INT,
      @ChangeModificationDate DATETIME,
      @ItemDisplayName varchar(100) = '',
      @Comment varchar(255) = '',
      /* @CurrentState varchar(50) */
      @Status INT Output
 
      AS
	
	      SET NOCOUNT ON
              Declare @SQLError int

              UPDATE t_approvals 
              SET c_ApproverId = @ApproverId,
                  c_ChangeLastModifiedDate = @ChangeModificationDate,
                  c_ItemDisplayName = @ItemDisplayName
                  /*, c_Comment = @Comment,
		  c_CurrentState = @CurrentState */
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

	 