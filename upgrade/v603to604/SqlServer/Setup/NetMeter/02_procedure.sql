use %%NETMETER%%

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

PRINT N'Altering [dbo].[WorkflowInsertInstanceState]'
GO

ALTER PROCEDURE [dbo].[WorkflowInsertInstanceState]
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

GO

PRINT N'Altering [dbo].[WorkflowUnlockInstanceState]'
GO

            Alter Procedure [dbo].[WorkflowUnlockInstanceState]
                @id_instance nvarchar(36),
                @id_owner nvarchar(36) = NULL
                As

                SET TRANSACTION ISOLATION LEVEL READ COMMITTED
                set nocount on

		                Update [dbo].[t_wf_InstanceState]  
		                Set id_owner = NULL,
			                dt_ownedUntil = NULL
		                Where id_instance = @id_instance AND ((id_owner = @id_owner AND dt_ownedUntil>=getutcdate()) OR (id_owner IS NULL AND @id_owner IS NULL ))

GO

PRINT N'Altering [dbo].[WorkflowRetrieveInstanceState]'
GO


            ALTER Procedure [dbo].[WorkflowRetrieveInstanceState]
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

GO

PRINT N'Altering [dbo].[WFRetNonblockInstanceStateIds]'
GO

            ALTER PROCEDURE [dbo].[WFRetNonblockInstanceStateIds]
              @id_owner nvarchar(36) = NULL,
              @dt_ownedUntil datetime = NULL,
              @now datetime
              AS
                  SELECT id_instance FROM [dbo].[t_wf_InstanceState] WITH (TABLOCK,UPDLOCK,HOLDLOCK)
                  WHERE n_blocked=0 AND n_status<>1 AND n_status<>3 AND n_status<>2 -- not n_blocked and not completed and not terminated and not suspended
 		              AND ( id_owner IS NULL OR dt_ownedUntil<getutcdate() )
                  if ( @@ROWCOUNT > 0 )
                  BEGIN
                      -- lock the table entries that are returned
                      Update [dbo].[t_wf_InstanceState]  
                      set id_owner = @id_owner,
	                  dt_ownedUntil = @dt_ownedUntil
                      WHERE n_blocked=0 AND n_status<>1 AND n_status<>3 AND n_status<>2
 		              AND ( id_owner IS NULL OR dt_ownedUntil<getutcdate() )
              	
                  END
GO

PRINT N'Altering [dbo].[WFRetNonblockInstanceStateId]'
GO


            ALTER PROCEDURE [dbo].[WFRetNonblockInstanceStateId]
              @id_owner nvarchar(36) = NULL,
              @dt_ownedUntil datetime = NULL,
              @id_instance nvarchar(36) = NULL output,
              @found int = 0 output
              AS
               BEGIN
		              --
		              -- Guarantee that no one else grabs this record between the select and update
		              SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
		              BEGIN TRANSACTION

              SET ROWCOUNT 1
		              SELECT	@id_instance = id_instance
		              FROM	[dbo].[t_wf_InstanceState] WITH (updlock) 
		              WHERE	n_blocked=0 
		              AND	n_status NOT IN ( 1,2,3 )
 		              AND	( id_owner IS NULL OR dt_ownedUntil<getutcdate() )
              SET ROWCOUNT 0

		              IF @id_instance IS NOT NULL
		               BEGIN
			              UPDATE	[dbo].[t_wf_InstanceState]  
			              SET		id_owner = @id_owner,
					              dt_ownedUntil = @dt_ownedUntil
			              WHERE	id_instance = @id_instance

			              SET @found = 1
		               END
		              ELSE
		               BEGIN
			              SET @found = 0
		               END

		              COMMIT TRANSACTION
               END

GO

PRINT N'Altering [dbo].[WFRetrieveExpiredTimerIds]'
GO

            ALTER PROCEDURE [dbo].[WFRetrieveExpiredTimerIds]
              @id_owner nvarchar(36) = NULL,
              @dt_ownedUntil datetime = NULL,
              @now datetime
              AS
                  SELECT id_instance FROM [dbo].[t_wf_InstanceState]
                  WHERE dt_nextTimer<@now AND n_status<>1 AND n_status<>3 AND n_status<>2 -- not n_blocked and not completed and not terminated and not suspended
                      AND ((n_unlocked=1 AND id_owner IS NULL) OR dt_ownedUntil<getutcdate() )

GO

PRINT N'Altering [dbo].[WorkflowInsertCompletedScope]'
GO

            ALTER PROCEDURE [dbo].[WorkflowInsertCompletedScope]
              @id_instance nvarchar(36),
              @id_completedScope nvarchar(36),
              @state image
              As

              SET TRANSACTION ISOLATION LEVEL READ COMMITTED
              SET NOCOUNT ON

		              UPDATE [dbo].[t_wf_CompletedScope] WITH(ROWLOCK UPDLOCK) 
		                  SET state = @state,
		                  dt_modified = getutcdate()
		                  WHERE id_completedScope=@id_completedScope 

		              IF ( @@ROWCOUNT = 0 )
		              BEGIN
			              --Insert Operation
			              INSERT INTO [dbo].[t_wf_CompletedScope] WITH(ROWLOCK)
			              VALUES(@id_instance, @id_completedScope, @state, getutcdate()) 
		              END

		              RETURN
              RETURN

GO

PRINT N'Altering [dbo].[SetPartitionOptions]'
GO

			/*
				SetPartitionOptions

				Sets values in t_usage_server.  Also adds metadata to facilitate
				treating t_acc_usage like a product view.

				@enable char(1)  -- Y if partitions enabled
				@type varchar(20) -- partition cycle type
				@datasize int		-- Size of data file in MB
				@logsize int	-- size of log file in MB

			*/
			ALTER proc SetPartitionOptions
				@enable char(1),  -- Y if partitions enabled
				@type varchar(20), -- partition cycle type
				@datasize int,		-- Size of data file in MB
				@logsize int	-- size of log file in MB
			AS
			begin

			set nocount on

			-- Error reporting and row counts
			declare @err int
			declare @rc int

			-- validate enable flag
			if lower(@enable) not in ('y', 'n') begin
				raiserror('Enbable flag must be "Y" or "N", not "%s"', 16, 1, @enable)
				return
			end

			-- get cycle id
			declare @cycle int

			-- find cycle id for a supported partition cycle
			select @cycle = uc.id_usage_cycle, @type = uct.tx_desc
			from  t_usage_cycle uc
			join t_usage_cycle_type uct
				on uct.id_cycle_type = uc.id_cycle_type
			where lower(uct.tx_desc) = lower(@type)
				and ((uc.id_cycle_type = 1 -- monthly
						and day_of_month = 31)
					or (uc.id_cycle_type = 4 -- weekly
	  					and day_of_week = 1)
					or (uc.id_cycle_type = 6  -- semi-montly
	  					and first_day_of_month = 14 and second_day_of_month = 31)
					or (uc.id_cycle_type = 7  -- quarterly
	  					and start_day = 1 and start_month = 1)
					or (uc.id_cycle_type = 3  -- daily
					))

			if (@cycle is null) begin
				raiserror('Partition type "%s" not supported.', 16, 1, @type)
				return
			end


			begin tran

				-- Update t_usage_server
				update t_usage_server set
					b_partitioning_enabled = upper(@enable),
					partition_cycle = @cycle,
					partition_type = @type,
					partition_data_size = @datasize,
					partition_log_size = @logsize
				
				set @err = @@error
				if (@err <> 0) begin
					raiserror('Cannot update t_usage_server.',1,1)
					rollback
					return
				end

				-- Treat t_acc_usage kinda like a product view
				if not exists (select * from t_prod_view where nm_table_name = 't_acc_usage')
				begin
					declare @prodid int
					declare @enumid int

					-- get the enum id for the acc_usage_table
					select @enumid = id_enum_data
					from t_enum_data
					where lower(nm_enum_data) = 'usage'

					insert t_prod_view 
						(id_view, dt_modified, nm_name, nm_table_name,b_can_resubmit_from)
						values 
						(@enumid, getdate(), 'metratech.com/acc_usage', 't_acc_usage','N')
					set @err = @@error
					set @prodid = @@identity
					if (@err <> 0) begin
						raiserror('Cannot insert to t_prod_view',1,1)
						rollback
						return
					end

					-- add acc_usage columns to t_prod_view_prop
					insert into t_prod_view_prop( 
						/*id_prod_view_prop, */id_prod_view, nm_name, nm_data_type, nm_column_name, 
						b_required, b_composite_idx, b_single_idx, b_part_of_key, b_exportable, 
						b_filterable, b_user_visible, nm_default_value, n_prop_type, nm_space, 
						nm_enum, b_core) 
					SELECT 
						--d_prod_view_prop,
						@prodid as id_prod_view,
						column_name as nm_name, 
						data_type as nm_data_type, 
						column_name as nm_column_name, 
						'Y' as b_required, 
						'N' as b_composite_idx, 
						'N' as b_single_idx, 
						'N' as b_part_of_key, 
						'Y' as b_exportable, 
						'Y' as b_filterable, 
						'Y' as b_user_visible, 
						null as nm_default_value, 	
						0 as n_prop_type, 
						null as nm_space, 
						null as nm_enum, 
						case when column_name like 'id%' then 'Y' else 'N' end as b_core 
					from information_schema.columns
					where table_name = 't_acc_usage'
					
					-- make tx_uid a uniquekey
					declare @ukid int
					declare @pvid int
					
					select @pvid = id_prod_view 
					from t_prod_view
					where nm_table_name = 't_acc_usage'
					
					insert into t_unique_cons (id_prod_view, constraint_name, nm_table_name)
						values (@pvid, 'uk_acc_usage_tx_uid', 't_uk_acc_usage_tx_uid')
					set @ukid = @@identity

					if (@err <> 0) begin
						raiserror('Cannot insert to t_unique_cons',1,1)
						rollback
						return
					end

					insert into t_unique_cons_columns
						select @ukid, id_prod_view_prop, 1
						from t_prod_view_prop
						where id_prod_view = @pvid
							and lower(nm_name) = 'tx_uid'

					if (@err <> 0) begin
						raiserror('Cannot insert to t_unique_cons_columns',1,1)
						rollback
						return
					end
				end

			commit

			return

			end

GO

PRINT N'Altering [dbo].[UpsertDescription]'
GO

		ALTER proc UpsertDescription
			@id_lang_code int,
			@a_nm_desc NVARCHAR(4000),
			@a_id_desc_in int, 
			@a_id_desc int OUTPUT
		AS
		begin
      declare @var int
			IF (@a_id_desc_in IS NOT NULL and @a_id_desc_in <> 0)
				BEGIN
					-- there was a previous entry
				UPDATE t_description
					SET
						tx_desc = ltrim(rtrim(@a_nm_desc))
					WHERE
						id_desc = @a_id_desc_in AND id_lang_code = @id_lang_code

					IF (@@RowCount=0)
					BEGIN
					  -- The entry didn't previously exist for this language code
						INSERT INTO t_description
							(id_desc, id_lang_code, tx_desc)
						VALUES
							(@a_id_desc_in, @id_lang_code, ltrim(rtrim(@a_nm_desc)))
					END

					-- continue to use old ID
					select @a_id_desc = @a_id_desc_in
				END

			ELSE
			  begin
				-- there was no previous entry
				IF (@a_nm_desc IS NULL)
				 begin
					-- no new entry
					select @a_id_desc = 0
				 end
				 ELSE
					BEGIN
						-- generate a new ID to use
						INSERT INTO t_mt_id default values
						select @a_id_desc = @@identity

						INSERT INTO t_description
							(id_desc, id_lang_code, tx_desc)
						VALUES
							(@a_id_desc, @id_lang_code, ltrim(rtrim(@a_nm_desc)))
					 END
			END 
			end
GO

PRINT N'Altering [dbo].[UpdateBaseProps]'
GO

			ALTER procedure UpdateBaseProps(
			@a_id_prop int,
			@a_id_lang int,
			@a_nm_name NVARCHAR(255),
			@a_nm_desc NVARCHAR(4000),
			@a_nm_display_name NVARCHAR(255))
		AS
		begin
      declare @old_id_name int
      declare @id_name int
      declare @old_id_desc int
      declare @id_desc int
      declare @old_id_display_name int
      declare @id_display_name int
			select @old_id_name = n_name, @old_id_desc = n_desc, 
			@old_id_display_name = n_display_name
     	from t_base_props where id_prop = @a_id_prop
			exec UpsertDescription @a_id_lang, @a_nm_name, @old_id_name, @id_name output
			exec UpsertDescription @a_id_lang, @a_nm_desc, @old_id_desc, @id_desc output
			exec UpsertDescription @a_id_lang, @a_nm_display_name, @old_id_display_name, @id_display_name output
			UPDATE t_base_props
				SET n_name = @id_name, n_desc = @id_desc, n_display_name = @id_display_name,
						nm_name = @a_nm_name, nm_desc = @a_nm_desc, nm_display_name = @a_nm_display_name
				WHERE id_prop = @a_id_prop
		END
GO

PRINT N'Altering [dbo].[UpdateBatchStatus]'
GO

ALTER procedure UpdateBatchStatus
	@tx_batch VARBINARY(16),
	@tx_batch_encoded varchar(24),
	@n_completed int,
	@sysdate datetime
as
declare @initialStatus char(1)
declare @finalStatus char(1)

if not exists (select * from t_batch with(updlock) where tx_batch = @tx_batch)
begin
  insert into t_batch (tx_namespace, tx_name, tx_batch, tx_batch_encoded, tx_status, n_completed, n_failed, dt_first, dt_crt)
    values ('pipeline', @tx_batch_encoded, @tx_batch, @tx_batch_encoded, 'A', 0, 0, @sysdate, @sysdate)
end

select @initialStatus = tx_status from t_batch with(updlock) where tx_batch = @tx_batch

update t_batch
  set t_batch.n_completed = t_batch.n_completed + @n_completed,
    t_batch.tx_status =
       case when ((t_batch.n_completed + t_batch.n_failed + ISNULL(t_batch.n_dismissed, 0) + @n_completed) = t_batch.n_expected
                   or 
                  (((t_batch.n_completed + t_batch.n_failed + + ISNULL(t_batch.n_dismissed, 0) + @n_completed) = t_batch.n_metered)                      and t_batch.n_expected = 0)) 
            then 'C'
				    when ((t_batch.n_completed + t_batch.n_failed + ISNULL(t_batch.n_dismissed, 0) + @n_completed) < t_batch.n_expected
                   or 
                 (((t_batch.n_completed + t_batch.n_failed + ISNULL(t_batch.n_dismissed, 0) + @n_completed) < t_batch.n_metered) 
                    and t_batch.n_expected = 0)) 
            then 'A'
            when ((t_batch.n_completed + t_batch.n_failed + ISNULL(t_batch.n_dismissed, 0) + @n_completed) > t_batch.n_expected) 
                   and t_batch.n_expected > 0 
            then 'F'
            else t_batch.tx_status end,
     t_batch.dt_last = @sysdate,
     t_batch.dt_first =
       case when t_batch.n_completed = 0 then @sysdate else t_batch.dt_first end
  where tx_batch = @tx_batch

select @finalStatus = tx_status from t_batch where tx_batch = @tx_batch

GO


PRINT N'Altering [dbo].[MTSP_INSERTINVOICE]'
GO

ALTER PROCEDURE MTSP_INSERTINVOICE
@id_billgroup int,
@invoicenumber_storedproc nvarchar(256), --this is the name of the stored procedure used to generate invoice numbers
@is_sample varchar(1),
@dt_now DATETIME,  -- the MetraTech system's date
@id_run int,
@num_invoices int OUTPUT,
@return_code int OUTPUT
AS
SET NOCOUNT ON
BEGIN
DECLARE
@invoice_date datetime,
@cnt int,
@curr_max_id int,
@id_interval_exist int,
@id_billgroup_exist int,
@debug_flag bit,
@SQLError int,
@ErrMsg varchar(200)
-- Initialization
SET @num_invoices = 0
SET @invoice_date = CAST(SUBSTRING(CAST(@dt_now AS CHAR),1,11) AS DATETIME) --datepart
SET @debug_flag = 1 -- yes
--SET @debug_flag = 0 -- no
-- Validate input parameter values
IF @id_billgroup IS NULL
BEGIN
  SET @ErrMsg = 'InsertInvoice: Completed abnormally, id_billgroup is null'
  GOTO FatalError
END
if @invoicenumber_storedproc IS NULL OR RTRIM(@invoicenumber_storedproc) = ''
BEGIN
  SET @ErrMsg = 'InsertInvoice: Completed abnormally, invoicenumber_storedproc is null'
  GOTO FatalError
END
IF @debug_flag = 1
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
    VALUES (@id_run, 'Debug', 'InsertInvoice: Started', getutcdate())
-- If already exists, do not process again
SELECT TOP 1 @id_billgroup_exist = id_billgroup
FROM t_invoice_range
WHERE id_billgroup = @id_billgroup and id_run is NULL
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @id_billgroup_exist IS NOT NULL
BEGIN
  SET @ErrMsg = 'InsertInvoice: Invoice number already exists in the t_invoice_range table, '
    + 'process skipped, process completed successfully at '
    + CONVERT(char, getutcdate(), 109)
  GOTO SkipReturn
END
/*  Does an invoice exist for the accounts in the given @id_billgroup */
SELECT TOP 1 @id_interval_exist = id_interval
FROM t_invoice inv
INNER JOIN t_billgroup_member bgm
  ON bgm.id_acc = inv.id_acc
INNER JOIN t_billgroup bg
  ON bg.id_usage_interval = inv.id_interval AND
     bg.id_billgroup = bgm.id_billgroup
WHERE bgm.id_billgroup = @id_billgroup and
            inv.sample_flag = 'N'
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @id_interval_exist IS NOT NULL
BEGIN
  SET @ErrMsg = 'InsertInvoice: Invoice number already exists in the t_invoice table, '
    + 'process skipped, process completed successfully at '
    + CONVERT(char, getdate(), 109)
  GOTO SkipReturn
END

-- call MTSP_INSERTINVOICE_BALANCES to populate #tmp_acc_amounts, #tmp_prev_balance, #tmp_adjustments

CREATE TABLE #tmp_acc_amounts
  (tmp_seq int IDENTITY,
  namespace nvarchar(40),
  id_interval int,
  id_acc int,
  invoice_currency nvarchar(10),
  payment_ttl_amt numeric(18, 6),
  postbill_adj_ttl_amt numeric(18, 6),
  ar_adj_ttl_amt numeric(18, 6),
  previous_balance numeric(18, 6),
  tax_ttl_amt numeric(18, 6),
  current_charges numeric(18, 6),
  id_payer int,
  id_payer_interval int
  )

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

CREATE TABLE #tmp_prev_balance
 ( id_acc int,
   previous_balance numeric(18, 6)
 )

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

CREATE TABLE #tmp_adjustments
 ( id_acc int,
   PrebillAdjAmt numeric(18, 6),
   PrebillTaxAdjAmt numeric(18, 6),
   PostbillAdjAmt numeric(18, 6),
   PostbillTaxAdjAmt numeric(18, 6)
 )

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

-- Create the driver table with all id_accs
CREATE TABLE #tmp_all_accounts
(tmp_seq int IDENTITY,
 id_acc int NOT NULL,
 namespace nvarchar(80) NOT NULL)

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

EXEC MTSP_INSERTINVOICE_BALANCES @id_billgroup, 0, @id_run, @return_code OUTPUT

if @return_code <> 0 GOTO FatalError

-- Obtain the configured invoice strings and store them in a temp table
CREATE TABLE #tmp_invoicenumber
(id_acc int NOT NULL,
 namespace nvarchar(40) NOT NULL,
 invoice_string nvarchar(50) NOT NULL,
 invoice_due_date datetime NOT NULL,
 id_invoice_num int NOT NULL)

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

INSERT INTO #tmp_invoicenumber EXEC @invoicenumber_storedproc @invoice_date
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
-- End of 11/20/2002 add

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

IF @debug_flag = 1
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
  VALUES (@id_run, 'Debug', 'InsertInvoice: Begin Insert into t_invoice', getutcdate())

-- Save all the invoice data to the t_invoice table
INSERT INTO t_invoice
  (namespace,
  invoice_string,
  id_interval,
  id_acc,
  invoice_amount,
  invoice_date,
  invoice_due_date,
  id_invoice_num,
  invoice_currency,
  payment_ttl_amt,
  postbill_adj_ttl_amt,
  ar_adj_ttl_amt,
  tax_ttl_amt,
  current_balance,
  id_payer,
  id_payer_interval,
  sample_flag,
  balance_forward_date)
SELECT
  #tmp_acc_amounts.namespace,
  tmpin.invoice_string, -- from the stored proc as below
  ui.id_interval, /*@id_interval,*/
  #tmp_acc_amounts.id_acc,
  current_charges
    + ISNULL(#tmp_adjustments.PrebillAdjAmt,0)
    + tax_ttl_amt
    + ISNULL(#tmp_adjustments.PrebillTaxAdjAmt,0.0),  -- invoice_amount = current_charges + prebill adjustments + taxes + prebill tax adjustments,
  @invoice_date invoice_date,
  tmpin.invoice_due_date, -- from the stored proc as @invoice_date+@invoice_due_date_offset   invoice_due_date,
  tmpin.id_invoice_num, -- from the stored proc as tmp_seq + @invoice_number - 1,
  invoice_currency,
  payment_ttl_amt, -- payment_ttl_amt
 ISNULL(#tmp_adjustments.PostbillAdjAmt, 0.0) + ISNULL(#tmp_adjustments.PostbillTaxAdjAmt, 0.0), -- postbill_adj_ttl_amt
  ar_adj_ttl_amt, -- ar_adj_ttl_amt
  tax_ttl_amt + ISNULL(#tmp_adjustments.PrebillTaxAdjAmt,0.0), -- tax_ttl_amt
  current_charges + tax_ttl_amt + ar_adj_ttl_amt
	  + ISNULL(#tmp_adjustments.PostbillAdjAmt, 0.0)
    + ISNULL(#tmp_adjustments.PostbillTaxAdjAmt,0.0)
    + payment_ttl_amt
	  + ISNULL(#tmp_prev_balance.previous_balance, 0.0)
    + ISNULL(#tmp_adjustments.PrebillAdjAmt, 0.0)
    + ISNULL(#tmp_adjustments.PrebillTaxAdjAmt,0.0), -- current_balance
  id_payer, -- id_payer
  CASE WHEN #tmp_acc_amounts.id_payer_interval IS NULL
           THEN (SELECT id_usage_interval
                     FROM t_billgroup
	         WHERE id_billgroup = @id_billgroup)/*@id_interval*/
           ELSE #tmp_acc_amounts.id_payer_interval
  END, -- id_payer_interval
  @is_sample sample_flag,
  ui.dt_end -- balance_forward_date
FROM #tmp_acc_amounts
INNER JOIN #tmp_invoicenumber tmpin ON tmpin.id_acc = #tmp_acc_amounts.id_acc
LEFT OUTER JOIN #tmp_prev_balance ON #tmp_prev_balance.id_acc = #tmp_acc_amounts.id_acc
LEFT OUTER JOIN #tmp_adjustments ON #tmp_adjustments.id_acc = #tmp_acc_amounts.id_acc
INNER JOIN t_usage_interval ui ON ui.id_interval IN (SELECT id_usage_interval
			                                               FROM t_billgroup
			                                               WHERE id_billgroup = @id_billgroup)/*= @id_interval*/
INNER JOIN t_av_internal avi ON avi.id_acc = #tmp_acc_amounts.id_acc

SET @num_invoices = @@ROWCOUNT

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

-- Store the invoice range data to the t_invoice_range table
SELECT @cnt = MAX(tmp_seq)
FROM #tmp_acc_amounts
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

IF @cnt IS NOT NULL
BEGIN
  --insert info about the current run into the t_invoice_range table
  INSERT INTO t_invoice_range (id_interval, id_billgroup, namespace, id_invoice_num_first, id_invoice_num_last)
  SELECT i.id_interval, bm.id_billgroup, i.namespace, ISNULL(min(id_invoice_num),0), ISNULL(max(id_invoice_num),0)
  FROM t_invoice i
	INNER JOIN t_billgroup_member bm on bm.id_acc = i.id_acc
	INNER JOIN t_billgroup b on b.id_billgroup = bm.id_billgroup
		and i.id_interval = b.id_usage_interval
  WHERE bm.id_billgroup = @id_billgroup
  GROUP BY i.id_interval, bm.id_billgroup, i.namespace

  --update the id_invoice_num_last in the t_invoice_namespace table
  UPDATE t_invoice_namespace
  SET t_invoice_namespace.id_invoice_num_last =
	(SELECT ISNULL(max(t_invoice.id_invoice_num),t_invoice_namespace.id_invoice_num_last)
	FROM t_invoice
  	WHERE t_invoice_namespace.namespace = t_invoice.namespace AND
	t_invoice.id_interval IN (SELECT id_usage_interval
			              FROM t_billgroup
			              WHERE id_billgroup = @id_billgroup))
  SELECT @SQLError = @@ERROR
  IF @SQLError <> 0 GOTO FatalError
END
ELSE  SET @cnt = 0

DROP TABLE #tmp_acc_amounts
DROP TABLE #tmp_prev_balance
DROP TABLE #tmp_invoicenumber
DROP TABLE #tmp_adjustments
DROP TABLE #tmp_all_accounts


IF @debug_flag = 1
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
   VALUES (@id_run, 'Debug', 'InsertInvoice: Completed successfully', getutcdate())

SET @return_code = 0
RETURN 0

SkipReturn:
  IF @ErrMsg IS NULL
    SET @ErrMsg = 'InsertInvoice: Process skipped'
  IF @debug_flag = 1
    INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
      VALUES (@id_run, 'Debug', @ErrMsg, getutcdate())
  SET @return_code = 0
  RETURN 0

FatalError:
  IF @ErrMsg IS NULL
    SET @ErrMsg = 'InsertInvoice: Adapter stored procedure failed'
  IF @debug_flag = 1
    INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
      VALUES (@id_run, 'Debug', @ErrMsg, getutcdate())
  SET @return_code = -1
  RETURN -1

END

GO

PRINT N'Altering [dbo].[mtsp_BackoutInvoices]'
GO


			ALTER procedure mtsp_BackoutInvoices (

			@id_billgroup int,
			@id_run int,
			@num_invoices int OUTPUT,
			@info_string nvarchar(500) OUTPUT,
			@return_code int OUTPUT
			)

                  		as
			begin

				DECLARE @debug_flag bit
				DECLARE @msg nvarchar(256)
				DECLARE @usage_cycle_type int

          				SET @msg = 'Invoice-Backout: Invoice adapter reversed'
				SET @debug_flag = 1
				--SET @debug_flag = 0
				SET @info_string = ''

				set @usage_cycle_type = (select id_usage_cycle from t_usage_interval
							 where id_interval  IN (SELECT id_usage_interval
						                                               FROM t_billgroup
						                                               WHERE id_billgroup = @id_billgroup))/*= @id_interval*/

				select top 1 t_invoice.id_invoice from t_invoice left outer join t_usage_interval
 					on t_invoice.id_interval = t_usage_interval.id_interval
 					where id_usage_cycle = @usage_cycle_type
 					and t_invoice.id_interval > (SELECT id_usage_interval
						                                FROM t_billgroup
						                                WHERE id_billgroup = @id_billgroup)/*@id_interval*/
				if (@@rowcount > 0)
 					SET @info_string = 'Reversing the invoice adapter for this interval has caused the invoices for subsequent intervals to be invalid'

				--truncate the table so that all rows corresponding to this interval are removed

				DELETE FROM t_invoice
				WHERE
                                                            id_acc IN (SELECT bgm.id_acc
						    FROM t_billgroup_member bgm
						    WHERE bgm.id_billgroup = @id_billgroup) AND

	            	id_interval IN (SELECT id_usage_interval
			                                FROM t_billgroup
			                                WHERE id_billgroup = @id_billgroup)

				SET @num_invoices = @@ROWCOUNT

				--update the t_invoice_range table's id_run field

					UPDATE t_invoice_range
					SET id_run = @id_run
                                                            WHERE id_billgroup = @id_billgroup
                                                              AND id_run IS NULL

					IF @debug_flag = 1

					INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
					  VALUES (@id_run, 'Debug', @msg, getutcdate())

    					SET @return_code = 0

			end

GO
