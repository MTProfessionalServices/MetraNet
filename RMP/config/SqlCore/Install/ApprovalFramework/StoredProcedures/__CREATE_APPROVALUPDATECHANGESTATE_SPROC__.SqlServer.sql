
	  
	CREATE PROCEDURE ApprovalUpdateChangeState
    @id_approval INT,
    @newState varchar(50),
    @expectedPreviousState varchar(50),
    @changeModificationDate DATETIME,
    @status INT OUTPUT
    
    AS
    BEGIN      
    SET NOCOUNT ON

	  declare @currentState nvarchar(50)
	  set @currentState = (select c_CurrentState from  t_approvals with (updlock) where id_approval = @id_approval)
	  
	  if (@currentState is null)
		  BEGIN
		    SELECT @status = -1  /*Invalid change id */
		    RETURN
		  END  

	  if ((@expectedPreviousState is not null) and (@currentState <> @expectedPreviousState))
		  BEGIN
		    SELECT @status = -2  /* State has changed since caller last read the change */
		    RETURN
		  END  
		
		/* Verify the state change is a valid transition */
		set @status = -3 /* Assume invalid state change and update for valid state changes */
		if (@currentState = 'Pending')
		  BEGIN
		  set @status = CASE @newState
                    WHEN 'ApprovedWaitingToBeApplied' THEN 0
                    WHEN 'Dismissed' THEN 0
                    ELSE -3
                    END
		  END
		  
		if (@currentState = 'Applied')
		  BEGIN
		  set @status = -3
		  END	

		if (@currentState = 'Dismissed')
		  BEGIN
		  set @status = -3
		  END	
		  		  
		if (@currentState = 'ApprovedWaitingToBeApplied')
		  BEGIN
		  set @status = CASE @newState
                    WHEN 'Dismissed' THEN 0
                    WHEN 'FailedToApply' THEN 0
                    WHEN 'Applied' THEN 0
                    ELSE -3
                    END
		  END		

		if (@currentState = 'FailedToApply')
		  BEGIN
		  set @status = CASE @newState
                    WHEN 'ApprovedWaitingToBeApplied' THEN 0
                    WHEN 'Dismissed' THEN 0
                    WHEN 'Pending' THEN 0 /* Details updated on change that failed to apply */
                    WHEN 'FailedToApply' THEN 0 /* Allow the state change to remain the same */
                    ELSE -3
                    END
		  END					
		
		
		if (@status = 0)
      UPDATE t_approvals SET c_CurrentState = @newState, c_ChangeLastModifiedDate = @changeModificationDate where id_approval = @id_approval
      
    END
	 