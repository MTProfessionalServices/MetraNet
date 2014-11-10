
						CREATE PROCEDURE GrantAllCapabilityToAccount
						(@aLoginName NVARCHAR(255), @aNameSpace NVARCHAR(255)) 
						as
						
						declare @polID INT
						declare @dummy int
            declare @aAccountID INT
        			begin
              SELECT @aAccountID = id_acc FROM t_account_mapper WHERE nm_login = @aLoginName AND nm_space = @aNameSpace
              IF @aAccountID IS NULL
              BEGIN
                RAISERROR('No Records found in t_account_mapper for Login Name %s and NameSpace %s', 16, 2, @aLoginName,  @aNameSpace)
              END
							SELECT @polID  = id_policy FROM T_PRINCIPAL_POLICY WHERE id_acc = @aAccountID AND policy_type = 'A'
							if (@polID is null)
								begin
								exec sp_Insertpolicy 'id_acc', @aAccountID, 'A', @polID output
								end
							end
							begin
							SELECT @dummy = id_policy FROM T_CAPABILITY_INSTANCE WHERE id_policy = @polID
							if (@dummy is null)
								begin		         
								INSERT INTO T_CAPABILITY_INSTANCE(tx_guid,id_parent_cap_instance,id_policy,id_cap_type) 
								SELECT cast('ABCD' as varbinary(16)), NULL,@polID,id_cap_type FROM T_COMPOSITE_CAPABILITY_TYPE WHERE 
								tx_name = 'Unlimited Capability'
								end
							end
				