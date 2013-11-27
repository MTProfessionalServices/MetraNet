

      CREATE PROCEDURE IsApprovalPending
      @ChangeType varchar(100),
      @UniqueItemId varchar(100),
      @Status int output 
      
      AS
      DECLARE @PendingApprovalCount int      
      SET @Status = 0
      BEGIN	
	  
	SELECT @PendingApprovalCount = isnull(count(*),0) 
        FROM t_approvals 
        WHERE c_changetype = @ChangeType 
        AND c_UniqueItemId = @UniqueItemId 
        AND c_CurrentState = 'Pending'      
 
 
        IF @PendingApprovalCount > 0
        BEGIN 
       		SELECT @Status = 1 
        END

    END
	 