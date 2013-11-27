
          Create Procedure [dbo].[WorkflowInsertInstanceState]
          @id_instance nvarchar(36),
          @state image,
          @n_status int,
          @n_unlocked int,
          @n_blocked int,
          @tx_info ntext,
          @id_owner nvarchar(36) = NULL,
          @dt_ownedUntil datetime = NULL,
          @dt_nextTimer datetime,
          @result int output,
          @currentOwnerID nvarchar(36) output
          As
              declare @localized_string_InsertInstanceState_Failed_Ownership nvarchar(256)
              set @localized_string_InsertInstanceState_Failed_Ownership = N'Instance ownership conflict'
              set @result = 0
              set @currentOwnerID = @id_owner
              declare @now datetime
              set @now = getutcdate()

              SET TRANSACTION ISOLATION LEVEL READ COMMITTED
              set nocount on

              IF @n_status=1 OR @n_status=3
              BEGIN
	          DELETE FROM [dbo].[t_wf_InstanceState] WHERE id_instance=@id_instance AND ((id_owner = @id_owner AND dt_ownedUntil>=@now) OR (id_owner IS NULL AND @id_owner IS NULL ))
	          if ( @@ROWCOUNT = 0 )
	          begin
		          set @currentOwnerID = NULL
    		          select  @currentOwnerID=id_owner from [dbo].[t_wf_InstanceState] Where id_instance = @id_instance
		          if ( @currentOwnerID IS NOT NULL )
		          begin	-- cannot delete the instance state because of an ownership conflict
			          -- RAISERROR(@localized_string_InsertInstanceState_Failed_Ownership, 16, -1)				
			          set @result = -2
			          return
		          end
	          end
	          else
	          BEGIN
		          DELETE FROM [dbo].[t_wf_CompletedScope] WHERE id_instance=@id_instance
	          end
              END
              
              ELSE BEGIN

  	              if not exists ( Select 1 from [dbo].[t_wf_InstanceState] Where id_instance = @id_instance )
		            BEGIN
			            --Insert Operation
			            IF @n_unlocked = 0
			            begin
			               Insert into [dbo].[t_wf_InstanceState] 
			               Values(@id_instance,@state,@n_status,@n_unlocked,@n_blocked,@tx_info,@now,@id_owner,@dt_ownedUntil,@dt_nextTimer) 
			            end
			            else
			            begin
			               Insert into [dbo].[t_wf_InstanceState] 
			               Values(@id_instance,@state,@n_status,@n_unlocked,@n_blocked,@tx_info,@now,null,null,@dt_nextTimer) 
			            end
		            END
          		  
		            ELSE BEGIN

				          IF @n_unlocked = 0
				          begin
					          Update [dbo].[t_wf_InstanceState]  
					          Set state = @state,
						          n_status = @n_status,
						          n_unlocked = @n_unlocked,
						          n_blocked = @n_blocked,
						          tx_info = @tx_info,
						          dt_modified = @now,
						          dt_ownedUntil = @dt_ownedUntil,
						          dt_nextTimer = @dt_nextTimer
					          Where id_instance = @id_instance AND ((id_owner = @id_owner AND dt_ownedUntil>=@now) OR (id_owner IS NULL AND @id_owner IS NULL ))
					          if ( @@ROWCOUNT = 0 )
					          BEGIN
						          -- RAISERROR(@localized_string_InsertInstanceState_Failed_Ownership, 16, -1)
						          select @currentOwnerID=id_owner from [dbo].[t_wf_InstanceState] Where id_instance = @id_instance  
						          set @result = -2
						          return
					          END
				          end
				          else
				          begin
					          Update [dbo].[t_wf_InstanceState]  
					          Set state = @state,
						          n_status = @n_status,
						          n_unlocked = @n_unlocked,
						          n_blocked = @n_blocked,
						          tx_info = @tx_info,
						          dt_modified = @now,
						          id_owner = NULL,
						          dt_ownedUntil = NULL,
						          dt_nextTimer = @dt_nextTimer
					          Where id_instance = @id_instance AND ((id_owner = @id_owner AND dt_ownedUntil>=@now) OR (id_owner IS NULL AND @id_owner IS NULL ))
					          if ( @@ROWCOUNT = 0 )
					          BEGIN
						          -- RAISERROR(@localized_string_InsertInstanceState_Failed_Ownership, 16, -1)
						          select @currentOwnerID=id_owner from [dbo].[t_wf_InstanceState] Where id_instance = @id_instance  
						          set @result = -2
						          return
					          END
				          end
          				
		            END


              END
		          RETURN
          Return
      