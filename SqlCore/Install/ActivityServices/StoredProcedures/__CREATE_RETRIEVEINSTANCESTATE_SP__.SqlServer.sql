
            Create Procedure [dbo].[WorkflowRetrieveInstanceState]
              @id_instance nvarchar(36),
              @id_owner nvarchar(36) = NULL,
              @dt_ownedUntil datetime = NULL,
              @result int output,
              @currentOwnerID nvarchar(36) output
              As
              Begin
                  declare @localized_string_RetrieveInstanceState_Failed_Ownership nvarchar(256)
                  set @localized_string_RetrieveInstanceState_Failed_Ownership = N'Instance ownership conflict'
                  set @result = 0
                  set @currentOwnerID = @id_owner

	              SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	              BEGIN TRANSACTION
              	
                  -- Possible workflow n_status: 0 for executing; 1 for completed; 2 for suspended; 3 for terminated; 4 for invalid

	              if @id_owner IS NOT NULL	-- if id is null then just loading readonly state, so ignore the ownership check
	              begin
		                Update [dbo].[t_wf_InstanceState]  
		                set	id_owner = @id_owner,
				              dt_ownedUntil = @dt_ownedUntil
		                where id_instance = @id_instance AND (    id_owner = @id_owner 
													               OR id_owner IS NULL 
													               OR dt_ownedUntil<getutcdate()
													              )
		                if ( @@ROWCOUNT = 0 )
		                BEGIN
			              -- RAISERROR(@localized_string_RetrieveInstanceState_Failed_Ownership, 16, -1)
			              select @currentOwnerID=id_owner from [dbo].[t_wf_InstanceState] Where id_instance = @id_instance 
			              if (  @@ROWCOUNT = 0 )
				              set @result = -1
			              else
				              set @result = -2
			              GOTO DONE
		                END
	              end
              	
                  Select state from [dbo].[t_wf_InstanceState]  
                  Where id_instance = @id_instance
                  
	              set @result = @@ROWCOUNT;
                  if ( @result = 0 )
	              begin
		              set @result = -1
		              GOTO DONE
	              end
              	
              DONE:
	              COMMIT TRANSACTION
	              RETURN

              End

        