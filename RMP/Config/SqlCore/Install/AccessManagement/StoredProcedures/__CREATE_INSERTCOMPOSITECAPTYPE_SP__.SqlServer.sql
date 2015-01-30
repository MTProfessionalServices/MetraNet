
						create procedure sp_InsertCompositeCapType 
						(@aGuid VARBINARY(16), @aName NVARCHAR(255), @aDesc NVARCHAR(255), @aProgid NVARCHAR(255), 
             @aEditor NVARCHAR(255),@aCSRAssignable VARCHAR, @aSubAssignable VARCHAR,
             @aMultipleInstances VARCHAR, @aUmbrellaSensitive VARCHAR , @ap_id_prop int OUTPUT)
						as
						
						begin
            	INSERT INTO t_composite_capability_type(tx_guid,tx_name,tx_desc,tx_progid,tx_editor,
              csr_assignable,subscriber_assignable,multiple_instances,umbrella_sensitive) VALUES (
							@aGuid, @aName, @aDesc, @aProgid, @aEditor, @aCSRAssignable,
						  @aSubAssignable, @aMultipleinstances,@aUmbrellaSensitive)
							if (@@error <> 0) 
                  begin
                  select @ap_id_prop = -99
                  end
                  else
                  begin
                  select @ap_id_prop = @@identity
                  end
        		END
				