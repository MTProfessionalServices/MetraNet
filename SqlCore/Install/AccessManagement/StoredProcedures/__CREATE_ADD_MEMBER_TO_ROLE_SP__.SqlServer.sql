
						CREATE PROCEDURE AddMemberToRole
						(@aRoleID INT,
						 @aAccountID INT,
						 @status INT OUTPUT)		
						AS
						
						Begin
						declare @accType VARCHAR(40)
						declare @polID INT
						declare @bCSRAssignableFlag VARCHAR(1)
						declare @bSubscriberAssignableFlag VARCHAR(1)
						declare @scratch INT
						select @status = 0
						-- evaluate business rules: role has to
						-- be assignable to the account type
						-- returned errors: MTAUTH_ROLE_CAN_NOT_BE_ASSIGNED_TO_SUBSCRIBER ((DWORD)0xE29F001CL) (-492896228)
						--                  MTAUTH_ROLE_CAN_NOT_BE_ASSIGNED_TO_CSR ((DWORD)0xE29F001DL) (-492896227)
						SELECT @accType = atype.name FROM T_ACCOUNT account inner join t_account_type atype on account.id_type = atype.id_type
						                  WHERE id_acc = @aAccountID
						SELECT @bCSRAssignableFlag = csr_assignable, 
						@bSubscriberAssignableFlag = subscriber_assignable  
						FROM T_ROLE WHERE id_role = @aRoleID
						IF (UPPER(@accType) <> 'SYSTEMACCOUNT') 
						begin
						IF (UPPER(@bSubscriberAssignableFlag) = 'N')
							begin
      				  select @status = -492896228
							  RETURN
							END
            END
						ELSE
						  begin
							IF UPPER(@bCSRAssignableFlag) = 'N' 
								begin
								select @status = -492896227
								RETURN
								END
							END
					
						--Get policy id for this account. sp_InsertPolicy will either
						--insert a new one or get existing one
						exec Sp_Insertpolicy 'id_acc', @aAccountID,'A', @polID output
						-- make the stored proc idempotent, only insert mapping record if
						-- it's not already there
						begin
							SELECT @scratch = id_policy FROM T_POLICY_ROLE WHERE id_policy = @polID AND id_role = @aRoleID
							if @scratch is null
								begin
								INSERT INTO T_POLICY_ROLE (id_policy, id_role) VALUES (@polID, @aRoleID)
								end
						end
						select @status = 1
						END 
       