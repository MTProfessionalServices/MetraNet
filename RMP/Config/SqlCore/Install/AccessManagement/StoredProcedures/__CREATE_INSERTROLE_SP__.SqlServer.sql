
					  create procedure sp_InsertRole
						(@aGuid VARBINARY(16), @aName NVARCHAR(255), @aDesc NVARCHAR(255),
						 @aCSRAssignable VARCHAR, @aSubAssignable VARCHAR, @ap_id_prop int OUTPUT)
						as
						
	          begin
             INSERT INTO t_role (tx_guid, tx_name, tx_desc, csr_assignable, subscriber_assignable) VALUES (@aGuid,
             @aName, @aDesc, @aCSRAssignable, @aSubAssignable)
						 if (@@error <> 0) 
							begin
              select @ap_id_prop = -99
              end
             else
              begin
              select @ap_id_prop = @@identity
              end
            end
				