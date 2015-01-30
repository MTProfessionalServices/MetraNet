
					  CREATE procedure sp_InsertCapabilityInstance
						(@aGuid VARCHAR(16), @aParentInstance int, @aPolicy int, @aCapType int,
						@ap_id_prop int OUTPUT)
						as
						
						begin
            	INSERT INTO t_capability_instance (tx_guid, id_parent_cap_instance, id_policy, id_cap_type) 
            	VALUES (cast (@aGuid as varbinary(16)), @aParentInstance, @aPolicy, @aCapType)
              if (@@error <> 0) 
                begin
                select @ap_id_prop = -99
                end
              else
                begin
                select @ap_id_prop = @@identity
                end
           	end
					