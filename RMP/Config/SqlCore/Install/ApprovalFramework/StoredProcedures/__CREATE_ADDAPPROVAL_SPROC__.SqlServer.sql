

      CREATE PROCEDURE AddApproval
      @SubmittedDate DATETIME, 
      @SubmitterId INT,
      @ChangeType varchar(100),
      @ChangeDetails varbinary(max),
      @ItemDisplayName varchar(100) = '',
      @UniqueItemId varchar(100),
      @Comment varchar(255) = '',
      @CurrentState varchar(50),
      @AllowMultiplePendingChangesForThisChangeType bit, 
      @IdApproval INT output,
      @Status INT Output
      
      AS

	  SET NOCOUNT ON
      Declare @PendingChangeCount int, @SQLError int
      
      if (@AllowMultiplePendingChangesForThisChangeType<>1)
      BEGIN
		  select @PendingChangeCount = count(*)  
		  from t_approvals where c_changetype = @ChangeType and c_UniqueItemId = @UniqueItemId and c_CurrentState = 'Pending'
	      
		  IF (isnull(@PendingChangeCount,0) <> 0)
				BEGIN 
					SELECT @IdApproval = 0 
					SELECT @Status = -1 /* Multiple pending changes are not allowed for this change type */
					return
				END 
      END
        
      
      BEGIN
	INSERT INTO t_approvals (c_SubmittedDate, c_SubmitterId, c_ChangeType, c_ChangeDetails, c_ApproverId, c_ChangeLastModifiedDate, c_ItemDisplayName, c_UniqueItemId, c_Comment,           c_CurrentState)
		SELECT @SubmittedDate,@SubmitterId,@ChangeType, @ChangeDetails, NULL, NULL, @ItemDisplayName, @UniqueItemId, @Comment, @CurrentState 
      END

           SELECT @SQLError = @@ERROR
		

	   IF @SQLError <> 0 
	        BEGIN
			SELECT @Status = -1
                        RETURN -1
                END
            ELSE
		BEGIN
			SELECT @Status = 0
			SELECT @IdApproval = SCOPE_IDENTITY()      	      
		END

	 