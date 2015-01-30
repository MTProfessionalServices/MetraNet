
						CREATE PROCEDURE RemoveMemberFromRole
						(
            @aRoleID INT,
            @aAccountID INT,
            @status  INT OUTPUT
						)
						AS
						
						Begin
						declare @accType VARCHAR(3)
						declare @polID INT
						declare @bCSRAssignableFlag VARCHAR(1)
						declare @bSubscriberAssignableFlag VARCHAR(1)
						declare @scratch INT
						select @status = 1
						SELECT @polID = id_policy FROM T_PRINCIPAL_POLICY WHERE id_acc = @aAccountID AND policy_type = 'A'
	          -- make the stored proc idempotent, only remove mapping record if
	          -- it's there
							BEGIN
	            SELECT @scratch = id_policy FROM T_POLICY_ROLE WHERE id_policy = @polID 
							AND id_role = @aRoleID 
	            if (@scratch is null)
								begin
								  RETURN
								end
							END
						DELETE FROM T_POLICY_ROLE WHERE id_policy = @polID AND id_role = @aRoleID
						END 
        