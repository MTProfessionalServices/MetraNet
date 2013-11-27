use %%NETMETER%%

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

PRINT N'Creating [dbo].[WFRetAllInstanceDescriptions]'
GO

              
            Create Procedure [dbo].[WFRetAllInstanceDescriptions]
            As
	            SELECT id_instance, tx_info, n_status, dt_nextTimer, n_blocked
	            FROM [dbo].[t_wf_InstanceState]
        
            
GO
PRINT N'Creating [dbo].[WorkflowInsertCompletedScope]'
GO

        
            CREATE PROCEDURE [dbo].[WorkflowInsertCompletedScope]
              @id_instance nvarchar(36),
              @id_completedScope nvarchar(36),
              @state image
              As

              SET TRANSACTION ISOLATION LEVEL READ COMMITTED
              SET NOCOUNT ON

		              UPDATE [dbo].[t_wf_CompletedScope] WITH(ROWLOCK UPDLOCK) 
		                  SET state = @state,
		                  dt_modified = getdate()
		                  WHERE id_completedScope=@id_completedScope 

		              IF ( @@ROWCOUNT = 0 )
		              BEGIN
			              --Insert Operation
			              INSERT INTO [dbo].[t_wf_CompletedScope] WITH(ROWLOCK)
			              VALUES(@id_instance, @id_completedScope, @state, getdate()) 
		              END

		              RETURN
              RETURN
        
      
GO
PRINT N'Creating [dbo].[WFRetNonblockInstanceStateIds]'
GO

              
            CREATE PROCEDURE [dbo].[WFRetNonblockInstanceStateIds]
              @id_owner nvarchar(36) = NULL,
              @dt_ownedUntil datetime = NULL,
              @now datetime
              AS
                  SELECT id_instance FROM [dbo].[t_wf_InstanceState] WITH (TABLOCK,UPDLOCK,HOLDLOCK)
                  WHERE n_blocked=0 AND n_status<>1 AND n_status<>3 AND n_status<>2 -- not n_blocked and not completed and not terminated and not suspended
 		              AND ( id_owner IS NULL OR dt_ownedUntil<getdate() )
                  if ( @@ROWCOUNT > 0 )
                  BEGIN
                      -- lock the table entries that are returned
                      Update [dbo].[t_wf_InstanceState]  
                      set id_owner = @id_owner,
	                  dt_ownedUntil = @dt_ownedUntil
                      WHERE n_blocked=0 AND n_status<>1 AND n_status<>3 AND n_status<>2
 		              AND ( id_owner IS NULL OR dt_ownedUntil<getdate() )
              	
                  END
        
            
GO
PRINT N'Creating [dbo].[WorkflowInsertInstanceState]'
GO

        
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
              set @now = getdate()

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
PRINT N'Creating [dbo].[WorkflowUnlockInstanceState]'
GO

              
            Create Procedure [dbo].[WorkflowUnlockInstanceState]
                @id_instance nvarchar(36),
                @id_owner nvarchar(36) = NULL
                As

                SET TRANSACTION ISOLATION LEVEL READ COMMITTED
                set nocount on

		                Update [dbo].[t_wf_InstanceState]  
		                Set id_owner = NULL,
			                dt_ownedUntil = NULL
		                Where id_instance = @id_instance AND ((id_owner = @id_owner AND dt_ownedUntil>=getdate()) OR (id_owner IS NULL AND @id_owner IS NULL ))
        
            
GO
PRINT N'Creating [dbo].[WorkflowRetrieveInstanceState]'
GO

              
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
													               OR dt_ownedUntil<getdate()
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
PRINT N'Creating [dbo].[WFRetNonblockInstanceStateId]'
GO

              
            CREATE PROCEDURE [dbo].[WFRetNonblockInstanceStateId]
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
 		              AND	( id_owner IS NULL OR dt_ownedUntil<getdate() )
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
PRINT N'Creating [dbo].[WorkflowDeleteCompletedScope]'
GO

        
            CREATE PROCEDURE [dbo].[WorkflowDeleteCompletedScope]
              @id_completedScope nvarchar(36)
              AS
              DELETE FROM [dbo].[t_wf_CompletedScope] WHERE id_completedScope=@id_completedScope
        
      
GO
PRINT N'Creating [dbo].[WFRetrieveExpiredTimerIds]'
GO

              
            CREATE PROCEDURE [dbo].[WFRetrieveExpiredTimerIds]
              @id_owner nvarchar(36) = NULL,
              @dt_ownedUntil datetime = NULL,
              @now datetime
              AS
                  SELECT id_instance FROM [dbo].[t_wf_InstanceState]
                  WHERE dt_nextTimer<@now AND n_status<>1 AND n_status<>3 AND n_status<>2 -- not n_blocked and not completed and not terminated and not suspended
                      AND ((n_unlocked=1 AND id_owner IS NULL) OR dt_ownedUntil<getdate() )
        
      
GO
PRINT N'Creating [dbo].[GetNewUIEvents]'
GO

        
        CREATE PROCEDURE GetNewUIEvents
        (
          @p_id_acc int
        )
        AS
        BEGIN 

           select
               ueq.id_event_queue,
               ueq.id_event,
	             ueq.id_acc,
	             ueq.dt_crt,
	             ueq.dt_viewed,
	             ueq.b_deleted,
               ueq.b_bubbled,
	             ue.tx_Event_type,
	             ue.json_blob
	          from t_ui_event_queue ueq
	             inner join t_ui_event ue on ue.id_event = ueq.id_event
	          where id_acc = @p_id_acc and dt_viewed is null
             order by id_event DESC
        END
			  
      
GO
PRINT N'Creating [dbo].[WorkflowRetrieveCompletedScope]'
GO

        
            CREATE PROCEDURE WorkflowRetrieveCompletedScope
              @id_completedScope nvarchar(36),
              @result int output
              AS
              BEGIN
                  SELECT state FROM [dbo].[t_wf_CompletedScope] WHERE id_completedScope=@id_completedScope
	              set @result = @@ROWCOUNT;
              End
        
      
GO
PRINT N'Altering [dbo].[MTSP_INSERTINVOICE_BALANCES]'
GO

ALTER   PROCEDURE MTSP_INSERTINVOICE_BALANCES
@id_billgroup int,
@exclude_billable char, -- '1' to only return non-billable accounts, '0' to return all accounts
@id_run int,
@return_code int OUTPUT
AS
BEGIN
DECLARE
@debug_flag bit,
@SQLError int,
@ErrMsg varchar(200)
SET NOCOUNT ON
SET @debug_flag = 1 -- yes
--SET @debug_flag = 0 -- no

-- populate the driver table with account ids
INSERT INTO #tmp_all_accounts
(id_acc, namespace)
SELECT /*DISTINCT*/
bgm.id_acc,
map.nm_space
	FROM t_billgroup_member bgm
	INNER JOIN t_acc_usage au ON au.id_acc = bgm.id_acc
	INNER JOIN t_account_mapper map
	ON map.id_acc = au.id_acc
	INNER JOIN t_namespace ns
	ON ns.nm_space = map.nm_space
	WHERE ns.tx_typ_space = 'system_mps' AND
	bgm.id_billgroup = @id_billgroup AND
    au.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                     WHERE id_billgroup = @id_billgroup)
UNION

SELECT /*DISTINCT*/
ads.id_acc,
map.nm_space
	FROM vw_adjustment_summary ads
	INNER JOIN t_billgroup_member bgm ON bgm.id_acc = ads.id_acc
	INNER JOIN t_account_mapper map
	ON map.id_acc = ads.id_acc
	INNER JOIN t_namespace ns
	ON ns.nm_space = map.nm_space
	WHERE ns.tx_typ_space = 'system_mps' AND
	bgm.id_billgroup = @id_billgroup AND
    ads.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                     WHERE id_billgroup = @id_billgroup)
UNION

  select inv.id_acc, inv.namespace from t_invoice inv 
  inner join t_billgroup_member bgm on inv.id_acc = bgm.id_acc 
  inner join t_billgroup bg on bgm.id_billgroup = bg.id_billgroup
  inner join t_usage_interval uii on bg.id_usage_interval = uii.id_interval  
  inner join t_namespace ns on inv.namespace = ns.nm_space
  WHERE ns.tx_typ_space = 'system_mps' and bgm.id_billgroup = @id_billgroup
  group by inv.id_acc, inv.namespace
  having (sum(invoice_amount) + sum(payment_ttl_amt)) <> 0

-- Populate with accounts that are non-billable but have payers that are billable.
-- in specified billing group
if @exclude_billable = '1'
BEGIN
	INSERT INTO #tmp_all_accounts
	(id_acc, namespace)

	-- Get all payee accounts (for the payers in the given billing group) with usage
	SELECT /*DISTINCT*/
	pr.id_payee,
	map.nm_space
		FROM t_billgroup_member bgm
		INNER JOIN t_payment_redirection pr	ON pr.id_payer = bgm.id_acc
		INNER JOIN t_acc_usage au ON au.id_acc = pr.id_payee
		INNER JOIN t_account_mapper map	ON map.id_acc = au.id_acc
		INNER JOIN t_namespace ns ON ns.nm_space = map.nm_space
		WHERE ns.tx_typ_space = 'system_mps' AND
		bgm.id_billgroup = @id_billgroup AND
		pr.id_payee NOT IN (SELECT id_acc FROM #tmp_all_accounts) AND
		au.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
								WHERE id_billgroup = @id_billgroup)
	UNION

	-- Get all payee accounts (for the payers in the given billing group) with adjustments
	SELECT /*DISTINCT*/
	ads.id_acc,
	map.nm_space
		FROM vw_adjustment_summary ads
		INNER JOIN t_payment_redirection pr	ON pr.id_payee = ads.id_acc
		INNER JOIN t_billgroup_member bgm ON bgm.id_acc = pr.id_payer
		INNER JOIN t_account_mapper map	ON map.id_acc = ads.id_acc
		INNER JOIN t_namespace ns ON ns.nm_space = map.nm_space
		WHERE ns.tx_typ_space = 'system_mps' AND
		bgm.id_billgroup = @id_billgroup AND
		pr.id_payee NOT IN (SELECT id_acc FROM #tmp_all_accounts) AND
		ads.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
								WHERE id_billgroup = @id_billgroup)
	UNION

  select inv.id_acc, inv.namespace from t_invoice inv 
  inner join t_payment_redirection pr on pr.id_payee  = inv.id_acc
  inner join t_billgroup_member bgm on pr.id_payer = bgm.id_acc 
  inner join t_billgroup bg on bgm.id_billgroup = bg.id_billgroup
  inner join t_usage_interval uii on bg.id_usage_interval = uii.id_interval  
  inner join t_namespace ns on inv.namespace = ns.nm_space
  WHERE ns.tx_typ_space = 'system_mps' and pr.id_payee not in (select id_acc from #tmp_all_accounts)
      AND bgm.id_billgroup = @id_billgroup
  group by inv.id_acc, inv.namespace
  having (sum(invoice_amount) + sum(payment_ttl_amt)) <> 0
END

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

-- populate #tmp_acc_amounts with accounts and their invoice amounts
IF (@debug_flag = 1 and @id_run IS NOT NULL)
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
    VALUES (@id_run, 'Debug', 'Invoice-Bal: Begin inserting to the #tmp_acc_amounts table', getutcdate())

-- check if datamarts are being used
-- if no datamarts
-- then...

IF ((SELECT value FROM t_db_values WHERE parameter = N'DATAMART') = 'false')

BEGIN
INSERT INTO #tmp_acc_amounts
  (namespace,
  id_interval,
  id_acc,
  invoice_currency,
  payment_ttl_amt,
  postbill_adj_ttl_amt,
  ar_adj_ttl_amt,
  previous_balance,
  tax_ttl_amt,
  current_charges,
  id_payer,
  id_payer_interval
)
SELECT
  RTRIM(ammps.nm_space) namespace,
  au.id_usage_interval id_interval,
  ammps.id_acc,
  avi.c_currency invoice_currency,
  SUM(CASE WHEN pvpay.id_sess IS NULL THEN 0 ELSE ISNULL(au.amount,0) END) payment_ttl_amt,
  0, --postbill_adj_ttl_amt
  SUM(CASE WHEN pvar.id_sess IS NULL THEN 0 ELSE ISNULL(au.amount,0) END) ar_adj_ttl_amt,
  0, --previous_balance
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_Federal,0.0)) ELSE 0 END) +
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_State,0.0))ELSE 0 END) +
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_County,0.0))ELSE 0 END) +
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_Local,0.0))ELSE 0 END) +
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_Other,0.0))ELSE 0 END) tax_ttl_amt,
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL AND NOT vh.id_view IS NULL) THEN (ISNULL(au.Amount, 0.0)) ELSE 0 END) current_charges,
  CASE WHEN avi.c_billable = '0' THEN pr.id_payer ELSE ammps.id_acc END id_payer,
  CASE WHEN avi.c_billable = '0' THEN auipay.id_usage_interval ELSE au.id_usage_interval END id_payer_interval
FROM  #tmp_all_accounts tmpall
INNER JOIN t_av_internal avi ON avi.id_acc = tmpall.id_acc
INNER JOIN t_account_mapper ammps ON ammps.id_acc = tmpall.id_acc
INNER JOIN t_namespace ns ON ns.nm_space = ammps.nm_space
	AND ns.tx_typ_space = 'system_mps'
INNER join t_acc_usage_interval aui ON aui.id_acc = tmpall.id_acc
INNER join t_usage_interval ui ON aui.id_usage_interval = ui.id_interval
	AND ui.id_interval IN (SELECT id_usage_interval
                                               FROM t_billgroup
                                               WHERE id_billgroup = @id_billgroup)/*= @id_interval*/
INNER join t_payment_redirection pr ON tmpall.id_acc = pr.id_payee
	AND ui.dt_end BETWEEN pr.vt_start AND pr.vt_end
INNER join t_acc_usage_interval auipay ON auipay.id_acc = pr.id_payer
INNER join t_usage_interval uipay ON auipay.id_usage_interval = uipay.id_interval
        AND ui.dt_end BETWEEN CASE WHEN auipay.dt_effective IS NULL THEN uipay.dt_start ELSE dateadd(s, 1, auipay.dt_effective) END AND uipay.dt_end

LEFT OUTER JOIN
(SELECT au1.id_usage_interval, au1.amount, au1.Tax_Federal, au1.Tax_State, au1.Tax_County, au1.Tax_Local, au1.Tax_Other, au1.id_sess, au1.id_acc, au1.id_view
FROM t_acc_usage au1
LEFT OUTER JOIN t_pi_template piTemplated2
ON piTemplated2.id_template=au1.id_pi_template
LEFT OUTER JOIN t_base_props pi_type_props ON pi_type_props.id_prop=piTemplated2.id_pi
LEFT OUTER JOIN t_enum_data enumd2 ON au1.id_view=enumd2.id_enum_data
AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or %%%UPPER%%%(enumd2.nm_enum_data) NOT LIKE '%_TEMP')

WHERE au1.id_parent_sess is NULL
AND au1.id_usage_interval IN (SELECT id_usage_interval
                                                 FROM t_billgroup
                                                 WHERE id_billgroup = @id_billgroup) /*= @id_interval*/
AND ((au1.id_pi_template is null and au1.id_parent_sess is null) or (au1.id_pi_template is not null and piTemplated2.id_template_parent is null))
) au ON

	au.id_acc = tmpall.id_acc
-- join with the tables used for calculating the sums
LEFT OUTER JOIN t_view_hierarchy vh
	ON au.id_view = vh.id_view
	AND vh.id_view = vh.id_view_parent
LEFT OUTER JOIN t_pv_aradjustment pvar ON pvar.id_sess = au.id_sess and au.id_usage_interval=pvar.id_usage_interval
LEFT OUTER JOIN t_pv_payment pvpay ON pvpay.id_sess = au.id_sess and au.id_usage_interval=pvpay.id_usage_interval
-- non-join conditions
WHERE
(@exclude_billable = '0' OR avi.c_billable = '0')
GROUP BY ammps.nm_space, ammps.id_acc, au.id_usage_interval, avi.c_currency, pr.id_payer, auipay.id_usage_interval, avi.c_billable


SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
---------------------------------------------------------------

-- populate #tmp_adjustments with postbill and prebill adjustments
INSERT INTO #tmp_adjustments
 ( id_acc,
   PrebillAdjAmt,
   PrebillTaxAdjAmt,
   PostbillAdjAmt,
   PostbillTaxAdjAmt
 )
select ISNULL(adjtrx.id_acc, #tmp_all_accounts.id_acc) id_acc,
       ISNULL(PrebillAdjAmt, 0) PrebillAdjAmt,
       ISNULL(PrebillTaxAdjAmt, 0) PrebillTaxAdjAmt,
       ISNULL(PostbillAdjAmt, 0) PostbillAdjAmt,
       ISNULL(PostbillTaxAdjAmt, 0) PostbillTaxAdjAmt
  from vw_adjustment_summary adjtrx
   INNER JOIN t_billgroup_member bgm ON bgm.id_acc = adjtrx.id_acc
   FULL OUTER JOIN #tmp_all_accounts ON adjtrx.id_acc = #tmp_all_accounts.id_acc
   WHERE bgm.id_billgroup = @id_billgroup AND
   adjtrx.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                            WHERE id_billgroup = @id_billgroup)
  /* where adjtrx.id_usage_interval = @id_interval*/

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

END

ELSE

-- else datamarts are being used.
-- join against t_mv_payer_interval
BEGIN

INSERT INTO #tmp_acc_amounts
  (namespace,
  id_interval,
  id_acc,
  invoice_currency,
  payment_ttl_amt,
  postbill_adj_ttl_amt,
  ar_adj_ttl_amt,
  previous_balance,
  tax_ttl_amt,
  current_charges,
  id_payer,
  id_payer_interval
)

SELECT

  RTRIM(ammps.nm_space) namespace,
  dm.id_usage_interval id_interval,
  tmpall.id_acc, -- changed
  avi.c_currency invoice_currency,
  SUM(CASE WHEN ed.nm_enum_data = 'metratech.com/Payment' THEN ISNULL(dm.TotalAmount, 0) ELSE 0 END) payment_ttl_amt,
  0, --postbill_adj_ttl_amt
  SUM(CASE WHEN ed.nm_enum_data = 'metratech.com/ARAdjustment' THEN ISNULL(dm.TotalAmount, 0) ELSE 0 END) ar_adj_ttl_amt,
  0, --previous_balance
  SUM(CASE WHEN (ed.nm_enum_data <> 'metratech.com/Payment'
                 AND ed.nm_enum_data <> 'metratech.com/ARAdjustment')
           THEN
           (ISNULL(dm.TotalTax,0.0))
           ELSE 0
           END),  --tax_ttl_amt
  SUM(CASE WHEN (ed.nm_enum_data <> 'metratech.com/Payment'
		AND ed.nm_enum_data <> 'metratech.com/ARAdjustment')
           THEN (ISNULL(dm.TotalAmount, 0.0))
           ELSE 0
           END) current_charges,
  CASE WHEN avi.c_billable = '0'
       THEN pr.id_payer
       ELSE tmpall.id_acc
       END id_payer,
  CASE WHEN avi.c_billable = '0'
       THEN auipay.id_usage_interval
       ELSE dm.id_usage_interval
       END id_payer_interval

FROM  #tmp_all_accounts tmpall

-- added
INNER JOIN t_av_internal avi
ON avi.id_acc = tmpall.id_acc

-- Select accounts which are of type 'system_mps'
INNER JOIN t_account_mapper ammps
ON ammps.id_acc = tmpall.id_acc

INNER JOIN t_namespace ns
ON ns.nm_space = ammps.nm_space
   AND ns.tx_typ_space = 'system_mps'

-- Select accounts which belong
-- to the given usage interval
INNER join t_acc_usage_interval aui
ON aui.id_acc = tmpall.id_acc

INNER join t_usage_interval ui
ON aui.id_usage_interval = ui.id_interval
	AND ui.id_interval IN (SELECT id_usage_interval
                           FROM t_billgroup
                           WHERE id_billgroup = @id_billgroup)/*= @id_interval*/

--
INNER join t_payment_redirection pr
ON tmpall.id_acc = pr.id_payee
   AND ui.dt_end BETWEEN pr.vt_start AND pr.vt_end

INNER join t_acc_usage_interval auipay
ON auipay.id_acc = pr.id_payer

INNER join t_usage_interval uipay
ON auipay.id_usage_interval = uipay.id_interval
   AND ui.dt_end BETWEEN
     CASE WHEN auipay.dt_effective IS NULL
          THEN uipay.dt_start
          ELSE dateadd(s, 1, auipay.dt_effective)
          END
     AND uipay.dt_end

LEFT OUTER JOIN t_mv_payer_interval dm
ON dm.id_acc = tmpall.id_acc AND dm.id_usage_interval IN (SELECT id_usage_interval
														  FROM t_billgroup
							                              WHERE id_billgroup = @id_billgroup) /*= @id_interval*/
LEFT OUTER JOIN t_enum_data ed
ON dm.id_view = ed.id_enum_data

-- non-join conditions
WHERE
(@exclude_billable = '0' OR avi.c_billable = '0')
GROUP BY  ammps.nm_space, tmpall.id_acc, dm.id_usage_interval, avi.c_currency, pr.id_payer, auipay.id_usage_interval, avi.c_billable

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

-- populate #tmp_adjustments with postbill and prebill adjustments
INSERT INTO #tmp_adjustments
 ( id_acc,
   PrebillAdjAmt,
   PrebillTaxAdjAmt,
   PostbillAdjAmt,
   PostbillTaxAdjAmt
 )
select ISNULL(adjtrx.id_acc, #tmp_all_accounts.id_acc) id_acc,
       ISNULL(PrebillAdjAmt, 0) PrebillAdjAmt,
       ISNULL(PrebillTaxAdjAmt, 0) PrebillTaxAdjAmt,
       ISNULL(PostbillAdjAmt, 0) PostbillAdjAmt,
       ISNULL(PostbillTaxAdjAmt, 0) PostbillTaxAdjAmt
  from vw_adjustment_summary adjtrx
  INNER JOIN t_billgroup_member bgm ON bgm.id_acc = adjtrx.id_acc
  FULL OUTER JOIN #tmp_all_accounts ON adjtrx.id_acc = #tmp_all_accounts.id_acc
  WHERE bgm.id_billgroup = @id_billgroup AND
   adjtrx.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                            WHERE id_billgroup = @id_billgroup)

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

END

-- populate #tmp_prev_balance with the previous balance
INSERT INTO #tmp_prev_balance
  (id_acc,
  previous_balance)
SELECT id_acc, CONVERT(DECIMAL(18,6), SUBSTRING(comp,CASE WHEN PATINDEX('%-%',comp) = 0 THEN 10 ELSE PATINDEX('%-%',comp) END,28)) previous_balance
FROM 	(SELECT inv.id_acc,
ISNULL(MAX(CONVERT(CHAR(8),ui.dt_end,112)+
			REPLICATE('0',20-LEN(inv.current_balance)) +
			CONVERT(CHAR,inv.current_balance)),'00000000000') comp
	FROM t_invoice inv
	INNER JOIN t_usage_interval ui ON ui.id_interval = inv.id_interval
	INNER JOIN #tmp_all_accounts ON inv.id_acc = #tmp_all_accounts.id_acc
	GROUP BY inv.id_acc) maxdtend

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

IF (@debug_flag = 1  and @id_run IS NOT NULL)
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
    VALUES (@id_run, 'Debug', 'Invoice-Bal: Completed successfully', getutcdate())

SET @return_code = 0

RETURN 0

FatalError:
  IF @ErrMsg IS NULL
    SET @ErrMsg = 'Invoice-Bal: Stored procedure failed'
  IF (@debug_flag = 1  and @id_run IS NOT NULL)
    INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
      VALUES (@id_run, 'Debug', @ErrMsg, getutcdate())

  SET @return_code = -1

  RETURN -1

END

GO
PRINT N'Altering [dbo].[checksubscriptionconflicts]'
GO

	
ALTER function checksubscriptionconflicts (
@id_acc            INT,
@id_po             INT,
@real_begin_date   DATETIME,
@real_end_date     DATETIME,
@id_sub            INT
)
RETURNS INT
AS
begin
declare @status int
declare @cycle_type int
declare @po_cycle int

SELECT @status = COUNT (t_sub.id_sub)
FROM t_sub with(updlock)
WHERE t_sub.id_acc = @id_acc
 AND t_sub.id_po = @id_po
 AND t_sub.id_sub <> @id_sub
 AND dbo.overlappingdaterange (t_sub.vt_start,t_sub.vt_end,@real_begin_date,@real_end_date)= 1
IF (@status > 0)
	begin
 -- MTPCUSER_CONFLICTING_PO_SUBSCRIPTION
  RETURN (-289472485)
	END
select @status = dbo.overlappingdaterange(@real_begin_date,@real_end_date,te.dt_start,te.dt_end)
from t_po
INNER JOIN t_effectivedate te on te.id_eff_date = t_po.id_eff_date
where id_po = @id_po
if (@status <> 1)
	begin
	-- MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE
	return (-289472472)
	end

SELECT @status = COUNT (id_pi_template)
FROM t_pl_map
WHERE 
  t_pl_map.id_po = @id_po AND
  t_pl_map.id_paramtable IS NULL AND
  t_pl_map.id_pi_template IN
           (SELECT id_pi_template
            FROM t_pl_map
            WHERE 
              id_paramtable IS NULL AND
              id_po IN
                         (SELECT id_po
                            FROM t_vw_effective_subs subs
                            WHERE subs.id_sub <> @id_sub
                            AND subs.id_acc = @id_acc
                             AND dbo.overlappingdaterange (
                                    subs.dt_start,
                                    subs.dt_end,
                                    @real_begin_date,
                                    @real_end_date
                                 ) = 1))
IF (@status > 0)
	begin
	return (-289472484)
	END

-- CR 10872: make sure account and po have the same currency

-- BP - actually we need to check if a payer has different currency
-- In Kona we allow non billable accounts to be created with no currency
--if (dbo.IsAccountAndPOSameCurrency(@id_acc, @id_po) = '0')

if EXISTS
(
SELECT 1 FROM t_payment_redirection pr
INNER JOIN t_av_internal avi on avi.id_acc = pr.id_payer
INNER JOIN t_po po on  po.id_po = @id_po
INNER JOIN t_pricelist pl ON po.id_nonshared_pl = pl.id_pricelist
WHERE pr.id_payee = @id_acc
AND avi.c_currency <>  pl.nm_currency_code
AND (pr.vt_start <= @real_end_date AND pr.vt_end >= @real_begin_date)
)
begin
	-- MT_ACCOUNT_PO_CURRENCY_MISMATCH
	return (-486604729)
end

-- Check for MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE 0xEEBF004EL -289472434
-- BR violation
if
  exists (
    SELECT 1
    FROM  t_account tacc 
    INNER JOIN t_account_type tacctype on tacc.id_type = tacctype.id_type
    WHERE tacc.id_acc = @id_acc AND tacctype.b_CanSubscribe = '0'
  )
begin
  return(-289472434) -- MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE 
end

-- check that account type of the account is compatible with the product offering
-- since the absense of ANY mappings for the product offering means that PO is "wide open"
-- we need to do 2 EXISTS queries
if
exists (
SELECT 1
FROM t_po_account_type_map atmap 
WHERE atmap.id_po = @id_po
)
--PO is not wide open - see if subscription is permitted for the account type
AND
not exists (
SELECT 1
FROM  t_account tacc 
INNER JOIN t_po_account_type_map atmap on atmap.id_po = @id_po AND atmap.id_account_type = tacc.id_type
 WHERE  tacc.id_acc = @id_acc
)
begin
 return (-289472435) -- MTPCUSER_CONFLICTING_PO_ACCOUNT_TYPE
end


RETURN (1)
END

GO

PRINT N'Creating [dbo].[GetEvents]'
GO

        
        CREATE PROCEDURE GetEvents
        (
          @p_id_event_queue int
        )
        AS
        BEGIN 
            select ueq.id_event_queue,
            ueq.id_event,
            ueq.id_acc,
            ueq.dt_crt,
            ueq.dt_viewed,
            ueq.b_deleted,
            ueq.b_bubbled,
            ue.tx_Event_type,
            ue.json_blob
            from t_ui_event_queue ueq
            inner join t_ui_event ue on ue.id_event = ueq.id_event
            where ueq.id_event_queue > @p_id_event_queue and dt_viewed is null
            order by id_event DESC
        END  
			  
      
GO
PRINT N'Altering [dbo].[CreatePaymentRecordBitemporal]'
GO

     
ALTER Procedure CreatePaymentRecordBitemporal (
@p_id_payer int,
@p_id_payee int,
@startdate  datetime,
@enddate datetime,
@p_systemdate datetime,
@status int OUTPUT
)
as
declare @realstartdate datetime
declare @realenddate datetime
declare @varMaxDateTime datetime
declare @tempStartDate datetime
declare @tempEndDate datetime
declare @onesecond_systemdate datetime
declare @temp_id_payer int
declare @temp_id_payee int

begin

-- detect directly adjacent records with a adjacent start and end date.  If the
-- key comparison matches successfully, use the start and/or end date of the original record 
-- instead.

select @realstartdate = @startdate,@realenddate = @enddate,@varMaxDateTime = dbo.mtmaxdate(),
  @onesecond_systemdate = dbo.subtractsecond(@p_systemdate)

 -- Someone changes the start date of an existing record so that it creates gaps in time
 -- Existing Record      |---------------------|
 -- modified record       	|-----------|
 -- modified record      |-----------------|
 -- modified record         |------------------|
	begin
		
		-- find the start and end dates of the original interval
		select 
		@tempstartdate = vt_start,
		@tempenddate = vt_end
    from
    t_payment_redir_history with(updlock)
    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    id_payer = @p_id_payer AND id_payee = @p_id_payee and tt_end = @varMaxDateTime 

		-- the original date range is no longer true
		update t_payment_redir_history
    set tt_end = @onesecond_systemdate
		where id_payer = @p_id_payer AND id_payee = @p_id_payee AND vt_start = @tempstartdate AND
		@tempenddate = vt_end AND tt_end = @varMaxDateTime

		-- adjust the two records end dates that are adjacent on the start and
		-- end dates; these records are no longer true
		update t_payment_redir_history 
		set tt_end = @onesecond_systemdate where
		id_payee = @p_id_payee AND tt_end = @varMaxDateTime AND
		(vt_end = dbo.subtractSecond(@tempstartdate) OR vt_start = dbo.addsecond(@tempenddate))
    if (@@error <> 0 )
		begin
    select @status = 0
		end

		insert into t_payment_redir_history 
		(id_payer,id_payee,vt_start,vt_end,tt_start,tt_end)
		select 
			id_payer,id_payee,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime
			from t_payment_redir_history 
			where
			id_payee = @p_id_payee AND vt_end = dbo.subtractSecond(@tempstartdate)
		UNION ALL
		select
			id_payer,id_payee,@realenddate,vt_end,@p_systemdate,@varMaxDateTime
			from t_payment_redir_history
			where
			id_payee = @p_id_payee  AND vt_start = dbo.addsecond(@tempenddate)

	end

	-- detect directly adjacent records with a adjacent start and end date.  If the
	-- key comparison matches successfully, use the start and/or end date of the original record 
	-- instead.
	
	select @realstartdate = vt_start
	from 
	t_payment_redir_history  where id_payer = @p_id_payer AND id_payee = @p_id_payee AND
		@startdate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime
	if @realstartdate is NULL begin
		select @realstartdate = @startdate
	end
	--CR 10620 fix: Do not add a second to end date
	select @realenddate = vt_end
	from
	t_payment_redir_history  where id_payer = @p_id_payer AND id_payee = @p_id_payee AND
	@enddate between vt_start AND vt_end and tt_end = @varMaxDateTime
	if @realenddate is NULL begin
		select @realenddate = @enddate
	end

 -- step : delete a range that is entirely in the new date range
 -- existing record:      |----|
 -- new record:      |----------------|
 update  t_payment_redir_history 
 set tt_end = @onesecond_systemdate
 where dbo.EnclosedDateRange(@realstartdate,@realenddate,vt_start,vt_end) =1 AND
 id_payee = @p_id_payee  AND tt_end = @varMaxDateTime 

 -- create two new records that are on around the new interval        
 -- existing record:          |-----------------------------------|
 -- new record                        |-------|
 --
 -- adjusted old records      |-------|       |--------------------|
  begin
    select
		@temp_id_payer = id_payer,
@temp_id_payee = id_payee

		,@tempstartdate = vt_start,
		@tempenddate = vt_end
    from
    t_payment_redir_history
    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    id_payee = @p_id_payee and tt_end = @varMaxDateTime AND  id_payer <> @p_id_payer
    update     t_payment_redir_history 
    set tt_end = @onesecond_systemdate where
    dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    id_payee = @p_id_payee AND tt_end = @varMaxDateTime AND  id_payer <> @p_id_payer
   
-- CR 14491 - Primary keys can not be null
if ((@temp_id_payee is not null))
begin

insert into t_payment_redir_history 
   (id_payer,id_payee,vt_start,vt_end,tt_start,tt_end)
   select 
    @temp_id_payer,@temp_id_payee,@tempStartDate,dbo.subtractsecond(@realstartdate),
    @p_systemdate,@varMaxDateTime
    where @tempstartdate is not NULL AND @tempStartDate <> @realstartdate
    -- the previous statement may fail
		if @realenddate <> @tempendDate AND @realenddate <> @varMaxDateTime begin
			insert into t_payment_redir_history 
			(id_payer,id_payee,vt_start,vt_end,tt_start,tt_end)
	    select
	    @temp_id_payer,@temp_id_payee,@realenddate,@tempEndDate,
	    @p_systemdate,@varMaxDateTime
		end
      
end

  -- the previous statement may fail
  end
 -- step 5: update existing payment records that are overlapping on the start
 -- range
 -- Existing Record |--------------|
 -- New Record: |---------|
 insert into t_payment_redir_history
 (id_payer,id_payee,vt_start,vt_end,tt_start,tt_end)
 select 
 id_payer,id_payee,@realenddate,vt_end,@p_systemdate,@varMaxDateTime
 from 
 t_payment_redir_history  where
 id_payee = @p_id_payee AND 
 vt_start > @realstartdate and vt_start < @realenddate 
 and tt_end = @varMaxDateTime
 
 update t_payment_redir_history
 set tt_end = @onesecond_systemdate
 where
 id_payee = @p_id_payee AND 
 vt_start > @realstartdate and vt_start < @realenddate 
 and tt_end = @varMaxDateTime
 -- step 4: update existing payment records that are overlapping on the end
 -- range
 -- Existing Record |--------------|
 -- New Record:             |-----------|
 insert into t_payment_redir_history
 (id_payer,id_payee,vt_start,vt_end,tt_start,tt_end)
 select
 id_payer,id_payee,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime
 from t_payment_redir_history
 where
 id_payee = @p_id_payee AND 
 vt_end > @realstartdate AND vt_end < @realenddate
 AND tt_end = @varMaxDateTime
 update t_payment_redir_history
 set tt_end = @onesecond_systemdate
 where id_payee = @p_id_payee AND 
  vt_end > @realstartdate AND vt_end < @realenddate
 AND tt_end = @varMaxDateTime
 -- used to be realenddate
 -- step 7: create the new payment redirection record.  If the end date 
 -- is not max date, make sure the enddate is subtracted by one second
 insert into t_payment_redir_history 
 (id_payer,id_payee,vt_start,vt_end,tt_start,tt_end)
 select 
 @p_id_payer,@p_id_payee,@realstartdate,
  case when @realenddate = dbo.mtmaxdate() then @realenddate else 
  dbo.subtractsecond(@realenddate) end,
  @p_systemdate,@varMaxDateTime
  
delete from t_payment_redirection where id_payee = @p_id_payee
insert into t_payment_redirection (id_payer,id_payee,vt_start,vt_end)
select id_payer,id_payee,vt_start,vt_end
from t_payment_redir_history  where
id_payee = @p_id_payee and tt_end = @varMaxDateTime
 select @status = 1
 end
			
GO
PRINT N'Altering [dbo].[CreateSubscriptionRecord]'
GO

     
ALTER Procedure CreateSubscriptionRecord (
@p_id_sub int,
@p_id_sub_ext varbinary(16),
@p_id_acc int,
@p_id_group int,
@p_id_po int,
@p_dt_crt datetime,
@startdate  datetime,
@enddate datetime,
@p_systemdate datetime,
@status int OUTPUT
)
as
declare @realstartdate datetime
declare @realenddate datetime
declare @varMaxDateTime datetime
declare @tempStartDate datetime
declare @tempEndDate datetime
declare @onesecond_systemdate datetime
declare @temp_id_sub int
declare @temp_id_sub_ext varbinary(16)
declare @temp_id_acc int
declare @temp_id_group int
declare @temp_id_po int
declare @temp_dt_crt datetime

begin

-- detect directly adjacent records with a adjacent start and end date.  If the
-- key comparison matches successfully, use the start and/or end date of the original record 
-- instead.

select @realstartdate = @startdate,@realenddate = @enddate,@varMaxDateTime = dbo.mtmaxdate(),
  @onesecond_systemdate = dbo.subtractsecond(@p_systemdate)

 -- Someone changes the start date of an existing record so that it creates gaps in time
 -- Existing Record      |---------------------|
 -- modified record       	|-----------|
 -- modified record      |-----------------|
 -- modified record         |------------------|
	begin
		
		-- find the start and end dates of the original interval
		select 
		@tempstartdate = vt_start,
		@tempenddate = vt_end
    from
    t_sub_history with(updlock)
    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    id_sub = @p_id_sub and tt_end = @varMaxDateTime 

		-- the original date range is no longer true
		update t_sub_history
    set tt_end = @onesecond_systemdate
		where id_sub = @p_id_sub AND vt_start = @tempstartdate AND
		@tempenddate = vt_end AND tt_end = @varMaxDateTime

		-- adjust the two records end dates that are adjacent on the start and
		-- end dates; these records are no longer true
		update t_sub_history 
		set tt_end = @onesecond_systemdate where
		id_sub = @p_id_sub AND tt_end = @varMaxDateTime AND
		(vt_end = dbo.subtractSecond(@tempstartdate) OR vt_start = dbo.addsecond(@tempenddate))
    if (@@error <> 0 )
		begin
    select @status = 0
		end

		insert into t_sub_history 
		(id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end,tt_start,tt_end)
		select 
			id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime
			from t_sub_history 
			where
			id_sub = @p_id_sub AND vt_end = dbo.subtractSecond(@tempstartdate)
		UNION ALL
		select
			id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,@realenddate,vt_end,@p_systemdate,@varMaxDateTime
			from t_sub_history
			where
			id_sub = @p_id_sub  AND vt_start = dbo.addsecond(@tempenddate)

	end

	-- detect directly adjacent records with a adjacent start and end date.  If the
	-- key comparison matches successfully, use the start and/or end date of the original record 
	-- instead.
	
	select @realstartdate = vt_start
	from 
	t_sub_history  where id_sub = @p_id_sub AND
		@startdate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime
	if @realstartdate is NULL begin
		select @realstartdate = @startdate
	end
	--CR 10620 fix: Do not add a second to end date
	select @realenddate = vt_end
	from
	t_sub_history  where id_sub = @p_id_sub AND
	@enddate between vt_start AND vt_end and tt_end = @varMaxDateTime
	if @realenddate is NULL begin
		select @realenddate = @enddate
	end

 -- step : delete a range that is entirely in the new date range
 -- existing record:      |----|
 -- new record:      |----------------|
 update  t_sub_history 
 set tt_end = @onesecond_systemdate
 where dbo.EnclosedDateRange(@realstartdate,@realenddate,vt_start,vt_end) =1 AND
 id_sub = @p_id_sub  AND tt_end = @varMaxDateTime 

 -- create two new records that are on around the new interval        
 -- existing record:          |-----------------------------------|
 -- new record                        |-------|
 --
 -- adjusted old records      |-------|       |--------------------|
  begin
    select
		@temp_id_sub = id_sub,
@temp_id_sub_ext = id_sub_ext,
@temp_id_acc = id_acc,
@temp_id_group = id_group,
@temp_id_po = id_po,
@temp_dt_crt = dt_crt

		,@tempstartdate = vt_start,
		@tempenddate = vt_end
    from
    t_sub_history
    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    id_sub = @p_id_sub and tt_end = @varMaxDateTime
    update     t_sub_history 
    set tt_end = @onesecond_systemdate where
    dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    id_sub = @p_id_sub AND tt_end = @varMaxDateTime
   
-- CR 14491 - Primary keys can not be null
if ((@temp_id_sub is not null))
begin

insert into t_sub_history 
   (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end,tt_start,tt_end)
   select 
    @temp_id_sub,@temp_id_sub_ext,@temp_id_acc,@temp_id_group,@temp_id_po,@temp_dt_crt,@tempStartDate,dbo.subtractsecond(@realstartdate),
    @p_systemdate,@varMaxDateTime
    where @tempstartdate is not NULL AND @tempStartDate <> @realstartdate
    -- the previous statement may fail
		if @realenddate <> @tempendDate AND @realenddate <> @varMaxDateTime begin
			insert into t_sub_history 
			(id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end,tt_start,tt_end)
	    select
	    @temp_id_sub,@temp_id_sub_ext,@temp_id_acc,@temp_id_group,@temp_id_po,@temp_dt_crt,@realenddate,@tempEndDate,
	    @p_systemdate,@varMaxDateTime
		end
      
end

  -- the previous statement may fail
  end
 -- step 5: update existing payment records that are overlapping on the start
 -- range
 -- Existing Record |--------------|
 -- New Record: |---------|
 insert into t_sub_history
 (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end,tt_start,tt_end)
 select 
 id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,@realenddate,vt_end,@p_systemdate,@varMaxDateTime
 from 
 t_sub_history  where
 id_sub = @p_id_sub AND 
 vt_start > @realstartdate and vt_start < @realenddate 
 and tt_end = @varMaxDateTime
 
 update t_sub_history
 set tt_end = @onesecond_systemdate
 where
 id_sub = @p_id_sub AND 
 vt_start > @realstartdate and vt_start < @realenddate 
 and tt_end = @varMaxDateTime
 -- step 4: update existing payment records that are overlapping on the end
 -- range
 -- Existing Record |--------------|
 -- New Record:             |-----------|
 insert into t_sub_history
 (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end,tt_start,tt_end)
 select
 id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime
 from t_sub_history
 where
 id_sub = @p_id_sub AND 
 vt_end > @realstartdate AND vt_end < @realenddate
 AND tt_end = @varMaxDateTime
 update t_sub_history
 set tt_end = @onesecond_systemdate
 where id_sub = @p_id_sub AND 
  vt_end > @realstartdate AND vt_end < @realenddate
 AND tt_end = @varMaxDateTime
 -- used to be realenddate
 -- step 7: create the new payment redirection record.  If the end date 
 -- is not max date, make sure the enddate is subtracted by one second
 insert into t_sub_history 
 (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end,tt_start,tt_end)
 select 
 @p_id_sub,@p_id_sub_ext,@p_id_acc,@p_id_group,@p_id_po,@p_dt_crt,@realstartdate,
  case when @realenddate = dbo.mtmaxdate() then @realenddate else 
  @realenddate end,
  @p_systemdate,@varMaxDateTime
  
delete from t_sub where id_sub = @p_id_sub
insert into t_sub (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end)
select id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end
from t_sub_history  where
id_sub = @p_id_sub and tt_end = @varMaxDateTime
 select @status = 1
 end
			
GO
PRINT N'Altering [dbo].[archive_delete]'
GO

    
ALTER procedure archive_delete
			(
			@partition nvarchar(4000)=null,
			@intervalid int=null,
			@result nvarchar(4000) output
			)
		as
/*
		How to run this stored procedure
		declare @result nvarchar(2000)
		exec archive_delete @partition='N_20040701_20040731',@result=@result output
		print @result
		or
		declare @result nvarchar(2000)
		exec archive_delete @intervalid=827719717,@result=@result output
		print @result
*/
		set nocount on
		declare @sql1 nvarchar(4000)
		declare @tab1 nvarchar(1000)
		declare @var1 nvarchar(1000)
		declare @vartime datetime
		declare @maxtime datetime
		declare @acc int
		declare	@servername nvarchar(100)
		declare	@dbname nvarchar(100)
		declare @interval int
		declare @partition1 nvarchar(4000)
		declare @min_id_sess int
		declare @max_id_sess int
		DECLARE @ParmDefinition nvarchar(500);

		select @servername = @@servername
		select @dbname = db_name()
		select @vartime = getdate()
		select @maxtime = dbo.mtmaxdate()

		--Checking the following Business rules

		--Either partition or Interval should be specified
		if ((@partition is not null and @intervalId is not null) or (@partition is null and @intervalId is null))
		begin
			set @result = '2000001-archive_delete operation failed-->Either Partition or Interval should be specified'
			return
		END
--Get the list of intervals that need to be archived
		if (@partition is not null)
		begin
			if ((select count(id_interval) from t_partition_interval_map map where id_partition
			in (select id_partition  from t_partition where partition_name = @partition))<= 0)
			begin
				set @result = '2000002-archive_delete operation failed-->None of the Intervals in the Partition needs to be archived'
				return
			END
			--Partition should not already by archived
			if exists (select * from t_archive_partition where partition_name = @partition
					and status ='A' and tt_end = @maxtime)
			begin
				set @result = '2000003-archive_delete operation failed-->Partition already archived'
				return
			END
			declare  interval_id cursor fast_forward for select id_interval from t_partition_interval_map map where id_partition
			= (select id_partition  from t_partition where partition_name = @partition)
		end
		else
		begin
			declare  interval_id cursor fast_forward for select @intervalId
			if (select b_partitioning_enabled from t_usage_server) = 'Y'
			begin
				select @partition1 = partition_name from t_partition part inner join
				t_partition_interval_map map on part.id_partition = map.id_partition
				and map.id_interval = @intervalid
			end
		end
		open interval_id
		fetch next from interval_id into @interval
		while (@@fetch_status = 0)
		begin
		--Interval should not be already archived
			if  exists (select top 1 * from t_archive where id_interval=@interval and status ='A' and tt_end = @maxtime)
			begin
				set @result = '2000004-archive operation failed-->Interval is already archived'
				close interval_id
				deallocate interval_id
				return
			end
			--Interval should exist and in export state
			if  exists (select 1 from t_acc_usage where id_usage_interval = @interval
					 and not exists (select 1 from t_archive where id_interval=@interval and status ='E' and tt_end = @maxtime))
			begin
				set @result = '2000005-archive operation failed-->Interval is not exported..run the archive_export procedure'
				close interval_id
				deallocate interval_id
				return
			end
		--Interval should not be already Dearchived
			if  exists (select top 1 * from t_archive where id_interval=@interval and status ='D' and tt_end = @maxtime)
			begin
				set @result = '2000006-archive operation failed-->Interval is Dearchived..run the trash procedure'
				close interval_id
				deallocate interval_id
				return
			end
		fetch next from interval_id into @interval
		end
		close interval_id


		begin tran
		open interval_id
		fetch next from interval_id into @interval
		while (@@fetch_status = 0)
		begin
			if object_id('tempdb..#adjustment') is not null
			drop table #adjustment
			create table #adjustment(name nvarchar(2000))
			declare c2 cursor fast_forward for select table_name from information_schema.tables where
			table_name like 't_aj_%' and table_name not in ('T_AJ_TEMPLATE_REASON_CODE_MAP','t_aj_type_applic_map')
			open c2
			fetch next from c2 into @var1
			while (@@fetch_status = 0)
			begin
			--Get the name of t_aj tables that have usage in this interval
			set @sql1 = N'if exists
					(select 1 from ' + @var1 + ' where id_adjustment in
					(select id_adj_trx from t_adjustment_transaction where id_usage_interval = ' + cast(@interval as varchar(10)) + N'))
					insert into #adjustment values(''' + @var1 + ''')'
					EXEC sp_executesql @sql1
			SET @sql1 = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP view bcpview'
					EXEC sp_executesql @sql1
			fetch next from c2 into @var1
			end
			close c2
			deallocate c2

			if object_id('tempdb..tmp_t_adjustment_transaction') is not null
			drop table tempdb..tmp_t_adjustment_transaction
			select @sql1 = N'SELECT id_adj_trx into tempdb..tmp_t_adjustment_transaction FROM ' + @dbname + '..t_adjustment_transaction where id_usage_interval=' + cast (@interval as varchar(10)) + N' order by id_sess'
			exec (@sql1)
			create unique clustered index idx_tmp_t_adjustment_transaction on tempdb..tmp_t_adjustment_transaction(id_adj_trx)
			declare  c1 cursor fast_forward for select distinct name from #adjustment
			open c1
			fetch next from c1 into @var1
			while (@@fetch_status = 0)
			begin
				--Delete from t_aj tables
				select @sql1 = N'delete aj FROM ' + @dbname + '..' + @var1 +  ' aj inner join
				tempdb..tmp_t_adjustment_transaction tmp on aj.id_adjustment = tmp.id_adj_trx'
				exec (@sql1)
				if (@@error <> 0)
				begin
					set @result = '2000007-archive operation failed-->Error in t_aj tables Delete operation'
					rollback tran
					close c1
					deallocate c1
					close interval_id
					deallocate interval_id
					return
				end
			fetch next from c1 into @var1
			end
			close c1
			deallocate c1

			--Delete from t_adjustment_transaction table
			select @sql1 = N'delete FROM ' + @dbname + '..t_adjustment_transaction where id_usage_interval=' + cast (@interval as varchar(10))
			exec (@sql1)
			if (@@error <> 0)
			begin
				set @result = '2000008-Error in Delete from t_adjustment_transaction table'
				rollback tran
				close interval_id
				deallocate interval_id
				return
			end
			commit tran
			--Delete from Unique constraints table
			if (select b_partitioning_enabled from t_usage_server) = 'Y'
			begin
				declare  c3 cursor fast_forward for select nm_table_name from t_unique_cons
				open c3
				fetch next from c3 into @tab1
				while (@@fetch_status = 0)
				begin
					select @sql1 = N'select @min_id_sess = min(id_sess) FROM ' + @dbname + '..' + @tab1 + ' where id_usage_interval=' + cast (@interval as varchar(10))
					SET @ParmDefinition = N' @min_id_sess varchar(30) OUTPUT';
					exec sp_executesql @sql1,@ParmDefinition,@min_id_sess=@min_id_sess OUTPUT
					select @sql1 = N'select @max_id_sess = max(id_sess) FROM ' + @dbname + '..' + @tab1 + ' where id_usage_interval=' + cast (@interval as varchar(10))
					SET @ParmDefinition = N' @max_id_sess varchar(30) OUTPUT'
					exec sp_executesql @sql1,@ParmDefinition,@max_id_sess=@max_id_sess OUTPUT
					while (@min_id_sess < @max_id_sess)
					begin
					begin tran
					select @sql1 = N'delete FROM ' + @dbname + '..' + @tab1 + ' where id_usage_interval=' + cast (@interval as varchar(10)) +
								' and id_sess between ' + cast(@min_id_sess as varchar(10)) + ' and ' + cast(@min_id_sess as varchar(10)) + ' + 1000000'
					exec (@sql1)
					if (@@error <> 0)
					begin
						set @result = '2000024-Error in Delete from unique constraint table'
						rollback tran
						close c3
						deallocate c3
						close interval_id
						deallocate interval_id
						return
					end
					commit tran
					set @min_id_sess = @min_id_sess + 1000001
					end
				fetch next from c3 into @tab1
				end
				close c3
				deallocate c3
			end

			begin tran
			--Checking for post bill adjustments that have corresponding usage archived
			if object_id('tempdb..#t_adjustment_transaction_temp') is not null
			drop table #t_adjustment_transaction_temp
			create table #t_adjustment_transaction_temp(id_sess bigint)
			select @sql1 =  N'insert into #t_adjustment_transaction_temp select id_sess
						from t_adjustment_transaction where n_adjustmenttype=1
						and id_sess in (select id_sess from t_acc_usage where id_usage_interval=' + cast(@interval as varchar(10)) + ' )'
			execute (@sql1)
			if (@@error <> 0)
			begin
				set @result = '2000009-archive operation failed-->Error in create adjustment temp table operation'
				rollback tran
				close interval_id
				deallocate interval_id
				return
			end
			IF ((SELECT count(*) FROM #t_adjustment_transaction_temp) > 0)
			begin
				update t_adjustment_transaction set archive_sess=id_sess,id_sess=null
				where id_sess in (select id_sess from #t_adjustment_transaction_temp)
				if (@@error <> 0)
				begin
					set @result = '2000010-archive operation failed-->Error in Update adjustment operation'
					rollback tran
					close interval_id
					deallocate interval_id
					return
				end
			end
			update t_acc_bucket_map
			set tt_end = dateadd(s,-1,@vartime)
			where id_usage_interval=@interval
			and status = 'E'
			and tt_end=@maxtime
			if (@@error <> 0)
			begin
				set @result = '2000011-archive operation failed-->Error in update t_acc_bucket_map table'
				rollback tran
				close interval_id
				deallocate interval_id
				return
			end
			insert into t_acc_bucket_map (id_usage_interval,id_acc,bucket,status,tt_start,tt_end)
			select @interval,id_acc,bucket,'A',@vartime,@maxtime from t_acc_bucket_map
			where id_usage_interval=@interval
			and status ='E'
			and tt_end=dateadd(s,-1,@vartime)
			if (@@error <> 0)
			begin
				set @result = '2000012-archive operation failed-->Error in insert into t_acc_bucket_map table'
				rollback tran
				close interval_id
				deallocate interval_id
				return
			end

			update t_archive
			set tt_end = dateadd(s,-1,@vartime)
			where id_interval=@interval
			and status='E'
			and tt_end=@maxtime
			if (@@error <> 0)
			begin
				set @result = '2000013-archive operation failed-->Error in update t_archive table'
				rollback tran
				close interval_id
				deallocate interval_id
				return
			end
			insert into t_archive
			select id_interval,id_view,adj_name,'A',@vartime,@maxtime from t_archive
			where id_interval = @interval
			and status ='E'
			and tt_end=dateadd(s,-1,@vartime)
			if (@@error <> 0)
			begin
				set @result = '2000014-archive operation failed-->Error in insert t_archive table'
				rollback tran
				close interval_id
				deallocate interval_id
				return
			end
		fetch next from interval_id into @interval
		end
		close interval_id
		deallocate interval_id

		if (@partition is null)
		begin
			if  ((select count(*) from t_partition_interval_map map where id_partition = (select id_partition
			from t_partition_interval_map where id_interval = @intervalid)) <= 1) and
			(select b_partitioning_enabled from t_usage_server) = 'Y'
			begin
				select @partition = partition_name from t_partition part inner join t_partition_interval_map map
				on part.id_partition = map.id_partition where map.id_interval = @intervalid
				set @intervalid = null
			end
		end

		if (@partition is not null)
		begin
			if object_id('tempdb..##id_view') is not null
			drop table ##id_view
			select @sql1 = ' select distinct id_view into ##id_view from ' + @partition + '..t_acc_usage'
			exec (@sql1)
				declare  c1 cursor fast_forward for select id_view from ##id_view
				open c1
				fetch next from c1 into @var1
				while (@@fetch_status = 0)
				begin
					select @tab1 = nm_table_name from t_prod_view where id_view=@var1 --and nm_table_name not like '%temp%'
					--Delete from product view tables
					select @sql1 = N'truncate table ' + @partition + '..' + @tab1
					exec (@sql1)
					if (@@error <> 0)
					begin
						set @result = '2000015-archive operation failed-->Error in product view Delete operation'
						rollback tran
						close c1
						deallocate c1
						return
					end
				fetch next from c1 into @var1
				end
				close c1
				deallocate c1

			--Delete from t_acc_usage table
			select @sql1 = N'truncate table ' + @partition + '..t_acc_usage'
			exec (@sql1)
			if (@@error <> 0)
			begin
				set @result = '2000016-archive operation failed-->Error in Delete t_acc_usage operation'
				rollback tran
				return
			end
		end

		if (@intervalid is not null)
		begin
			if object_id('tempdb..##id_view') is not null
			drop table ##id_view
			select @sql1 = ' select distinct id_view into ##id_view from t_acc_usage  where id_usage_interval = ' + cast(@intervalid as nvarchar(100))
			exec (@sql1)
			declare  c1 cursor fast_forward for select id_view from ##id_view
			open c1
			fetch next from c1 into @var1
			while (@@fetch_status = 0)
			begin
				select @tab1 = nm_table_name from t_prod_view where id_view=@var1 --and nm_table_name not like '%temp%'
				--Delete from product view tables
				select @sql1 = N'delete pv FROM ' + @tab1 + ' pv inner join t_acc_usage tmp on
				pv.id_sess = tmp.id_sess and pv.id_usage_interval=tmp.id_usage_interval
				and tmp.id_usage_interval = ' + cast(@intervalid as nvarchar(100))
				exec (@sql1)
				if (@@error <> 0)
				begin
					set @result = '2000017-archive operation failed-->Error in product view Delete operation'
					rollback tran
					close c1
					deallocate c1
					return
				end
			fetch next from c1 into @var1
			end
			close c1
			deallocate c1
			--Delete from t_acc_usage table
			select @sql1 = N'delete au from t_acc_usage au
			where au.id_usage_interval = ' + cast(@intervalid as nvarchar(100))
			exec (@sql1)
			if (@@error <> 0)
			begin
				set @result = '2000018-archive operation failed-->Error in Delete t_acc_usage operation'
				rollback tran
				return
			end
		end

		if
		(
		(
			(@partition is not null)
			or not exists
			(
				select 1
				from t_partition_interval_map map
				left outer join t_archive inte on inte.id_interval = map.id_interval and tt_end = @maxtime
				where map.id_partition = (select id_partition from t_partition_interval_map where id_interval = @intervalid) and (status is null or status <> 'A')
			)
		)
		and
			(select b_partitioning_enabled from t_usage_server) = 'Y'
		)
		begin
			update t_archive_partition
			set tt_end = dateadd(s,-1,@vartime)
			where partition_name = isnull(@partition,@partition1)
			and tt_end= @maxtime
			and status = 'E'
			if (@@error <> 0)
			begin
				set @result = '2000021-archive operation failed-->Error in update t_archive_partition table'
				rollback tran
				return
			end
			insert into t_archive_partition values(isnull(@partition,@partition1),'A',@vartime,@maxtime)
			if (@@error <> 0)
			begin
				set @result = '2000022-archive operation failed-->Error in insert into t_archive_partition table'
				rollback tran
				return
			end
			update t_partition set b_active = 'N' where partition_name = isnull(@partition,@partition1)
			if (@@error <> 0)
			begin
				set @result = '2000023-archive operation failed-->Error in update t_partition table'
				rollback tran
				return
			end
		end

		if object_id('tempdb..tmp_t_adjustment_transaction') is not null
		drop table tempdb..tmp_t_adjustment_transaction
		if object_id('tempdb..##id_view') is not null
		drop table ##id_view

		set @result = '0-archive_delete operation successful'
		commit tran
		
    
GO
PRINT N'Altering [dbo].[CreateAccountStateRecord]'
GO

     
ALTER Procedure CreateAccountStateRecord (
@p_id_acc int,
@p_status varchar(2),
@startdate  datetime,
@enddate datetime,
@p_systemdate datetime,
@status int OUTPUT
)
as
declare @realstartdate datetime
declare @realenddate datetime
declare @varMaxDateTime datetime
declare @tempStartDate datetime
declare @tempEndDate datetime
declare @onesecond_systemdate datetime
declare @temp_id_acc int
declare @temp_status varchar(2)

begin

-- detect directly adjacent records with a adjacent start and end date.  If the
-- key comparison matches successfully, use the start and/or end date of the original record 
-- instead.

select @realstartdate = @startdate,@realenddate = @enddate,@varMaxDateTime = dbo.mtmaxdate(),
  @onesecond_systemdate = dbo.subtractsecond(@p_systemdate)

 -- Someone changes the start date of an existing record so that it creates gaps in time
 -- Existing Record      |---------------------|
 -- modified record       	|-----------|
 -- modified record      |-----------------|
 -- modified record         |------------------|
	begin
		
		-- find the start and end dates of the original interval
		select 
		@tempstartdate = vt_start,
		@tempenddate = vt_end
    from
    t_account_state_history with(updlock)
    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    id_acc = @p_id_acc AND status = @p_status and tt_end = @varMaxDateTime 

		-- the original date range is no longer true
		update t_account_state_history
    set tt_end = @onesecond_systemdate
		where id_acc = @p_id_acc AND status = @p_status AND vt_start = @tempstartdate AND
		@tempenddate = vt_end AND tt_end = @varMaxDateTime

		-- adjust the two records end dates that are adjacent on the start and
		-- end dates; these records are no longer true
		update t_account_state_history 
		set tt_end = @onesecond_systemdate where
		id_acc = @p_id_acc AND tt_end = @varMaxDateTime AND
		(vt_end = dbo.subtractSecond(@tempstartdate) OR vt_start = dbo.addsecond(@tempenddate))
    if (@@error <> 0 )
		begin
    select @status = 0
		end

		insert into t_account_state_history 
		(id_acc,status,vt_start,vt_end,tt_start,tt_end)
		select 
			id_acc,status,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime
			from t_account_state_history 
			where
			id_acc = @p_id_acc AND vt_end = dbo.subtractSecond(@tempstartdate)
		UNION ALL
		select
			id_acc,status,@realenddate,vt_end,@p_systemdate,@varMaxDateTime
			from t_account_state_history
			where
			id_acc = @p_id_acc  AND vt_start = dbo.addsecond(@tempenddate)

	end

	-- detect directly adjacent records with a adjacent start and end date.  If the
	-- key comparison matches successfully, use the start and/or end date of the original record 
	-- instead.
	
	select @realstartdate = vt_start
	from 
	t_account_state_history  where id_acc = @p_id_acc AND status = @p_status AND
		@startdate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime
	if @realstartdate is NULL begin
		select @realstartdate = @startdate
	end
	--CR 10620 fix: Do not add a second to end date
	select @realenddate = vt_end
	from
	t_account_state_history  where id_acc = @p_id_acc AND status = @p_status AND
	@enddate between vt_start AND vt_end and tt_end = @varMaxDateTime
	if @realenddate is NULL begin
		select @realenddate = @enddate
	end

 -- step : delete a range that is entirely in the new date range
 -- existing record:      |----|
 -- new record:      |----------------|
 update  t_account_state_history 
 set tt_end = @onesecond_systemdate
 where dbo.EnclosedDateRange(@realstartdate,@realenddate,vt_start,vt_end) =1 AND
 id_acc = @p_id_acc  AND tt_end = @varMaxDateTime 

 -- create two new records that are on around the new interval        
 -- existing record:          |-----------------------------------|
 -- new record                        |-------|
 --
 -- adjusted old records      |-------|       |--------------------|
  begin
    select
		@temp_id_acc = id_acc,
@temp_status = status

		,@tempstartdate = vt_start,
		@tempenddate = vt_end
    from
    t_account_state_history
    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    id_acc = @p_id_acc and tt_end = @varMaxDateTime AND  status <> @p_status
    update     t_account_state_history 
    set tt_end = @onesecond_systemdate where
    dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    id_acc = @p_id_acc AND tt_end = @varMaxDateTime AND  status <> @p_status
   
-- CR 14491 - Primary keys can not be null
if ((@temp_id_acc is not null))
begin

insert into t_account_state_history 
   (id_acc,status,vt_start,vt_end,tt_start,tt_end)
   select 
    @temp_id_acc,@temp_status,@tempStartDate,dbo.subtractsecond(@realstartdate),
    @p_systemdate,@varMaxDateTime
    where @tempstartdate is not NULL AND @tempStartDate <> @realstartdate
    -- the previous statement may fail
		if @realenddate <> @tempendDate AND @realenddate <> @varMaxDateTime begin
			insert into t_account_state_history 
			(id_acc,status,vt_start,vt_end,tt_start,tt_end)
	    select
	    @temp_id_acc,@temp_status,@realenddate,@tempEndDate,
	    @p_systemdate,@varMaxDateTime
		end
      
end

  -- the previous statement may fail
  end
 -- step 5: update existing payment records that are overlapping on the start
 -- range
 -- Existing Record |--------------|
 -- New Record: |---------|
 insert into t_account_state_history
 (id_acc,status,vt_start,vt_end,tt_start,tt_end)
 select 
 id_acc,status,@realenddate,vt_end,@p_systemdate,@varMaxDateTime
 from 
 t_account_state_history  where
 id_acc = @p_id_acc AND 
 vt_start > @realstartdate and vt_start < @realenddate 
 and tt_end = @varMaxDateTime
 
 update t_account_state_history
 set tt_end = @onesecond_systemdate
 where
 id_acc = @p_id_acc AND 
 vt_start > @realstartdate and vt_start < @realenddate 
 and tt_end = @varMaxDateTime
 -- step 4: update existing payment records that are overlapping on the end
 -- range
 -- Existing Record |--------------|
 -- New Record:             |-----------|
 insert into t_account_state_history
 (id_acc,status,vt_start,vt_end,tt_start,tt_end)
 select
 id_acc,status,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime
 from t_account_state_history
 where
 id_acc = @p_id_acc AND 
 vt_end > @realstartdate AND vt_end < @realenddate
 AND tt_end = @varMaxDateTime
 update t_account_state_history
 set tt_end = @onesecond_systemdate
 where id_acc = @p_id_acc AND 
  vt_end > @realstartdate AND vt_end < @realenddate
 AND tt_end = @varMaxDateTime
 -- used to be realenddate
 -- step 7: create the new payment redirection record.  If the end date 
 -- is not max date, make sure the enddate is subtracted by one second
 insert into t_account_state_history 
 (id_acc,status,vt_start,vt_end,tt_start,tt_end)
 select 
 @p_id_acc,@p_status,@realstartdate,
  case when @realenddate = dbo.mtmaxdate() then @realenddate else 
  dbo.subtractsecond(@realenddate) end,
  @p_systemdate,@varMaxDateTime
  
delete from t_account_state where id_acc = @p_id_acc
insert into t_account_state (id_acc,status,vt_start,vt_end)
select id_acc,status,vt_start,vt_end
from t_account_state_history  where
id_acc = @p_id_acc and tt_end = @varMaxDateTime
 select @status = 1
 end
			
GO
PRINT N'Altering [dbo].[CreateGSubMemberRecord]'
GO

     
ALTER Procedure CreateGSubMemberRecord (
@p_id_group int,
@p_id_acc int,
@startdate  datetime,
@enddate datetime,
@p_systemdate datetime,
@status int OUTPUT
)
as
declare @realstartdate datetime
declare @realenddate datetime
declare @varMaxDateTime datetime
declare @tempStartDate datetime
declare @tempEndDate datetime
declare @onesecond_systemdate datetime
declare @temp_id_group int
declare @temp_id_acc int

begin

-- detect directly adjacent records with a adjacent start and end date.  If the
-- key comparison matches successfully, use the start and/or end date of the original record 
-- instead.

select @realstartdate = @startdate,@realenddate = @enddate,@varMaxDateTime = dbo.mtmaxdate(),
  @onesecond_systemdate = dbo.subtractsecond(@p_systemdate)

 -- Someone changes the start date of an existing record so that it creates gaps in time
 -- Existing Record      |---------------------|
 -- modified record       	|-----------|
 -- modified record      |-----------------|
 -- modified record         |------------------|
	begin
		
		-- find the start and end dates of the original interval
		select 
		@tempstartdate = vt_start,
		@tempenddate = vt_end
    from
    t_gsubmember_historical with(updlock)
    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    id_group = @p_id_group AND id_acc = @p_id_acc and tt_end = @varMaxDateTime 

		-- the original date range is no longer true
		update t_gsubmember_historical
    set tt_end = @onesecond_systemdate
		where id_group = @p_id_group AND id_acc = @p_id_acc AND vt_start = @tempstartdate AND
		@tempenddate = vt_end AND tt_end = @varMaxDateTime

		-- adjust the two records end dates that are adjacent on the start and
		-- end dates; these records are no longer true
		update t_gsubmember_historical 
		set tt_end = @onesecond_systemdate where
		id_group = @p_id_group AND id_acc = @p_id_acc AND tt_end = @varMaxDateTime AND
		(vt_end = dbo.subtractSecond(@tempstartdate) OR vt_start = dbo.addsecond(@tempenddate))
    if (@@error <> 0 )
		begin
    select @status = 0
		end

		insert into t_gsubmember_historical 
		(id_group,id_acc,vt_start,vt_end,tt_start,tt_end)
		select 
			id_group,id_acc,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime
			from t_gsubmember_historical 
			where
			id_group = @p_id_group AND id_acc = @p_id_acc AND vt_end = dbo.subtractSecond(@tempstartdate)
		UNION ALL
		select
			id_group,id_acc,@realenddate,vt_end,@p_systemdate,@varMaxDateTime
			from t_gsubmember_historical
			where
			id_group = @p_id_group AND id_acc = @p_id_acc  AND vt_start = dbo.addsecond(@tempenddate)

	end

	-- detect directly adjacent records with a adjacent start and end date.  If the
	-- key comparison matches successfully, use the start and/or end date of the original record 
	-- instead.
	
	select @realstartdate = vt_start
	from 
	t_gsubmember_historical  where id_group = @p_id_group AND id_acc = @p_id_acc AND
		@startdate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime
	if @realstartdate is NULL begin
		select @realstartdate = @startdate
	end
	--CR 10620 fix: Do not add a second to end date
	select @realenddate = vt_end
	from
	t_gsubmember_historical  where id_group = @p_id_group AND id_acc = @p_id_acc AND
	@enddate between vt_start AND vt_end and tt_end = @varMaxDateTime
	if @realenddate is NULL begin
		select @realenddate = @enddate
	end

 -- step : delete a range that is entirely in the new date range
 -- existing record:      |----|
 -- new record:      |----------------|
 update  t_gsubmember_historical 
 set tt_end = @onesecond_systemdate
 where dbo.EnclosedDateRange(@realstartdate,@realenddate,vt_start,vt_end) =1 AND
 id_group = @p_id_group AND id_acc = @p_id_acc  AND tt_end = @varMaxDateTime 

 -- create two new records that are on around the new interval        
 -- existing record:          |-----------------------------------|
 -- new record                        |-------|
 --
 -- adjusted old records      |-------|       |--------------------|
  begin
    select
		@temp_id_group = id_group,
@temp_id_acc = id_acc

		,@tempstartdate = vt_start,
		@tempenddate = vt_end
    from
    t_gsubmember_historical
    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    id_group = @p_id_group AND id_acc = @p_id_acc and tt_end = @varMaxDateTime
    update     t_gsubmember_historical 
    set tt_end = @onesecond_systemdate where
    dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
    id_group = @p_id_group AND id_acc = @p_id_acc AND tt_end = @varMaxDateTime
   
-- CR 14491 - Primary keys can not be null
if ((@temp_id_group is not null) AND (@temp_id_acc is not null))
begin

insert into t_gsubmember_historical 
   (id_group,id_acc,vt_start,vt_end,tt_start,tt_end)
   select 
    @temp_id_group,@temp_id_acc,@tempStartDate,dbo.subtractsecond(@realstartdate),
    @p_systemdate,@varMaxDateTime
    where @tempstartdate is not NULL AND @tempStartDate <> @realstartdate
    -- the previous statement may fail
		if @realenddate <> @tempendDate AND @realenddate <> @varMaxDateTime begin
			insert into t_gsubmember_historical 
			(id_group,id_acc,vt_start,vt_end,tt_start,tt_end)
	    select
	    @temp_id_group,@temp_id_acc,@realenddate,@tempEndDate,
	    @p_systemdate,@varMaxDateTime
		end
      
end

  -- the previous statement may fail
  end
 -- step 5: update existing payment records that are overlapping on the start
 -- range
 -- Existing Record |--------------|
 -- New Record: |---------|
 insert into t_gsubmember_historical
 (id_group,id_acc,vt_start,vt_end,tt_start,tt_end)
 select 
 id_group,id_acc,@realenddate,vt_end,@p_systemdate,@varMaxDateTime
 from 
 t_gsubmember_historical  where
 id_group = @p_id_group AND id_acc = @p_id_acc AND 
 vt_start > @realstartdate and vt_start < @realenddate 
 and tt_end = @varMaxDateTime
 
 update t_gsubmember_historical
 set tt_end = @onesecond_systemdate
 where
 id_group = @p_id_group AND id_acc = @p_id_acc AND 
 vt_start > @realstartdate and vt_start < @realenddate 
 and tt_end = @varMaxDateTime
 -- step 4: update existing payment records that are overlapping on the end
 -- range
 -- Existing Record |--------------|
 -- New Record:             |-----------|
 insert into t_gsubmember_historical
 (id_group,id_acc,vt_start,vt_end,tt_start,tt_end)
 select
 id_group,id_acc,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime
 from t_gsubmember_historical
 where
 id_group = @p_id_group AND id_acc = @p_id_acc AND 
 vt_end > @realstartdate AND vt_end < @realenddate
 AND tt_end = @varMaxDateTime
 update t_gsubmember_historical
 set tt_end = @onesecond_systemdate
 where id_group = @p_id_group AND id_acc = @p_id_acc AND 
  vt_end > @realstartdate AND vt_end < @realenddate
 AND tt_end = @varMaxDateTime
 -- used to be realenddate
 -- step 7: create the new payment redirection record.  If the end date 
 -- is not max date, make sure the enddate is subtracted by one second
 insert into t_gsubmember_historical 
 (id_group,id_acc,vt_start,vt_end,tt_start,tt_end)
 select 
 @p_id_group,@p_id_acc,@realstartdate,
  case when @realenddate = dbo.mtmaxdate() then @realenddate else 
  @realenddate end,
  @p_systemdate,@varMaxDateTime
  
delete from t_gsubmember where id_group = @p_id_group AND id_acc = @p_id_acc
insert into t_gsubmember (id_group,id_acc,vt_start,vt_end)
select id_group,id_acc,vt_start,vt_end
from t_gsubmember_historical  where
id_group = @p_id_group AND id_acc = @p_id_acc and tt_end = @varMaxDateTime
 select @status = 1
 end
			
GO
PRINT N'Creating [dbo].[createUIEvent]'
GO

        
        CREATE PROCEDURE createUIEvent
          @EventType varchar(50),
          @JSONBlob ntext,
          @AccountID int
          AS
          Begin
            Set NoCount on
            DECLARE @EventID INT
            
            INSERT INTO [dbo].[t_ui_event]
              ([tx_event_type]
              ,[json_blob])
            VALUES
               (@EventType, @JSONBlob)
          
            -- Get new event id
            Select @EventID = @@Identity

            INSERT INTO [dbo].[t_ui_event_queue]
                   ([id_event]
                   ,[id_acc]
                   ,[dt_crt]
                   ,[dt_viewed]
                   ,[b_deleted]
				           ,[b_bubbled])
             VALUES
                   (@EventID
                   ,@AccountID
                   ,GetUTCDate()
                   ,NULL
                   ,'0'
                   ,'0')
          End			
			
GO
PRINT N'Altering [dbo].[archive_queue]'
GO

    
ALTER  procedure archive_queue
   (
   @update_stats char(1) = 'N',  
   @sampling_ratio varchar(3) = '30',  
   @result nvarchar(4000) output  
   )  
  as  
  --How to run this stored procedure  
--declare @result nvarchar(2000)  
--exec archive_queue @result=@result output  
--print @result 
--OR If we want to update statistics also
--declare @result nvarchar(2000)
--exec archive_queue 'Y',30,@result=@result output
--print @result
 
  set nocount on  
  declare @sql1 nvarchar(4000)  
  declare @tab1 nvarchar(1000)  
  declare @var1 nvarchar(1000)  
  declare @vartime datetime  
  declare @maxtime datetime  
  declare @count nvarchar(10)  
  declare @NU_varStatPercentChar varchar(255)
  declare @id char(1)
  
--create table t_archive_queue (id_svc int, status varchar(1), tt_start datetime, tt_end datetime)  
  select @vartime = getdate()  
  select @maxtime = dbo.mtmaxdate()  
  
  if object_id('tempdb..##tmp_t_session_state') is not null drop table ##tmp_t_session_state  
  if (@@error <> 0)   
  begin  
	   set @result = '7000001--archive_queues operation failed-->error in dropping ##tmp_t_session_state'  
	   return  
  end  
  
  if object_id('tempdb..#tmp2_t_session_state') is not null drop table #tmp2_t_session_state  
  if (@@error <> 0)   
  begin  
	   set @result = '7000001a--archive_queues operation failed-->error in dropping #tmp2_t_session_state'  
	   return  
  end    
  begin tran
--Lock all the session tables
  declare  c1 cursor fast_forward for   
  select nm_table_name from t_service_def_log
  open c1  
  fetch next from c1 into @tab1  
  while (@@fetch_status = 0)  
  begin  
	   set @sql1 = 'select 1 from ' + @tab1 + ' with(tablockx) where 0=1'
	   exec (@sql1)
  fetch next from c1 into @tab1  
  end  
  close c1  
  deallocate c1  

   set @sql1 = 'select 1 from t_message with(tablockx) where 0=1'
   exec (@sql1)
   set @sql1 = 'select 1 from t_session_set with(tablockx) where 0=1'
   exec (@sql1)
   set @sql1 = 'select 1 from t_session with(tablockx) where 0=1'
   exec (@sql1)
   set @sql1 = 'select 1 from t_session_state with(tablockx) where 0=1'
   exec (@sql1)

  create table ##tmp_t_session_state(id_sess varbinary(16))  
  create clustered index idx_tmp_t_session_state on ##tmp_t_session_state(id_sess)  
  insert into ##tmp_t_session_state   
  select sess.id_source_sess  
  from t_session sess where not exists (select 1 from t_session_state state where  
  state.id_sess = sess.id_source_sess)  
  union all  
  select id_sess from t_session_state state where tx_state in ('F','R')  
  and state.dt_end = @maxtime  
  if (@@error <> 0)  
  begin
	set @result = '7000002-archive_queues operation failed-->Error in creating ##tmp_t_session_state'
	rollback tran  
	return  
  end  

  if exists (select 1 from t_prod_view where b_can_resubmit_from = 'N'  
  and nm_table_name not like 't_acc_usage')  
  begin
	   if (select b_partitioning_enabled from t_usage_server) = 'N'  
	   begin  
		    insert into ##tmp_t_session_state   
		    select state.id_sess  
		    from t_acc_usage au inner join   
		    t_session_state state  
		    on au.tx_uid = state.id_sess  
		    inner join t_prod_view prod   
		    on au.id_view = prod.id_view and prod.b_can_resubmit_from='N'  
		    where state.dt_end = @maxtime
		    and au.id_usage_interval in  
		    (select distinct id_interval from t_usage_interval  
		    where tx_interval_status <> 'H'  
		    )
		    if (@@error <> 0)  
		    begin
						set @result = '7000003-archive_queues operation failed-->Error in creating ##tmp_t_session_state'  
		        rollback tran  
						return  
		    end  
	   end  
	   else  
	   begin  
		    insert into ##tmp_t_session_state   
		    select state.id_sess  
		    from t_session_state state  
		    inner join t_uk_acc_usage_tx_uid uk_uid  
		    on state.id_sess = uk_uid.tx_uid  
		    inner join t_acc_usage au  
		    on au.id_sess = uk_uid.id_sess  
		    inner join t_prod_view prod   
		    on au.id_view = prod.id_view and prod.b_can_resubmit_from='N'  
		    where state.dt_end = @maxtime
		    and au.id_usage_interval in  
		    (select distinct id_interval from t_usage_interval  
		    where tx_interval_status <> 'H'  
		    )
		    if (@@error <> 0)  
		    begin  
			    set @result = '7000004-archive_queues operation failed-->Error in creating ##tmp_t_session_state'  
			    rollback tran  
			    return  
		   end  
	   end  
  end  
    
  declare  c1 cursor fast_forward for   
  select nm_table_name from t_service_def_log  
  open c1  
  fetch next from c1 into @tab1  
  while (@@fetch_status = 0)  
  begin
	if object_id('tempdb..##svc') is not null
	drop table ##svc
	if (@@error <> 0)   
	begin  
	    set @result = '7000005--archive_queues operation failed-->error in dropping ##svc table'  
	    rollback tran  
	    close c1  
	    deallocate c1  
	    return  
	end  
	select @sql1 = N'select * into ##svc from ' + @tab1 + ' where id_source_sess  
   	in (select id_sess from ##tmp_t_session_state)'  
   	exec (@sql1)  
   	if (@@error <> 0)  
   	begin  
    		set @result = '7000006-archive_queues operation failed-->Error in t_svc Delete operation'  
    		rollback tran  
    		close c1  
    		deallocate c1  
    		return  
   	end  
   	exec ('truncate table ' + @tab1)  
   	if (@@error <> 0)  
   	begin  
	    set @result = '7000007-archive_queues operation failed-->Error in t_svc Delete operation'  
	    rollback tran  
	    close c1  
	    deallocate c1  
	    return  
   	end  
	select @sql1 = N'insert into ' + @tab1 + ' select * from ##svc'  
	exec (@sql1)  
	if (@@error <> 0)  
	begin  
	    set @result = '7000008-archive_queues operation failed-->Error in t_svc Delete operation'  
	    rollback tran  
	    close c1  
	    deallocate c1  
	    return  
	end  
   	--Delete from t_svc tables  
   	insert into t_archive_queue (id_svc,status,tt_start,tt_end)  
   	select @tab1,'A',@vartime,@maxtime  
   	if (@@error <> 0)  
  	begin  
	    set @result = '7000009-archive_queues operation failed-->Error in insert t_archive table'  
	    rollback tran  
	    close c1  
	    deallocate c1  
	    return  
   	end  
  fetch next from c1 into @tab1  
  end  
  close c1  
  deallocate c1  
  
  --Delete from t_session and t_session_state table  
  if object_id('tempdb..#tmp_t_session') is not null drop table #tmp_t_session  
  select * into #tmp_t_session from t_session where id_source_sess  
  in (select id_sess from ##tmp_t_session_state)   
  if (@@error <> 0)  
  begin  
	   set @result = '7000010-archive_queues operation failed-->Error in insert into tmp_t_session'  
	   rollback tran  
	   return  
  end  
  truncate table t_session  
  if (@@error <> 0)  
  begin  
	   set @result = '7000011-archive_queues operation failed-->Error in Delete from t_session'  
	   rollback tran  
	   return  
  end  
  insert into t_session select * from #tmp_t_session  
  if (@@error <> 0)  
  begin  
	   set @result = '7000012-archive_queues operation failed-->Error in insert into t_session'  
	   rollback tran  
	   return  
  end  
  if object_id('tempdb..#tmp_t_session_set') is not null drop table #tmp_t_session_set  
  select * into #tmp_t_session_set from t_session_set where id_ss in  
  (select id_ss from t_session)  
  if (@@error <> 0)  
  begin  
	   set @result = '7000013-archive_queues operation failed-->Error in insert into tmp_t_session_set'  
	   rollback tran  
	   return  
  end  
  truncate table t_session_set  
  if (@@error <> 0)  
  begin  
	   set @result = '7000014-archive_queues operation failed-->Error in Delete from t_session_set'  
	   rollback tran  
	   return  
  end  
  insert into t_session_set select * from #tmp_t_session_set  
  if (@@error <> 0)  
  begin  
	   set @result = '7000015-archive_queues operation failed-->Error in insert into t_session_set'  
	   rollback tran  
	   return  
  end  
  if object_id('tempdb..#tmp_t_message') is not null drop table #tmp_t_message  
  select * into #tmp_t_message from t_message where id_message in  
  (select id_message from t_session_set)  
  if (@@error <> 0)  
  begin  
	   set @result = '7000016-archive_queues operation failed-->Error in insert into tmp_t_message'  
	   rollback tran  
	   return  
  end  
  truncate table t_message  
  if (@@error <> 0)  
  begin  
	   set @result = '7000017-archive_queues operation failed-->Error in Delete from t_message'  
	   rollback tran  
	   return  
  end  
  insert into t_message select * from #tmp_t_message  
  if (@@error <> 0)  
  begin  
	   set @result = '7000018-archive_queues operation failed-->Error in insert into t_message'  
	   rollback tran  
	   return  
  end  
  select state.* into #tmp2_t_session_state from t_session_state state  
  where state.id_sess in  
  (select id_sess from ##tmp_t_session_state)  
  if (@@error <> 0)  
  begin  
	   set @result = '7000019-archive_queues operation failed-->Error in creating #tmp2_t_session_state'  
	   return  
  end  
  
  truncate table t_session_state  
  if (@@error <> 0)  
  begin  
	   set @result = '7000020-archive_queues operation failed-->Error in Delete from t_session_state table'  
	   rollback tran  
	   return  
  end  
  insert into t_session_state select * from #tmp2_t_session_state  
  if (@@error <> 0)  
  begin  
	   set @result = '7000021-archive_queues operation failed-->Error in insert into t_session_state table'  
	   rollback tran  
	   return  
  end  
  
  if object_id('tempdb..##svc') is not null drop table ##svc  
  if object_id('tempdb..##tmp_t_session_state') is not null drop table ##tmp_t_session_state  
  if object_id('tempdb..#tmp2_t_session_state') is not null drop table #tmp2_t_session_state  
  if object_id('tempdb..#tmp_t_session_set') is not null drop table #tmp_t_session_set  
  if object_id('tempdb..#tmp_t_message') is not null drop table #tmp_t_message  
  if object_id('tempdb..#tmp_t_session') is not null drop table #tmp_t_session  
  commit tran  

  if (@update_stats = 'Y')  
  begin
	declare  c1 cursor fast_forward for select nm_table_name from t_service_def_log
	open c1  
	fetch next from c1 into @tab1  
	while (@@fetch_status = 0)  
	begin
	   IF @sampling_ratio < 5 SET @NU_varStatPercentChar = ' WITH SAMPLE 5 PERCENT '  
	   ELSE IF @sampling_ratio >= 100 SET @NU_varStatPercentChar = ' WITH FULLSCAN '  
	   ELSE SET @NU_varStatPercentChar = ' WITH SAMPLE ' + CAST(@sampling_ratio AS varchar(20)) + ' PERCENT '  
	   SET @sql1 = 'UPDATE STATISTICS ' + @tab1 + @NU_varStatPercentChar   
	   EXECUTE (@sql1)  
	   if (@@error <> 0)  
	   begin  
		     set @result = '7000022-archive_queues operation failed-->Error in update stats'  
		     rollback tran  
		     close c1  
		     deallocate c1  
		     return  
	   end  
	fetch next from c1 into @tab1  
	end  
	close c1  
	deallocate c1
	SET @sql1 = 'UPDATE STATISTICS t_session ' + @NU_varStatPercentChar   
	EXECUTE (@sql1)  
	SET @sql1 = 'UPDATE STATISTICS t_session_set ' + @NU_varStatPercentChar   
	EXECUTE (@sql1)  
	SET @sql1 = 'UPDATE STATISTICS t_session_state ' + @NU_varStatPercentChar   
	EXECUTE (@sql1)  
	SET @sql1 = 'UPDATE STATISTICS t_message' + @NU_varStatPercentChar   
	EXECUTE (@sql1)  
  end  
  
  set @result = '0-archive_queue operation successful'  
    
    
GO
PRINT N'Altering [dbo].[DeleteAccounts]'
GO

      
			ALTER Procedure DeleteAccounts
				@accountIDList nvarchar(4000), --accounts to be deleted
				@tablename nvarchar(4000), --table containing id_acc to be deleted
				@linkedservername nvarchar(255), --linked server name for payment server
				@PaymentServerdbname nvarchar(255) --payment server database name
			AS
			set nocount on
			set xact_abort on
			declare @sql nvarchar(4000)
	/*
			How to run this stored procedure
			exec DeleteAccounts @accountIDList='123,124',@tablename=null,@linkedservername=null,@PaymentServerdbname=null
			or
			exec DeleteAccounts @accountIDList=null,@tablename='tmp_t_account',@linkedservername=null,@PaymentServerdbname=null
	*/
				-- Break down into simple account IDs
				-- This block of SQL can be used as an example to get
				-- the account IDs from the list of account IDs that are
				-- passed in
				CREATE TABLE #AccountIDsTable (
				  ID int NOT NULL,
					status int NULL,
					message varchar(255) NULL)

				PRINT '------------------------------------------------'
				PRINT '-- Start of Account Deletion Stored Procedure --'
				PRINT '------------------------------------------------'

				if ((@accountIDList is not null and @tablename is not null) or
				(@accountIDList is null and @tablename is null))
				begin
					print 'ERROR--Delete account operation failed-->Either accountIDList or tablename should be specified'
					return -1
				END

				if (@accountIDList is not null)
				begin
					PRINT '-- Parsing Account IDs passed in and inserting in tmp table --'
					WHILE CHARINDEX(',', @accountIDList) > 0
					BEGIN
						INSERT INTO #AccountIDsTable (ID, status, message)
	 					SELECT SUBSTRING(@accountIDList,1,(CHARINDEX(',', @accountIDList)-1)), 1, 'Okay to delete'
	 					SET @accountIDList =
	 						SUBSTRING (@accountIDList, (CHARINDEX(',', @accountIDList)+1),
	  										(LEN(@accountIDList) - (CHARINDEX(',', @accountIDList))))
					END
	 						INSERT INTO #AccountIDsTable (ID, status, message)
							SELECT @accountIDList, 1, 'Okay to delete'
					-- SELECT ID as one FROM #AccountIDsTable

					-- Transitive Closure (check for folder/corporation)
					PRINT '-- Inserting children (if any) into the tmp table --'
					INSERT INTO #AccountIDsTable (ID, status, message)
					SELECT DISTINCT
					  aa.id_descendent,
						1,
						'Okay to delete'
					FROM
					  t_account_ancestor aa INNER JOIN #AccountIDsTable tmp ON
						tmp.ID = aa.id_ancestor AND
						aa.num_generations > 0 AND
					NOT EXISTS (
					  SELECT
						  ID
						FROM
						  #AccountIDsTable tmp1
						WHERE
						  tmp1.ID = aa.id_descendent)

					--fix bug 11599
					INSERT INTO #AccountIDsTable (ID, status, message)
					SELECT DISTINCT
					  aa.id_descendent,
						1,
						'Okay to delete'
					FROM
					  t_account_ancestor aa where id_ancestor in (select id from  #AccountIDsTable)
						AND
						aa.num_generations > 0 AND
					NOT EXISTS (
					  SELECT
						  ID
						FROM
						  #AccountIDsTable tmp1
						WHERE
						  tmp1.ID = aa.id_descendent)
				end
				else
				begin
					set @sql = 'INSERT INTO #AccountIDsTable (ID, status, message) SELECT id_acc,
							1, ''Okay to delete'' from ' + @tablename
					exec (@sql)
					INSERT INTO #AccountIDsTable (ID, status, message)
					SELECT DISTINCT
					  aa.id_descendent,
						1,
						'Okay to delete'
					FROM
					  t_account_ancestor aa INNER JOIN #AccountIDsTable tmp ON
						tmp.ID = aa.id_ancestor AND
						aa.num_generations > 0 AND
					NOT EXISTS (
					  SELECT
						  ID
						FROM
						  #AccountIDsTable tmp1
						WHERE
						  tmp1.ID = aa.id_descendent)
				end
				-- SELECT * from #AccountIDsTable

				/*
				-- print out the accounts with their login names
				SELECT
					ID as two,
					nm_login as two
				FROM
					#AccountIDsTable a,
					t_account_mapper b
				WHERE
					a.ID = b.id_acc
				*/

				/*
				 * Check for all the business rules.  We want to make sure
				 * that we are checking the more restrictive rules first
				 * 1. Check for usage in hard closed interval
				 * 2. Check for invoices in hard closed interval
				 * 3. Check if the account is a payer ever
				 * 4. Check if the account is a receiver of per subscription Recurring
				 *    Charge
				 * 5. Check for usage in soft/open closed interval
				 * 6. Check for invoices in soft/open closed interval
				 * 7. Check if the account contributes to group discount
				 */
				PRINT '-- Account does not exists check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account does not exists!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					not EXISTS (
						SELECT
							1
						FROM
							t_account acc
						WHERE
							acc.id_acc = tmp.ID )

				-- 1. Check for 'hard close' usage in any of these accounts
				PRINT '-- Usage in Hard closed interval check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account contains usage in hard interval!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							au.id_acc
						FROM
							t_acc_usage au INNER JOIN t_acc_usage_interval ui
						ON
							ui.id_usage_interval = au.id_usage_interval AND
							ui.tx_status in ('H')
						WHERE
							au.id_acc = tmp.ID )

				-- 2. Check for invoices in hard closed interval usage in any of these
				-- accounts
				PRINT '-- Invoices in Hard closed interval check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account contains invoices for hard closed interval!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							i.id_acc
						FROM
							t_invoice i INNER JOIN t_acc_usage_interval ui
						ON
							ui.id_usage_interval = i.id_interval AND
							ui.tx_status in ('H')
						WHERE
							i.id_acc = tmp.ID )

				-- 3. Check if this account has ever been a payer
				PRINT '-- Payer check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account is a payer!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							p.id_payer
						FROM
							t_payment_redir_history p
						WHERE
							p.id_payer = tmp.ID AND
							p.id_payee not in (select id from #AccountIDsTable))

				-- 4. Check if this account is receiver of per subscription RC
				PRINT '-- Receiver of per subscription Recurring Charge check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account is receiver of per subscription RC!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							gsrm.id_acc
						FROM
							t_gsub_recur_map gsrm
						WHERE
							gsrm.id_acc = tmp.ID )

				-- 5. Check for invoices in soft closed or open usage in any of these
				-- accounts
				PRINT '-- Invoice in Soft closed/Open interval check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account contains invoices for soft closed interval.  Please backout invoice adapter first!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							i.id_acc
						FROM
							t_invoice i INNER JOIN t_acc_usage_interval ui
						ON
							ui.id_usage_interval = i.id_interval AND
							ui.tx_status in ('C', 'O')
						WHERE
							i.id_acc = tmp.ID )

				-- 6. Check for 'soft close/open' usage in any of these accounts
				PRINT '-- Usage in Soft closed/Open interval check --'
				UPDATE
					tmp
				SET					status = 0, -- failure
					message = 'Account contains usage in soft closed or open interval.  Please backout first!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							au.id_acc
						FROM
							t_acc_usage au INNER JOIN t_acc_usage_interval ui
						ON
							ui.id_usage_interval = au.id_usage_interval AND
							ui.tx_status in ('C', 'O')
						WHERE
							au.id_acc = tmp.ID )

				-- 7. Check if this account contributes to group discount
				PRINT '-- Contribution to Discount Distribution check --'
				UPDATE
					tmp
				SET
					status = 0, -- failure
					message = 'Account is contributing to a discount!'
				FROM
					#AccountIDsTable tmp
				WHERE
					status <> 0 AND
					EXISTS (
						SELECT
							gs.id_discountAccount
						FROM
							t_group_sub gs
						WHERE
							gs.id_discountAccount = tmp.ID )

				IF EXISTS (
					SELECT
						*
					FROM
						#AccountIDsTable
					WHERE
						status = 0)
				BEGIN					PRINT 'Deletion of accounts cannot proceed. Fix the errors!'
					PRINT '-- Exiting --!'
					SELECT
						*
					FROM
						#AccountIDsTable

					RETURN
				END

				-- Start the deletes here
				PRINT '-- Beginning the transaction here --'
				BEGIN TRANSACTION

				-- Script to find ICB rates and delete from t_pt, t_rsched,
				-- t_pricelist tables
				PRINT '-- Finding ICB rate and deleting for PC tables --'
				create table #id_sub (id_sub int)
				INSERT into #id_sub select id_sub from t_sub where id_acc
				IN (SELECT ID FROM #AccountIDsTable)
				DECLARE @id_pt table (id_pt int,id_pricelist int)
				INSERT
					@id_pt
				SELECT
					id_paramtable,
					id_pricelist
				FROM
					t_pl_map
				WHERE
					id_sub IN (SELECT * FROM #id_sub)
				DECLARE c1 cursor forward_only for select id_pt,id_pricelist from @id_pt
				DECLARE @name varchar(200)
				DECLARE @pt_name varchar(200)
				DECLARE @pl_name varchar(200)
				DECLARE @str varchar(4000)
				OPEN c1
				FETCH c1 INTO @pt_name,@pl_name
				SELECT
					@name =
				REVERSE(substring(REVERSE(nm_name),1,charindex('/',REVERSE(nm_name))-1))
				FROM
					t_base_props
				WHERE
					id_prop = @pt_name
				SELECT
					@str = 'DELETE t_pt_' + @name + ' from t_pt_' + @name + ' INNER JOIN t_rsched rsc on t_pt_'
						+ @name + '.id_sched = rsc.id_sched
						INNER JOIN t_pl_map map ON
						map.id_paramtable = rsc.id_pt AND
						map.id_pi_template = rsc.id_pi_template AND
						map.id_pricelist = rsc.id_pricelist
						WHERE map.id_sub IN (SELECT id_sub FROM #id_sub)'
				EXECUTE (@str)
				SELECT @str = 'DELETE FROM t_rsched WHERE id_pricelist =' + @pl_name
				EXECUTE (@str)
				SELECT @str = 'DELETE FROM t_pl_map WHERE id_pricelist =' + @pl_name
				EXECUTE (@str)
				SELECT @str = 'DELETE FROM t_pricelist WHERE id_pricelist =' + @pl_name
				EXECUTE (@str)

				CLOSE c1
				DEALLOCATE c1

				-- t_billgroup_member
				PRINT '-- Deleting from t_billgroup_member --'
				DELETE FROM t_billgroup_member
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_member table'
					GOTO SetError
				END

				-- t_billgroup_member_history
				PRINT '-- Deleting from t_billgroup_member_history --'
				DELETE FROM t_billgroup_member_history
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_member_history table'
					GOTO SetError
				END

				-- t_billgroup_member_history
				PRINT '-- Deleting from t_billgroup_source_acc --'
				DELETE FROM t_billgroup_source_acc
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_source_acc table'
					GOTO SetError
				END

				-- t_billgroup_constraint
				PRINT '-- Deleting from t_billgroup_constraint  --'
				DELETE FROM t_billgroup_constraint
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_constraint table'
					GOTO SetError
				END

				-- t_billgroup_constraint_tmp
				PRINT '-- Deleting from t_billgroup_constraint_tmp --'
				DELETE FROM t_billgroup_constraint_tmp
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_billgroup_constraint_tmp table'
					GOTO SetError
				END

				-- t_av_* tables
				DECLARE @table_name nvarchar(1000)
				DECLARE c2 CURSOR FOR SELECT table_name FROM information_schema.tables
				WHERE table_name LIKE 't_av_%' AND table_type = 'BASE TABLE'
				-- Delete from t_av_* tables
				OPEN c2
				FETCH NEXT FROM c2 into @table_name
				WHILE (@@FETCH_STATUS = 0)
				BEGIN
					PRINT '-- Deleting from ' + @table_name + ' --'
					EXEC ('DELETE FROM ' + @table_name + ' WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)')
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from ' + @table_name + ' table'
  						CLOSE c2
   						DEALLOCATE c2
						GOTO SetError
					END
   					FETCH NEXT FROM c2 INTO @table_name
				END
  				CLOSE c2
   				DEALLOCATE c2

				-- t_account_state_history
				PRINT '-- Deleting from t_account_state_history --'
				DELETE FROM t_account_state_history
				WHERE id_acc IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account_state_history table'
					GOTO SetError
				END

				-- t_account_state
				PRINT '-- Deleting from t_account_state --'
				DELETE FROM t_account_state
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account_state table'
					GOTO SetError
				END

				-- t_acc_usage_interval
				PRINT '-- Deleting from t_acc_usage_interval --'
				DELETE FROM t_acc_usage_interval
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_usage_interval table'
					GOTO SetError
				END

				-- t_acc_usage_cycle
				PRINT '-- Deleting from t_acc_usage_cycle --'
				DELETE FROM t_acc_usage_cycle
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_usage_cycle table'
					GOTO SetError
				END

				-- t_acc_template_props
				PRINT '-- Deleting from t_acc_template_props --'
				DELETE FROM t_acc_template_props
				WHERE id_acc_template IN
				(SELECT id_acc_template
				FROM t_acc_template
				WHERE id_folder in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_template_props table'
					GOTO SetError
				END

				-- t_acc_template_subs
				PRINT '-- Deleting from t_acc_template_subs --'
				DELETE FROM t_acc_template_subs
				WHERE id_acc_template IN
				(SELECT id_acc_template
				FROM t_acc_template
				WHERE id_folder in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_template_subs table'
					GOTO SetError
				END

				-- t_acc_template
				PRINT '-- Deleting from t_acc_template --'
				DELETE FROM t_acc_template
				WHERE id_folder in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_acc_template table'
					GOTO SetError
				END

				-- t_user_credentials
				PRINT '-- Deleting from t_user_credentials --'
				DELETE FROM t_user_credentials
				WHERE nm_login IN
				(SELECT nm_login
				FROM t_account_mapper
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_user_credentials table'
					GOTO SetError
				END

				-- t_profile
				PRINT '-- Deleting from t_profile --'
				DELETE FROM t_profile
				WHERE id_profile IN
				(SELECT id_profile
				FROM t_site_user
				WHERE nm_login IN
				(SELECT nm_login
				FROM t_account_mapper
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_profile table'
					GOTO SetError
				END

				-- t_site_user
				PRINT '-- Deleting from t_site_user --'
				DELETE FROM t_site_user
				WHERE nm_login IN
				(SELECT nm_login
				FROM t_account_mapper
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_site_user table'
					GOTO SetError
				END

				-- t_payment_redirection
				PRINT '-- Deleting from t_payment_redirection --'
				DELETE FROM t_payment_redirection
				WHERE id_payee IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_payment_redirection table'
					GOTO SetError
				END

				-- t_payment_redir_history
				PRINT '-- Deleting from t_payment_redir_history --'
				DELETE FROM t_payment_redir_history
				WHERE id_payee IN (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_payment_redir_history table'
					GOTO SetError
				END

				-- t_sub
				PRINT '-- Deleting from t_sub --'
				DELETE FROM t_sub
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_sub table'
					GOTO SetError
				END

				-- t_sub_history
				PRINT '-- Deleting from t_sub_history --'
				DELETE FROM t_sub_history
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_sub_history table'
					GOTO SetError
				END

				-- t_group_sub
				PRINT '-- Deleting from t_group_sub --'
				DELETE FROM t_group_sub
				WHERE id_discountAccount in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_group_sub table'
					GOTO SetError
				END

				-- t_gsubmember
				PRINT '-- Deleting from t_gsubmember --'
				DELETE FROM t_gsubmember
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_gsubmember table'
					GOTO SetError
				END

				-- t_gsubmember_historical
				PRINT '-- Deleting from t_gsubmember_historical --'
				DELETE FROM t_gsubmember_historical
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_gsubmember_historical table'
					GOTO SetError
				END

				-- t_gsub_recur_map
				PRINT '-- Deleting from t_gsub_recur_map --'
				DELETE FROM t_gsub_recur_map
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
				  PRINT 'Cannot delete from t_gsub_recur_map table'
					GOTO SetError
				END

				-- t_pl_map
				PRINT '-- Deleting from t_pl_map --'
				DELETE FROM t_pl_map
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_pl_map table'
					GOTO SetError
				END

				-- t_path_capability
				PRINT '-- Deleting from t_path_capability --'
				DELETE FROM t_path_capability
				WHERE id_cap_instance IN (
				SELECT id_cap_instance FROM t_capability_instance ci
				WHERE ci.id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_path_capability table'
					GOTO SetError
				END

				-- t_enum_capability
				PRINT '-- Deleting from t_enum_capability --'
				DELETE FROM t_enum_capability
				WHERE id_cap_instance IN (
				SELECT id_cap_instance FROM t_capability_instance ci
				WHERE ci.id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_enum_capability table'
					GOTO SetError
				END

				-- t_decimal_capability
				PRINT '-- Deleting from t_decimal_capability --'
				DELETE FROM t_decimal_capability
				WHERE id_cap_instance IN (
				SELECT id_cap_instance FROM t_capability_instance ci
				WHERE ci.id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_decimal_capability table'
					GOTO SetError
				END

				-- t_capability_instance
				PRINT '-- Deleting from t_capability_instance --'
				DELETE FROM t_capability_instance
				WHERE id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_capability_instance table'
					GOTO SetError
				END

				-- t_policy_role
				PRINT '-- Deleting from t_policy_role --'
				DELETE FROM t_policy_role
				WHERE id_policy IN (
				SELECT id_policy FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_policy_role table'
					GOTO SetError
				END

				-- t_principal_policy
				PRINT '-- Deleting from t_principal_policy --'
				DELETE FROM t_principal_policy
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_principal_policy table'
					GOTO SetError
				END

				-- t_impersonate
				PRINT '-- Deleting from t_impersonate --'
				DELETE FROM t_impersonate
				WHERE (id_acc in (SELECT ID FROM #AccountIDsTable)
				or id_owner in (SELECT ID FROM #AccountIDsTable))
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_impersonate table'
					GOTO SetError
				END

				-- t_account_mapper
				PRINT '-- Deleting from t_account_mapper --'
				DELETE FROM t_account_mapper
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account_mapper table'
					GOTO SetError
				END

				DECLARE @hierarchyrule nvarchar(10)
				SELECT @hierarchyrule = value
				FROM t_db_values
				WHERE parameter = 'Hierarchy_RestrictedOperations'
				IF (@hierarchyrule = 'True')
				BEGIN
				  DELETE FROM t_group_sub
					WHERE id_corporate_account IN (SELECT ID FROM #AccountIDsTable)
					IF (@@Error <> 0)
					BEGIN
					  PRINT 'Cannot delete from t_group_sub table'
						GOTO SetError
					END
				END

				-- t_account_ancestor
				PRINT '-- Deleting from t_account_ancestor --'
				DELETE FROM t_account_ancestor
				WHERE id_descendent in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account_ancestor table'
					GOTO SetError
				END

				UPDATE
					t_account_ancestor
				SET
					b_Children = 'N'
				FROM
					t_account_ancestor aa1
				WHERE
					id_descendent IN (SELECT ID FROM #AccountIDsTable) and
					NOT EXISTS (SELECT 1 FROM t_account_ancestor aa2
											WHERE aa2.id_ancestor = aa1.id_descendent
											AND num_generations <> 0)

				-- t_account
				PRINT '-- Deleting from t_account --'
				DELETE FROM t_account
				WHERE id_acc in (SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_account table'
					GOTO SetError
				END

				PRINT '-- Deleting from t_dm_account_ancestor --'
				DELETE FROM t_dm_account_ancestor
				WHERE id_dm_descendent in
				(
				select id_dm_acc from t_dm_account where id_acc in
				(SELECT ID FROM #AccountIDsTable)
				)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_dm_account_ancestor table'
					GOTO SetError
				END

				PRINT '-- Deleting from t_dm_account --'
				DELETE FROM t_dm_account
				WHERE id_acc in
				(SELECT ID FROM #AccountIDsTable)
				IF (@@Error <> 0)
				BEGIN
					PRINT 'Cannot delete from t_dm_account table'
					GOTO SetError
				END

				-- IF (@linkedservername <> NULL)
				-- BEGIN
				  -- Do payment server stuff here
				-- END

				-- If we are here, then all accounts should have been deleted

				if (@linkedservername is not NULL and @PaymentServerdbname is not null)
				begin
					select @sql = 'delete from ' + @linkedservername + '.' + @PaymentServerdbname + '.dbo.t_ps_creditcard WHERE id_acc in
							(SELECT ID FROM #AccountIDsTable)'
					print (@sql)
					execute (@sql)
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from t_ps_creditcard table'
						GOTO SetError
					end
					select @sql = 'delete from ' + @linkedservername + '.' + @PaymentServerdbname + '.dbo.t_ps_ach WHERE id_acc in
							(SELECT ID FROM #AccountIDsTable)'
					execute (@sql)
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from t_ps_ach table'
						GOTO SetError
					END
				end
				if (@linkedservername is NULL and @PaymentServerdbname is not null)
				begin
					select @sql = 'delete from ' + @PaymentServerdbname + '.dbo.t_ps_creditcard WHERE id_acc in
							(SELECT ID FROM #AccountIDsTable)'
					execute (@sql)
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from t_ps_creditcard table'
						GOTO SetError
					end
					select @sql = 'delete from ' + @PaymentServerdbname + '.dbo.t_ps_ach WHERE id_acc in
							(SELECT ID FROM #AccountIDsTable)'
					execute (@sql)
					IF (@@Error <> 0)
					BEGIN
						PRINT 'Cannot delete from t_ps_ach table'
						GOTO SetError
					END
				end

				if (@linkedservername is not NULL and @PaymentServerdbname is null)
					BEGIN
						PRINT 'Please specify the database name of payment server'
						GOTO SetError
					END

				UPDATE
				  #AccountIDsTable
				SET
				  message = 'This account no longer exists!'

				SELECT
					*
				FROM
					#AccountIDsTable
				--WHERE
				--	status <> 0

				COMMIT TRANSACTION
				RETURN 0

				SetError:
					ROLLBACK TRANSACTION
					RETURN -1
			
			
GO
PRINT N'Altering [dbo].[AddAccToHierarchy]'
GO

ALTER  procedure
AddAccToHierarchy (@id_ancestor int,
@id_descendent int,
@dt_start  datetime,
@dt_end  datetime,
@p_acc_startdate datetime,
@ancestor_type varchar(40) OUTPUT,
@acc_type varchar(40) OUTPUT,
@status int OUTPUT)
as
begin
declare @realstartdate datetime
declare @realenddate datetime
declare @varMaxDateTime datetime
declare @ancestor int
declare @descendentIDAsString varchar(50)
declare @ancestorStartDate as datetime
declare @realaccstartdate as datetime
declare @ancestor_acc_type int
declare @descendent_acc_type int
select  @status = 0
-- begin business rules
-- check that the account is not already in the hierarchy
select @varMaxDateTime = dbo.MTMaxDate()
select @descendentIDAsString = CAST(@id_descendent as varchar(50)) 

  -- begin business rule checks.


 select @ancestor_type = atype.name, @ancestor_acc_type = atype.id_type from t_account acc
       inner join t_account_type atype 
       on atype.id_type = acc.id_type
       where acc.id_acc = @id_ancestor

      
  select @acc_type = atype.name, @descendent_acc_type = atype.id_type from t_account acc
       inner join t_account_type atype
       on atype.id_type = acc.id_type
       where acc.id_acc = @id_descendent
              

	SELECT @ancestor = id_acc 
	  from
	  t_account where id_acc = @id_ancestor
	if @ancestor is null begin
		  -- MT_PARENT_NOT_IN_HIERARCHY
		  select @status = -486604771
		  return
	end
	
	if @descendent_acc_type not in (
	  select id_descendent_type from t_acctype_descendenttype_map
	  where id_type = @ancestor_acc_type)
  begin
     select @status = -486604714  -- MT_ANCESTOR_OF_INCORRECT_TYPE
     return
  end 

	if @p_acc_startdate is NULL
	begin
		select @realaccstartdate = dt_crt from t_account where id_acc = @id_descendent
	end
	else
	begin
		select @realaccstartdate = @p_acc_startdate
	end

	select @ancestorStartDate = dt_crt
	from t_account where id_acc = @id_ancestor
	if  dbo.mtstartofday(@realaccstartdate) < dbo.mtstartofday(@ancestorStartDate)
	begin
		-- MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START
		select @status = -486604746
		return
	end 

  select  @status = count(*)  from t_account_ancestor with(updlock)
    where id_descendent = @id_descendent 
    and id_ancestor = @id_ancestor
    and num_generations = 1
    and (dbo.overlappingdaterange(vt_start,vt_end,@dt_start,@dt_end) = 1 )

  if (@status > 0) 
  begin
    -- MT_ACCOUNT_ALREADY_IN_HIEARCHY
    select @status = -486604785
    return
  end 

-- end business rule checks.

select @realstartdate = dbo.MTStartOfDay(@dt_start)  
if (@dt_end is NULL) 
begin
 select @realenddate = dbo.MTStartOfDay(dbo.mtmaxdate())  
 end
else
 begin
 select @realenddate = dbo.mtendofday(@dt_end)  
 end 
-- TODO: we need error handling code to detect when the ancestor does 
-- not exist at the time interval!!
-- populate t_account_ancestor (no bitemporal data)
insert into t_account_ancestor (id_ancestor,id_descendent,
num_generations,vt_start,vt_end,tx_path)
select id_ancestor,@id_descendent,num_generations + 1,dbo.MTMaxOfTwoDates(vt_start,@realstartdate),dbo.MTMinOfTwoDates(vt_end,@realenddate),
case when (id_descendent = 1 OR id_descendent = -1) then
tx_path + @descendentIDAsString
else
tx_path + '/' + @descendentIDAsString
end 
from t_account_ancestor
where
id_descendent = @id_ancestor AND id_ancestor <> id_descendent  AND
dbo.OverlappingDateRange(vt_start,vt_end,@realstartdate,@realenddate) = 1
UNION ALL
-- the new record to parent.  Note that the 
select @id_ancestor,@id_descendent,1,@realstartdate,@realenddate,
case when (id_descendent = 1 OR id_descendent = -1) then
tx_path + @descendentIDAsString
else
tx_path + '/' + @descendentIDAsString
end
from
t_account_ancestor where id_descendent = @id_ancestor AND num_generations = 0
AND dbo.OverlappingDateRange(vt_start,vt_end,@realstartdate,@realenddate) = 1
	-- self pointer
UNION ALL 
select @id_descendent,@id_descendent,0,@realstartdate,@realenddate,@descendentIDAsString
 -- update our parent entry to have children
--update t_account_ancestor set b_Children = 'Y' where
--id_descendent = @id_ancestor AND
--dbo.OverlappingDateRange(vt_start,vt_end,@realstartdate,@realenddate) = 1
if (@@error <> 0) 
 begin
 select @status = 0
 end
select @status = 1  
end
				
GO
PRINT N'Altering [dbo].[CreatePaymentRecord]'
GO

			 
ALTER PROCEDURE  CreatePaymentRecord (
  @Payer  int,
  @NPA int,
  @startdate  datetime,
  @enddate datetime,
  @payerbillable varchar(1),
  @systemdate datetime,
  @p_fromUpdate char(1),
  @p_enforce_same_corporation varchar(1),
  @p_account_currency nvarchar(5),
  @status int OUTPUT)
  as
  begin

  declare @realstartdate datetime
  declare @realenddate datetime
  declare @accCreateDate datetime
  declare @billableFlag varchar(1)
  declare @payer_state varchar(10)

  select @status = 0
  select @realstartdate = dbo.mtstartofday(@startdate)    
  if (@enddate is NULL)
    begin
    select @realenddate = dbo.mtstartofday(dbo.MTMaxDate()) 
    end
 else
   begin
	if @enddate <> dbo.mtstartofday(dbo.MTMaxDate())
		select @realenddate = DATEADD(d, 1,dbo.mtstartofday(@enddate))
	else
		select @realenddate = @enddate
    end

	select @AccCreateDate = dbo.mtstartofday(dt_crt) from t_account where id_acc = @NPA
	if @realstartdate < @AccCreateDate 
	begin
		-- MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE
		select @status = -486604753
		return
	end
	if @realstartdate = @realenddate begin
		-- MT_PAYMENT_START_AND_END_ARE_THE_SAME
		select @status = -486604735
		return
	end
	if @realstartdate > @realenddate begin
		-- MT_PAYMENT_START_AFTER_END
		select @status = -486604734
		return
	end
	 /* 
		NPA: Non Paying Account
	  Assumptions: The system has already checked if an existing payment
	  redirection record exists.  The user is asked whether the 
	  system should truncate the existing payment redirection record.
	  business rule checks:
	  MT_ACCOUNT_CAN_NOT_PAY_FOR_ITSELF (0xE2FF0007L, -486604793)
	  ACCOUNT_IS_NOT_BILLABLE (0xE2FF0005L,-486604795)
	  MT_PAYMENT_RELATIONSHIP_EXISTS (0xE2FF0006L, -486604794)
	  step 1: Account can not pay for itself
	if (@Payer = @NPA)
	begin
		select @status = -486604793
		return
		end  
	 */
	if (@Payer <> -1)
	begin
		select @billableFlag = case when @payerbillable is NULL then
			dbo.IsAccountBillable(@payer)	else @payerbillable end
		 -- step 2: The account is in a state such that new payment records can be created
		if (@billableFlag = '0') begin
			-- MT_ACCOUNT_IS_NOT_BILLABLE
		select @status = -486604795
			return
		end
	
	
	
		-- make sure that the paying account is active for the entire payment period
		select TOP 1 @payer_state = status from t_account_state
		where dbo.enclosedDateRange(vt_start,vt_end,@realstartdate,dateadd(s, -1, @realenddate)) = 1 AND
		id_acc = @payer
		if @payer_state is NULL OR @payer_state <> 'AC' begin
			-- MT_PAYER_IN_INVALID_STATE
			select @status = -486604736
			return
		end
	

		-- always check that payer and payee are on the same currency
		-- (if they are not the same, of course)
		-- if @p_account_currency parameter was passed as empty string, then 
		-- the call is coming either from MAM, and the currency is not available,
		-- or the call is coming from account update session, where currency is not being
	-- updated. In both cases it won't hurt to resolve it from t_av_internal and check
		-- that it matches payer currency.. ok, in Kona, an account that can never be a payer
		-- need not have a currency, handle this.
		if(@NPA <> @payer)
		begin
			if((LEN(@p_account_currency) = 0) OR (LEN(@p_account_currency) is null))
			begin
			SELECT @p_account_currency = c_currency from t_av_internal WHERE id_acc = @NPA
				if (@p_account_currency is null)
				begin
				  -- check if the account type has the b_canbepayer false, if it is then just assume that it has
				  -- the same currency as the prospective payer.
	  			  declare @NPAPayerRule varchar(1)
	  			  select @NPAPayerRule = b_CanBePayer from t_account_type atype
	  			  inner join t_account acc
	  			  on atype.id_type = acc.id_type
	  			  where acc.id_acc = @NPA
	  			  if (@NPAPayerRule = '0')
	  			    select @p_account_currency = c_currency from t_av_internal where id_acc = @payer
				end
			end
		
			declare @sameCurrency int
			select @sameCurrency = 
				(SELECT COUNT(payerav.id_acc)  from t_av_internal payerav
				where payerav.id_acc = @payer AND (payerav.c_currency) = (@p_account_currency)
				)
			if @sameCurrency = 0
			begin
				-- MT_PAYER_PAYEE_CURRENCY_MISMATCH
				select @status = -486604728
				return
			end
		end
		-- check that both the payer and Payee are in the same corporate account
		--only check this if business rule is enforced
		--only check this if the payee's current ancestor is not -1
		declare @payeeCurrentAncestor integer
		select @payeeCurrentAncestor = id_ancestor from t_account_ancestor
		where id_descendent = @NPA and  @realstartdate between vt_start AND vt_end
	  and num_generations = 1
	 
		if (@p_enforce_same_corporation = 1 AND @payeeCurrentAncestor <> -1 AND dbo.IsInSameCorporateAccount(@payer,@NPA,@realstartdate) <> 1)
		begin
			-- MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT
			select @status = -486604758
			return
		end
	end
	-- return without doing work in cases where nothing needs to be done
	select @status = count(*) 
	from t_payment_redirection where id_payer = @payer AND id_payee = @NPA
	AND (
		(dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND @p_fromupdate = 'N') 
		OR
		(vt_start <= @realstartdate AND vt_end = @realenddate AND @p_fromupdate = 'Y')
	)
	if @status > 0 begin
		-- account is already paying for the account during the interval.  Simply ignore
		-- the action
		select @status = 1
		return
	end

	exec CreatePaymentRecordBitemporal @payer,@NPA,@realstartdate,@realenddate,@systemdate, @status OUTPUT
  IF @status <> 1
    RETURN -- failure

  -- post-operation business rule checks (relies on rollback of work done up until this point)
  DECLARE @check1 INT, @check2 INT, @check3 INT
  SELECT 
  -- CR9906: checks to make sure the new payer's billing cycle matches all of the payee's 
  -- group subscriptions' BCR constraints
    @check1 = ISNULL(MIN(dbo.CheckGroupMembershipCycleConstraint(@systemdate, groups.id_group)), 1),
    -- EBCR cycle constraint checks
    @check2 = ISNULL(MIN(dbo.CheckGroupMembershipEBCRConstraint(@systemdate, groups.id_group)), 1)
  FROM 
  (
    -- gets all of the payee's group subscriptions
    SELECT DISTINCT gsm.id_group id_group
    FROM t_gsubmember gsm
    WHERE gsm.id_acc = @NPA  -- payee ID
  ) groups

  IF (@check1 <> 1)
  BEGIN
    SET @status = @check1
    RETURN
  END
  ELSE IF (@check2 <> 1)
  BEGIN
    SET @status = @check2
    RETURN
  END

  SELECT  
    @check3 = ISNULL(MIN(dbo.CheckGroupReceiverEBCRConstraint(@systemdate, groups.id_group)), 1)
  FROM 
  (
    -- gets all of the payee's receiverships
    SELECT DISTINCT gsrm.id_group id_group
    FROM t_gsub_recur_map gsrm
    WHERE gsrm.id_acc = @NPA  -- payee ID
  ) groups

  IF (@check3 <> 1)
    SET @status = @check3

  -- Part of bug fix for 13588  
  -- check that - if the payee has individual subscriptions to product offerings with BCR constraints, then the
  -- new payer's cycle type satisfies those constraints.
 
  DECLARE @payer_cycle_type int
  DECLARE @check4 int
  -- g. cieplik 1/29/2009 (CORE-660) default "@check4" to 1, if either no rows are returned or id_po is null, then @check4 is 1
  set  @check4 = 1

  set @payer_cycle_type = (select type.id_cycle_type 
    from t_acc_usage_cycle uc
    inner join t_usage_cycle ucc
    on uc.id_usage_cycle = ucc.id_usage_cycle
    inner join t_usage_cycle_type type
    on ucc.id_cycle_type = type.id_cycle_type
    where uc.id_acc = @payer)
  
  -- g. cieplik 1/29/2009 (CORE-660) poConstrainedCycleType returns zero when there is no "ConstrainedCycleType", added predicate to check value being returned from "poConstrainedCycleType
  select top 1 @check4 = ISNULL(id_po, 1) from t_sub sub where id_acc = @NPA
  and id_group is null
  and @realenddate >= sub.vt_start and @realstartdate <= sub.vt_end
  and dbo.POContainsBillingCycleRelative(id_po) = 1
  and @payer_cycle_type <> dbo.poConstrainedCycleType(id_po)
  and 0 <> dbo.poConstrainedCycleType(id_po)
  
  IF (@check4 <> 1)
    SET @status = -289472464

END

GO
PRINT N'Altering [dbo].[RemoveSubscription]'
GO

  
ALTER procedure RemoveSubscription(
	@p_id_sub int,
	@p_systemdate datetime)
	as
	begin
 	declare @groupID int
	declare @maxdate datetime
  declare @icbID int
	declare @status int
	select @groupID = id_group,@maxdate = dbo.mtmaxdate()
	from t_sub where id_sub = @p_id_sub AND @p_systemdate BETWEEN vt_Start and vt_End

  -- Look for an ICB pricelist and delete it if it exists
	select distinct @icbID = id_pricelist from t_pl_map where id_sub=@p_id_sub

  if (@groupID is not NULL)
		begin
		update t_gsubmember_historical set tt_end = @p_systemdate 
		where tt_end = @maxdate AND id_group = @groupID
		delete from t_gsubmember where id_group = @groupID
    delete from t_gsub_recur_map where id_group = @groupID
		-- note that we do not delete from t_group_sub
		end   
	delete from t_pl_map where id_sub = @p_id_sub
	delete from t_sub where id_sub = @p_id_sub
	update t_recur_value set tt_end = @p_systemdate 
	where id_sub = @p_id_sub and tt_end = @maxdate
	update t_sub_history set tt_end = @p_systemdate
	where tt_end = @maxdate AND id_sub = @p_id_sub

	if (@icbID is not NULL)
  begin
    exec sp_DeletePricelist @icbID, @status output
    if @status <> 0 return
  end

	end
		

GO
PRINT N'Altering [dbo].[AddNewAccount]'
GO

		
ALTER PROCEDURE AddNewAccount(
@p_id_acc_ext  varchar(16),
@p_acc_state  varchar(2),
@p_acc_status_ext  int,
@p_acc_vtstart  datetime,
@p_acc_vtend  datetime,
@p_nm_login  nvarchar(255),
@p_nm_space nvarchar(40),
@p_tx_password  nvarchar(1024),
@p_langcode  varchar(10),
@p_profile_timezone  int,
@p_ID_CYCLE_TYPE  int,
@p_DAY_OF_MONTH  int,
@p_DAY_OF_WEEK  int,
@p_FIRST_DAY_OF_MONTH  int,
@p_SECOND_DAY_OF_MONTH int,
@p_START_DAY int,
@p_START_MONTH int,
@p_START_YEAR int,
@p_billable varchar,
@p_id_payer int,
@p_payer_startdate datetime,
@p_payer_enddate datetime,
@p_payer_login nvarchar(255),
@p_payer_namespace nvarchar(40),
@p_id_ancestor int,
@p_hierarchy_start datetime,
@p_hierarchy_end datetime,
@p_ancestor_name nvarchar(255),
@p_ancestor_namespace nvarchar(40),
@p_acc_type varchar(40),
@p_apply_default_policy varchar,
@p_systemdate datetime,
@p_enforce_same_corporation varchar,
-- pass the currency through to CreatePaymentRecord
-- stored procedure only to validate it against the payer
-- We have to do it, because the t_av_internal record
--is not created yet
@p_account_currency nvarchar(5),
@p_profile_id int,
@p_login_app varchar(40),
@accountID int,
@status  int OUTPUT,
@p_hierarchy_path varchar(4000) output,
@p_currency nvarchar(10) OUTPUT,
@p_id_ancestor_out int OUTPUT,
@p_corporate_account_id int OUTPUT,
@p_ancestor_type_out varchar(40) OUTPUT
)
as
	declare @existing_account as int
	declare @intervalID as int
	declare @intervalstart as datetime
	declare @intervalend as datetime
	declare @usagecycleID as int
	declare @acc_startdate as datetime
	declare @acc_enddate as datetime
	declare @payer_startdate as datetime
	declare @payer_enddate as datetime
	declare @ancestor_startdate as datetime
	declare @ancestor_enddate as datetime	declare @payerID as int
	declare @ancestorID as int
	declare @siteID as int
	declare @folderName nvarchar(255)
	declare @varMaxDateTime as datetime
	declare @IsNotSubscriber int
	declare @payerbillable as varchar(1)
	declare @authancestor as int
	declare @id_type as int
        declare @dt_end datetime

  set @p_ancestor_type_out = 'Err'
	-- step : validate that the account does not already exist.  Note 
	-- that this check is performed by checking the t_account_mapper table.
	-- However, we don't check the account state so the new account could
	-- conflict with an account that is an archived state.  You would need
	-- to purge the archived account before the new account could be created.
	select @varMaxDateTime = dbo.MTMaxDate()
	select @existing_account = id_acc from t_account_mapper with(updlock) where nm_login=@p_nm_login and nm_space=@p_nm_space
	if (@existing_account is not null) begin
	-- ACCOUNTMAPPER_ERR_ALREADY_EXISTS
	select @status = -501284862
	return
	end 

	-- check account creation business rules
	IF (@p_nm_login not in ('rm', 'mps_folder'))
	BEGIN
	  exec CheckAccountCreationBusinessRules 
			 @p_nm_space, 
			 @p_acc_type, 
			 @p_id_ancestor, 
			 @status output
	  IF (@status <> 1)
		BEGIN
	  	RETURN
		END		
	END	

	-- step : populate the account start dates if the values were
	-- not passed into the sproc
	select 
	@acc_startdate = case when @p_acc_vtstart is NULL then dbo.mtstartofday(@p_systemdate) 
		else dbo.mtstartofday(@p_acc_vtstart) end,
	@acc_enddate = case when @p_acc_vtend is NULL then @varMaxDateTime 
		else dbo.mtendofday(@p_acc_vtend) end
	-- step : populate t_account

 	select @id_type = id_type from t_account_type where name = @p_acc_type
	if (@p_id_acc_ext is null) begin
		insert into t_account(id_acc,id_acc_ext,dt_crt,id_type)
		select @accountID,newid(),@acc_startdate,@id_type 
	end
	else begin
		insert into t_account(id_acc,id_Acc_ext,dt_crt,id_type)
		select @accountID,convert(varbinary(16),@p_id_acc_ext),@acc_startdate,@id_type 
	end 
	-- step : get the account ID
	-- step : initial account state
	insert into t_account_state values (@accountID,
	@p_acc_state /*,p_acc_status_ext*/,
	@acc_startdate,@acc_enddate)
	insert into t_account_state_history values (@accountID,
	@p_acc_state /*,p_acc_status_ext*/,
	@acc_startdate,@acc_enddate,@p_systemdate,@varMaxDateTime)
	-- step : login and namespace information
	insert into t_account_mapper values (@p_nm_login,lower(@p_nm_space),@accountID)
	-- step : user credentials
	insert into t_user_credentials (nm_login, nm_space, tx_password) values (@p_nm_login,lower(@p_nm_space),@p_tx_password)

	-- step : t_profile. This looks like it is only for timezone information
	insert into t_profile values (@p_profile_id,'timeZoneID',@p_profile_timezone,'System')
	-- step : site user information
	exec GetlocalizedSiteInfo @p_nm_space,@p_langcode,@siteID OUTPUT
	insert into t_site_user values (@p_nm_login,@siteID,@p_profile_id)


  	--
  	-- associates the account with the Usage Server
  	--

	-- determines the usage cycle ID from the passed in date properties
	if (@p_ID_CYCLE_TYPE IS NOT NULL)
	BEGIN
		SELECT @usagecycleID = id_usage_cycle 
		FROM t_usage_cycle cycle 
	 	 WHERE
		 cycle.id_cycle_type = @p_ID_CYCLE_TYPE AND
	   	(@p_DAY_OF_MONTH = cycle.day_of_month OR @p_DAY_OF_MONTH IS NULL) AND
	   	(@p_DAY_OF_WEEK = cycle.day_of_week OR @p_DAY_OF_WEEK IS NULL) AND
	   	(@p_FIRST_DAY_OF_MONTH = cycle.FIRST_DAY_OF_MONTH OR @p_FIRST_DAY_OF_MONTH IS NULL) AND
	   	(@p_SECOND_DAY_OF_MONTH = cycle.SECOND_DAY_OF_MONTH OR @p_SECOND_DAY_OF_MONTH IS NULL) AND
	   	(@p_START_DAY = cycle.START_DAY OR @p_START_DAY IS NULL) AND
	   	(@p_START_MONTH = cycle.START_MONTH OR @p_START_MONTH IS NULL) AND
	   	(@p_START_YEAR = cycle.START_YEAR OR @p_START_YEAR IS NULL)
	
	  	-- adds the account to usage cycle mapping
		INSERT INTO t_acc_usage_cycle VALUES (@accountID, @usagecycleID)
	
	  	-- creates only needed intervals and mappings for this account only.
	  	-- other accounts affected by any new intervals (same cycle) will
	 	-- be associated later in the day via a usm -create
                -- Compare this logic to that in the batch case by noting the mapping between
                -- variables and temp table columns:
                --
                -- tmp.id_account = @accountID
                -- tmp.id_usage_cycle = @usagecycleID
                -- tmp.acc_vtstart = @acc_startdate
                -- tmp.acc_vtend = @acc_enddate
                -- tmp.acc_state = @p_acc_state
                --
                -- Note also that some predicates don't depend on database tables
                -- and these become a surrounding IF statement

                -- Defines the date range that an interval must fall into to
                -- be considered 'active'.
                SELECT @dt_end = (@p_systemdate + n_adv_interval_creation) FROM t_usage_server

                IF 
                  -- Exclude archived accounts.
                  @p_acc_state <> 'AR' 
                  -- The account has already started or is about to start.
                  AND @acc_startdate < @dt_end 
                  -- The account has not yet ended.
                  AND @acc_enddate >= @p_systemdate
                BEGIN
                INSERT INTO t_usage_interval(id_interval,id_usage_cycle,dt_start,dt_end,tx_interval_status)
                SELECT 
                  ref.id_interval,
                  ref.id_cycle,
                  ref.dt_start,
                  ref.dt_end,
                  'O'  -- Open
                FROM 
                t_pc_interval ref                 
                WHERE
                /* Only add intervals that don't exist */
                NOT EXISTS (SELECT 1 FROM t_usage_interval ui WHERE ref.id_interval = ui.id_interval)
                AND 
                ref.id_cycle = @usagecycleID AND
                -- Reference interval must at least partially overlap the [minstart, maxend] period.
                (ref.dt_end >= @acc_startdate AND 
                 ref.dt_start <= CASE WHEN @acc_enddate < @dt_end THEN @acc_enddate ELSE @dt_end END)

                INSERT INTO t_acc_usage_interval(id_acc,id_usage_interval,tx_status,dt_effective)
                SELECT
                  @accountID,
                  ref.id_interval,
                  ref.tx_interval_status,
		  NULL
                FROM 
                t_usage_interval ref 
                WHERE
                ref.id_usage_cycle = @usagecycleID AND
                -- Reference interval must at least partially overlap the [minstart, maxend] period.
                (ref.dt_end >= @acc_startdate AND 
                ref.dt_start <= CASE WHEN @acc_enddate < @dt_end THEN @acc_enddate ELSE @dt_end END)
                /* Only add mappings for non-blocked intervals */
                AND ref.tx_interval_status <> 'B'
              END
	END

	-- Non-billable accounts must have a payment redirection record
	if ( @p_billable = 'N' AND 
	(@p_id_payer is NULL and
	(@p_id_payer is null AND @p_payer_login is NULL AND @p_payer_namespace is NULL))) begin
	-- MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER
		select @status = -486604768
		return
	end
	-- default the payer start date to the start of the account  
	select @payer_startdate = case when @p_payer_startdate is NULL then @acc_startdate else dbo.mtstartofday(@p_payer_startdate) end,
	 -- default the payer end date to the end of the account if NULL
	@payer_enddate = case when @p_payer_enddate is NULL then @acc_enddate else dbo.mtendofday(@p_payer_enddate) end,
	-- step : default the hierarchy start date to the account start date 
	@ancestor_startdate = case when @p_hierarchy_start is NULL then @acc_startdate else @p_hierarchy_start end,
	-- step : default the hierarchy end date to the account end date
	@ancestor_enddate = case when @p_hierarchy_end is NULL then @acc_enddate else dbo.mtendofday(@p_hierarchy_end) end,
	-- step : resolve the ancestor ID if necessary
	@ancestorID = case when @p_ancestor_name is not NULL and @p_ancestor_namespace is not NULL then
		dbo.LookupAccount(@p_ancestor_name,@p_ancestor_namespace)  else 
		-- if the ancestor ID iis NULL then default to the root
		case when @p_id_ancestor is NULL then 1 else @p_id_ancestor end
	end,
	-- step : resolve the payer account if necessary
	@payerID = case when 	@p_payer_login is not null and @p_payer_namespace is not null then
		 dbo.LookupAccount(@p_payer_login,@p_payer_namespace) else 
			case when @p_id_payer is NULL then @accountID else @p_id_payer 
			end
		  end
  -- Fix CORE-762: step: @payerID must be > 1 (to eliminate root and synthetic root) and must be present
	select id_acc from t_account where id_acc = @payerID 
	if (@@rowcount = 0)
	begin
		-- MT_CANNOT_RESOLVE_PAYING_ACCOUNT
		select @status = -486604792
		return
	end

	select id_acc from t_account where id_acc = @ancestorID
	if (@@rowcount= 0) 
		begin
			-- MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT
			select @status = -486604791
			return
		end 
	else
		begin
			SET @p_id_ancestor_out = @ancestorID
		end
	
	if ((@p_acc_type) = 'SYSTEMACCOUNT') begin  -- any one who is not a system account is a subscriber
		select @IsNotSubscriber = 1
	end 
	-- we trust AddAccToHIerarchy to set the status to 1 in case of success
	declare @acc_type_out varchar(40)
	exec AddAccToHierarchy @ancestorID,@accountID,@ancestor_startdate,
	@ancestor_enddate,@acc_startdate,@p_ancestor_type_out output, @acc_type_out output, @status output
	if (@status <> 1)begin 
		return
	end 

	-- Populate t_dm_account and t_dm_account_ancestor table
	declare @id_dm_acc int

      insert into t_dm_account select id_descendent, vt_start, vt_end from
      t_account_ancestor where id_ancestor=1 and id_descendent = @accountID

      set @id_dm_acc = @@identity
      
      insert into t_dm_account_ancestor select dm2.id_dm_acc, dm1.id_dm_acc, aa1.num_generations
      from t_account_ancestor aa1
      inner join t_dm_account dm1 with(readcommitted) on aa1.id_descendent=dm1.id_acc and aa1.vt_start <= dm1.vt_end and dm1.vt_start <= aa1.vt_end
      inner join t_dm_account dm2 with(readcommitted) on aa1.id_ancestor=dm2.id_acc and aa1.vt_start <= dm2.vt_end and dm2.vt_start <= aa1.vt_end
      where dm1.id_acc <> dm2.id_acc
      and dm1.vt_start >= dm2.vt_start
      and dm1.vt_end <= dm2.vt_end
      and aa1.id_descendent = @accountID
      and dm1.id_dm_acc = @id_dm_acc

	insert into t_dm_account_ancestor select id_dm_acc,id_dm_acc,0	from t_dm_account where id_acc = @accountID
	-- pass in the current account's billable flag when creating the payment 
	-- redirection record IF the account is paying for itself
	select @payerbillable = case when @payerID = @accountID then
		@p_billable else NULL end
	exec CreatePaymentRecord @payerID,@accountID,
	@payer_startdate,@payer_enddate,@payerbillable,@p_systemdate,'N', @p_enforce_same_corporation, @p_account_currency, @status OUTPUT
	if (@status <> 1) begin
		return
	end   
	-- if "Apply Default Policy" flag is set, then
	-- figure out "ancestor" id based on account type in case the account is not
	--a subscriber
	--BP: 10/5 Make sure that t_principal_policy record is always there, otherwise ApplyRoleMembership will break
	declare @polid int
	exec Sp_Insertpolicy 'id_acc', @accountID,'A', @polID output
	if
		(UPPER(@p_apply_default_policy) = 'Y' OR
		UPPER(@p_apply_default_policy) = 'T' OR
		UPPER(@p_apply_default_policy) = '1') begin
    SET @authancestor = @ancestorID
		if (@IsNotSubscriber > 0) begin
		 	select @folderName = 
			 CASE 
				WHEN UPPER(@p_login_app) = 'CSR' THEN 'csr_folder'
				WHEN UPPER(@p_login_app) = 'MOM' THEN 'mom_folder'
				WHEN UPPER(@p_login_app) = 'MCM' THEN 'mcm_folder'
				WHEN UPPER(@p_login_app) = 'MPS' THEN 'mps_folder'
				END
			SELECT @authancestor = NULL
      SELECT @authancestor = id_acc  FROM t_account_mapper WHERE nm_login = @folderName
			AND nm_space = 'auth'
			if (@authancestor is null) begin
	 			select @status = 1
	 		end
		end 
		--apply default security policy
		if (@authancestor > 1) begin
			exec dbo.CloneSecurityPolicy @authancestor, @accountID , 'D' , 'A'
		end
	End 
	select @p_hierarchy_path = tx_path  from t_account_ancestor
	where id_descendent = @accountID and (id_ancestor = 1 OR id_ancestor = -1)
	AND @ancestor_startdate between vt_start AND vt_end
	
	--resolve accounts' corporation
	--select ancestor whose ancestor is of a type that has b_iscorporate set to true.
	select @p_corporate_account_id = ancestor.id_ancestor from t_account_ancestor ancestor
	inner join t_account acc on acc.id_acc = ancestor.id_ancestor
	inner join t_account_type atype on acc.id_type = atype.id_type
	where
	ancestor.id_descendent = @accountID and
	atype.b_iscorporate = '1' 
	AND @acc_startdate  BETWEEN ancestor.vt_start and ancestor.vt_end
	
  if (@p_corporate_account_id is null)
   set @p_corporate_account_id = @accountID
   
	if (@ancestorID <> 1 and @ancestorID <> -1)
	begin
		select @p_currency = c_currency from t_av_internal where id_acc = @ancestorID
		--if cross corp business rule is enforced, verify that currencies match
		if(@p_enforce_same_corporation = '1' AND ((@p_currency) <> (@p_account_currency)) )
		begin
			-- MT_CURRENCY_MISMATCH
			select @status = -486604737
			return
		end
  end

	-- done
	select @status = 1
		
GO
PRINT N'Altering [dbo].[UpdateAccount]'
GO


ALTER PROCEDURE UpdateAccount (
  @p_loginname nvarchar(255),
	@p_namespace nvarchar(40),
	@p_id_acc int,
	@p_acc_state varchar(2),
	@p_acc_state_ext int,
	@p_acc_statestart datetime,
	@p_tx_password nvarchar(1024),
	@p_ID_CYCLE_TYPE int,
	@p_DAY_OF_MONTH  int,
	@p_DAY_OF_WEEK int,
	@p_FIRST_DAY_OF_MONTH int,
	@p_SECOND_DAY_OF_MONTH  int,
	@p_START_DAY int,
	@p_START_MONTH int,
	@p_START_YEAR int,
	@p_id_payer int,
	@p_payer_login nvarchar(255),
  @p_payer_namespace nvarchar(40),
	@p_payer_startdate datetime,
	@p_payer_enddate datetime,
	@p_id_ancestor int,
	@p_ancestor_name nvarchar(255),
	@p_ancestor_namespace nvarchar(40),
	@p_hierarchy_movedate datetime,
	@p_systemdate datetime,
	@p_billable varchar,
	@p_enforce_same_corporation varchar,
	--pass the currency through so that CreatePaymenrRecord
	--validates it, because the currency can be updated
	@p_account_currency nvarchar(5),
	@p_status int output,
	@p_cyclechanged int output,
	@p_newcycle int output,
	@p_accountID int output,
	@p_hierarchy_path varchar(4000) output,
	--if account is being moved, select old ancestor id
	@p_old_id_ancestor_out int output,
	--if account is being moved, select new ancestor id
	@p_id_ancestor_out int output,
	@p_corporate_account_id int OUTPUT,
	@p_ancestor_type varchar(40) OUTPUT,
	@p_acc_type varchar(40) OUTPUT
	)
as
begin
	declare @accountID int
	declare @oldcycleID int
	declare @usagecycleID int
	declare @intervalenddate datetime
	declare @intervalID int
	declare @pc_start datetime
	declare @pc_end datetime
	declare @oldpayerstart datetime
	declare @oldpayerend datetime
	declare @oldpayer int
	declare @payerenddate datetime
	declare @payerID int
	declare @AncestorID int
	
	declare @payerbillable varchar(1)
	select @accountID = -1
	select @oldcycleID = 0
	select @p_status = 0
	
	-- initialize the ancestor type (hack !!)
	set @p_ancestor_type = ''
	
	set @p_old_id_ancestor_out = @p_id_ancestor  -- we assume no move.
	-- step : resolve the account if necessary
	if (@p_id_acc is NULL) begin
		if (@p_loginname is not NULL and @p_namespace is not NULL) begin
		select @accountID = dbo.LookupAccount(@p_loginname,@p_namespace) 
			if (@accountID < 0) begin
				-- MTACCOUNT_RESOLUTION_FAILED
					select @p_status = -509673460
      end
		end
		else 
			begin
  	-- MTACCOUNT_RESOLUTION_FAILED
      select @p_status = -509673460
		end 
	end
	else
	begin
		select @accountID = @p_id_acc
	end 
	if (@p_status < 0) begin
		return
	end
 -- step : update the account password if necessary.  catch error
 -- if the account does not exist or the login name is not valid.  The system
 -- should check that both the login name, namespace, and password are 
 -- required to change the password.
	if (@p_loginname is not NULL and @p_namespace is not NULL and 
			@p_tx_password is not NULL)
			begin
			 update t_user_credentials set tx_password = @p_tx_password
				where nm_login = @p_loginname and nm_space = @p_namespace
			 if (@@rowcount = 0) 
	       begin
				 -- MTACCOUNT_FAILED_PASSWORD_UPDATE
				 select @p_status =  -509673461
         end
      end
			-- step : figure out if we need to update the account's billing cycle.  this
			-- may fail because the usage cycle information may not be present.
	begin
		select @usagecycleID = id_usage_cycle 
		from t_usage_cycle cycle where
	  cycle.id_cycle_type = @p_ID_CYCLE_TYPE 
		AND (@p_DAY_OF_MONTH = cycle.day_of_month or @p_DAY_OF_MONTH is NULL)
		AND (@p_DAY_OF_WEEK = cycle.day_of_week or @p_DAY_OF_WEEK is NULL)
		AND (@p_FIRST_DAY_OF_MONTH= cycle.FIRST_DAY_OF_MONTH  or @p_FIRST_DAY_OF_MONTH is NULL)
		AND (@p_SECOND_DAY_OF_MONTH = cycle.SECOND_DAY_OF_MONTH or @p_SECOND_DAY_OF_MONTH is NULL)
		AND (@p_START_DAY= cycle.START_DAY or @p_START_DAY is NULL)
		AND (@p_START_MONTH= cycle.START_MONTH or @p_START_MONTH is NULL)
		AND (@p_START_YEAR = cycle.START_YEAR or @p_START_YEAR is NULL)
    if (@usagecycleid is null)
		 begin
			SELECT @usagecycleID = -1
		 end
   end
	 select @oldcycleID = id_usage_cycle from
	 t_acc_usage_cycle where id_acc = @accountID
	 if (@oldcycleID <> @usagecycleID AND @usagecycleID <> -1)
	  begin

      -- checks to see if this account is affiliated with an EBCR charge
      SET @p_status = dbo.IsBillingCycleUpdateProhibitedByGroupEBCR(@p_systemdate, @p_id_acc)
      IF @p_status <> 1
        RETURN

      -- updates the account's billing cycle mapping
      UPDATE t_acc_usage_cycle SET id_usage_cycle = @usagecycleID
      WHERE id_acc = @accountID

      -- post-operation business rule check (relies on rollback of work done up until this point)
      -- CR9906: checks to make sure the account's new billing cycle matches all of it's and/or payee's 
      -- group subscription BCR constraints
      SELECT @p_status = ISNULL(MIN(dbo.CheckGroupMembershipCycleConstraint(@p_systemdate, groups.id_group)), 1)
      FROM 
      (
        -- gets all of the payer's payee's and/or the payee's group subscriptions
        SELECT DISTINCT gsm.id_group id_group
        FROM t_gsubmember gsm
        INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc
        WHERE 
          pay.id_payer = @accountID OR
          -- TODO: is payee criteria necessary?  
          pay.id_payee = @accountID
      ) groups
      IF @p_status <> 1
        RETURN
    
			-- deletes any mappings to intervals in the future from the old cycle
			DELETE FROM t_acc_usage_interval 
			WHERE 
        t_acc_usage_interval.id_acc = @accountID AND
        id_usage_interval IN 
        ( 
          SELECT id_interval 
          FROM t_usage_interval ui
          INNER JOIN t_acc_usage_interval aui ON 
            t_acc_usage_interval.id_acc = @accountID AND
            aui.id_usage_interval = ui.id_interval
          WHERE dt_start > @p_systemdate
			  )

      -- only one pending update is allowed at a time
			-- deletes any previous update mappings which have not yet
      -- transitioned (dt_effective is still in the future)
			DELETE FROM t_acc_usage_interval 
      WHERE 
        dt_effective IS NOT NULL AND
        id_acc = @accountID AND
        dt_effective >= @p_systemdate

      -- gets the current interval's end date
			SELECT @intervalenddate = ui.dt_end 
      FROM t_acc_usage_interval aui
			INNER JOIN t_usage_interval ui ON 
        ui.id_interval = aui.id_usage_interval AND
        @p_systemdate BETWEEN ui.dt_start AND ui.dt_end
		  WHERE aui.id_acc = @AccountID

      -- future dated accounts may not yet be associated with an interval (CR11047)
      IF @intervalenddate IS NOT NULL
      BEGIN
        -- figures out the new interval ID based on the end date of the current interval  
			  SELECT 
          @intervalID = id_interval,
         @pc_start = dt_start,
          @pc_end = dt_end 
			  FROM t_pc_interval
        WHERE
          id_cycle = @usagecycleID AND
			    dbo.addsecond(@intervalenddate) BETWEEN dt_start AND dt_end

        -- inserts the new usage interval if it doesn't already exist
        -- (needed for foreign key relationship in t_acc_usage_interval)
			  INSERT INTO t_usage_interval
        SELECT 
          @intervalID,
          @usagecycleID,
          @pc_start,
          @pc_end,
          'O'
			  WHERE @intervalID NOT IN (SELECT id_interval FROM t_usage_interval)

			  -- creates the special t_acc_usage_interval mapping to the interval of
        -- new cycle. dt_effective is set to the end of the old interval.
			  INSERT INTO t_acc_usage_interval 
			  SELECT @accountID, 
			         @intervalID, 
			         ISNULL(tx_interval_status, 'O'),
			         @intervalenddate
			  FROM t_usage_interval 
			  WHERE id_interval = @intervalID AND 
			        tx_interval_status != 'B'
      END

			-- indicate that the cycle changed
			select @p_newcycle = @UsageCycleID
			select @p_cyclechanged = 1

    END
    else
  	-- indicate to the caller that the cycle did not change
    begin
		select @p_newcycle = @UsageCycleID
    	select @p_cyclechanged = 0
    end

    -- step : update the payment redirection information.  Only update
    -- the payment information if the payer and payer_startdate is specified
    if ((@p_id_payer is NOT NULL OR (@p_payer_login is not NULL AND 
	@p_payer_namespace is not NULL)) AND @p_payer_startdate is NOT NULL) 
    begin
	-- resolve the paying account id if necessary
	if (@p_payer_login is not null and @p_payer_namespace is not null)
	begin
		select @payerId = dbo.LookupAccount(@p_payer_login,@p_payer_namespace) 
		if (@payerID = -1)
	 	begin 
			-- MT_CANNOT_RESOLVE_PAYING_ACCOUNT
	 		select @p_status = -486604792
	 		return
	 	end 
	end
	else
	begin
    -- Fix CORE-762: account must be present
    select id_acc from t_account where id_acc = @p_id_payer 
	  if (@@rowcount = 0)
	  begin
		  -- MT_CANNOT_RESOLVE_PAYING_ACCOUNT
		  select @p_status = -486604792
		  return
	  end
		select @payerID = @p_id_payer
	end 
		-- default the payer end date to the end of the account
	if (@p_payer_enddate is NULL)
	begin
		select @payerenddate = dbo.mtmaxdate()
	end 
	else
	begin 
		select @payerenddate = @p_payer_enddate
    	end 
	-- find the old payment information
	select @oldpayerstart = vt_start,@oldpayerend = vt_end ,@oldpayer = id_payer
	from t_payment_redirection
	where id_payee = @AccountID and
	dbo.overlappingdaterange(vt_start,vt_end,@p_payer_startdate,dbo.mtmaxdate())=1
	-- if the new record is in range of the old record and the payer is the same as the older payer,
	-- update the record
	if (@payerID = @oldpayer) 
        begin
		exec UpdatePaymentRecord @payerID,@accountID,@oldpayerstart,@oldpayerend,
		 @p_payer_startdate,@payerenddate,@p_systemdate,@p_enforce_same_corporation, @p_account_currency, @p_status output
		if (@p_status <> 1)
		 begin
			return
		 end 

  	end
  	else
	begin
	 	select @payerbillable = case when @payerID = @accountID then @p_billable else NULL end
	 	exec CreatePaymentRecord @payerID,@accountID,@p_payer_startdate,@payerenddate,@payerbillable,
		@p_systemdate,'N', @p_enforce_same_corporation, @p_account_currency, @p_status output
	 	if (@p_status <> 1)
	  	begin
			return
		end
	end
    end
    -- check if the account has any payees before setting the account as Non-billable.  It is important
    -- that this check take place after creating any payment redirection records	
    if dbo.IsAccountBillable(@AccountID) = '1' AND @p_billable = 'N' 
    begin
	if dbo.DoesAccountHavePayees(@AccountID,@p_systemdate) = 'Y'
        begin
		-- MT_ACCOUNT_NON_BILLABLE_AND_HAS_NON_PAYING_SUBSCRIBERS
		select @p_status = -486604767
			return
	end
    end

    --payer update done.
    
    
    --ancestor update begun
  if (((@p_ancestor_name is not null AND @p_ancestor_namespace is not NULL)
	 or @p_id_ancestor is not null) AND @p_hierarchy_movedate is not null)
    begin	 
	    if (@p_ancestor_name is not NULL and @p_ancestor_namespace is not NULL)
	    begin
		    select @ancestorID = dbo.LookupAccount(@p_ancestor_name,@p_ancestor_namespace) 

		    SET @p_id_ancestor_out = @ancestorID
		    if (@ancestorID = -1)
		    begin
			    -- MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT
			    select @p_status = -486604791
			    return
		    end 
	    end
  	  else
	    begin
		    select @ancestorID = @p_id_ancestor
	    end
	 
	    exec MoveAccount @ancestorID,@AccountID, @p_hierarchy_movedate, @p_enforce_same_corporation, @p_status output, @p_old_id_ancestor_out output, @p_ancestor_type output, @p_acc_type output

	    if (@p_status <> 1)
 	    begin
		    return
 	    end 

  end
  --ancestor update done

if (@p_old_id_ancestor_out is null)
begin
	set @p_old_id_ancestor_out = -1
end

if (@p_id_ancestor_out is null)
begin
	set @p_id_ancestor_out = -1
end
  
	-- step : resolve the hierarchy path based on the current time
 		begin
			select @p_hierarchy_path = tx_path  from t_account_ancestor
			where id_ancestor =1  and id_descendent = @AccountID and
				@p_systemdate between vt_start and vt_end

  		if (@p_hierarchy_path is null)
		 begin
			select @p_hierarchy_path = '/'  
 	 	 end

 		end

	--resolve accounts' corporation
	select @p_corporate_account_id = ancestor.id_ancestor from t_account_ancestor ancestor
	inner join t_account acc on ancestor.id_ancestor = acc.id_acc
	inner join t_account_type atype on atype.id_type = acc.id_type
	where
	  ancestor.id_descendent = @AccountID
		AND atype.b_iscorporate = '1'
		AND @p_systemdate  BETWEEN ancestor.vt_start and ancestor.vt_end

  if (@p_corporate_account_id is null)
    set @p_corporate_account_id = @AccountID
    
 -- done
 select @p_accountID = @AccountID
 select @p_status = 1
 end
	
			 
GO
PRINT N'Creating [dbo].[FILTERSORTQUERY_v2]'
GO

        
      create PROCEDURE FILTERSORTQUERY_v2
      (
		  @stagingDBName nvarchar(100),
          @tableName nvarchar(50),
          @InnerQuery nvarchar(max),
          @OrderByText nvarchar(500),
          @StartRow int,
          @NumRows int
      )
      AS
		  declare @Sql nvarchar(max)
          /* Create a temp table with all the selected records after the filter */
			set @Sql = 	N'select *, IDENTITY(int, 1, 1) as RowNumber into ' + @stagingDBName + '..' +  @tableName + N' from (' + @InnerQuery + N') innerQuery ' + @OrderByText;
			print(@Sql);
          Execute (@Sql);

          /* Get the total number of records after the filter */
		  set @Sql = N'select count(*) as TotalRows from ' + @stagingDBName + '..' + @tableName;
		  print(@Sql);
          execute (@Sql);

          /* If the results are to be paged, apply the page filter */
          if @NumRows > 0
		  begin
			  set @Sql = N'select * from ' + @stagingDBName + '..' + @tableName + N' where RowNumber between ' + cast(@StartRow as nvarchar(10)) + N' and ' + cast((@StartRow + @NumRows - 1) as nvarchar(10));
			  print(@Sql);
              execute(@Sql);
		  end
          else
		  begin
              execute('select * from ' + @stagingDBName + '..' + @tableName);
          end

          /* Drop the temp table to clean up */
		  Execute('drop table ' + @stagingDBName + '..' + @tableName);
      
      
GO

PRINT N'Altering [dbo].[sp_InsertPolicy]'
GO
ALTER procedure sp_InsertPolicy
						(@aPrincipalColumn VARCHAR(255),
						 @aPrincipalID int,
						 @aPolicyType VARCHAR(2),
             @ap_id_prop int OUTPUT)
		        as
		        
            declare @args NVARCHAR(255)
		        declare @str nvarchar(2000)
						declare @selectstr nvarchar(2000)
            begin
						 select @selectstr = N'SELECT @ap_id_prop = id_policy  FROM t_principal_policy with(updlock) WHERE ' + 
																CAST(@aPrincipalColumn AS nvarchar(255))
																+  N' = ' + CAST(@aPrincipalID AS nvarchar(38)) + N' AND ' + N'policy_type=''' 
																+ CAST(@aPolicyType AS nvarchar(2)) + ''''
						 select @str = N'INSERT INTO t_principal_policy (' + CAST(@aPrincipalColumn AS nvarchar(255)) + N',
						               policy_type)' + N' VALUES ( ' + CAST(@aPrincipalID AS nvarchar(38)) + N', ''' + 
						               CAST(@aPolicyType AS nvarchar(2))	+ N''')' 
            select @args = '@ap_id_prop INT OUTPUT'
            exec sp_executesql @selectstr, @args, @ap_id_prop OUTPUT
             if (@ap_id_prop is null)
	            begin
              exec sp_executesql @str
  	          select @ap_id_prop = @@identity
              end
            end
GO

PRINT N'Altering [dbo].[UpsertDescription]'
GO
ALTER procedure UpsertDescription
			@id_lang_code int,
			@a_nm_desc NVARCHAR(255),
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

PRINT N'Altering [dbo].[Analyze]'
GO

  ALTER PROCEDURE Analyze (@table_name nvarchar(30))
    as
    begin
	  declare @rows_changed int
	  declare @query nvarchar(4000)
	  declare @svctablename nvarchar(255)
	  declare @id_svc nvarchar(10)
    declare @reanalyze_index int
     
	  -- mark the successful rows as analyzed.
		if exists (select 1 from t_usage_server where b_partitioning_enabled = 'N')
		begin
      
     -- clean up any rows in the t_rerun_table that may have been alterd
	   -- ReAnalyze Case. This will al
		  SELECT @reanalyze_index =  CHARINDEX(UPPER('t_rerun_session_'), UPPER(@table_name))

	    if (@reanalyze_index != 0)
	      begin
      		  set @query = N'delete from ' + @table_name + 
			  ' where id_source_sess not in  ((select id_source_sess from ' + @table_name + ' rr inner join t_acc_usage au on rr.id_source_sess = au.tx_UID)
			    union (select id_source_sess from ' + @table_name + ' rr inner join t_failed_transaction tft on rr.id_source_sess = tft.tx_FailureID))'

			  EXEC sp_executesql @query
	  	end
      
				set @query = N'update ' + @table_name +
					N' set tx_state = ''A''
					from ' + @table_name + N' rr
					inner join t_acc_usage acc
					on rr.id_sess = acc.id_sess
					and acc.id_usage_interval = rr.id_interval
					where tx_state = ''I'''
		end
		else
		begin
				set @query = N'update ' + @table_name +
					N' set tx_state = ''A''
					from ' + @table_name + N' rr
					inner join t_uk_acc_usage_tx_uid acc
					on rr.id_source_sess = acc.tx_uid
					where tx_state = ''I'''
		end
	  EXEC sp_executesql @query
	  
	  -- set the id_parent_source_sess correctly for the children already 
	  -- identified by now (successful only)
	 
	  set @query = N'update ' + @table_name +
		  N' set id_parent_source_sess = acc.tx_uid
		  from ' + @table_name + N' rr
		  inner join t_acc_usage acc
		  on rr.id_parent_sess = acc.id_sess
		  and acc.id_usage_interval = rr.id_interval
		  where acc.id_parent_sess is null
		  and rr.id_parent_source_sess is null
		  and rr.tx_state = ''A'''
    EXEC sp_executesql @query
    
	  -- just so the loop will run the first time
	  set @rows_changed = 1

		-- find parents for successful sessions
		set @query = N'
		insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
		  select distinct 
			auparents.tx_UID,	-- id_source_sess
			auparents.tx_batch,	-- tx_batch
			auparents.id_sess,	-- id_sess
			auparents.id_parent_sess,	-- id_parent
			null,				-- TODO: root
			auparents.id_usage_interval,	-- id_interval
			auparents.id_view,		-- id_view
			case aui.tx_status when ''H'' then ''C'' else ''A'' end, -- c_state
			auparents.id_svc,		-- id_svc
			NULL, -- id_parent_source_sess
			auparents.id_acc,
			auparents.amount,
			auparents.am_currency
		  from t_acc_usage auchild
		  inner join ' + @table_name + N' rr on auchild.id_sess = rr.id_sess
  		  and auchild.id_usage_interval =rr.id_interval
		  inner join t_acc_usage auparents on auparents.id_sess = auchild.id_parent_sess
		  and auparents.id_usage_interval =auchild.id_usage_interval
		  inner join t_acc_usage_interval aui on auparents.id_usage_interval = aui.id_usage_interval
        and auparents.id_acc = aui.id_acc
		  where not exists (select * from ' + @table_name + N' rr1 where rr1.id_sess = auparents.id_sess and auparents.id_usage_interval =rr1.id_interval)'
		EXEC sp_executesql @query

		-- find children for successful sessions
		set @query = N'insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, 
				root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
		  select
			au.tx_UID,	-- id_source_sess
			au.tx_batch,	-- tx_batch
			au.id_sess,	-- id_sess
			au.id_parent_sess,	-- id_parent
			null,			-- TODO: root
			au.id_usage_interval,	-- id_interval
			au.id_view,		-- id_view
			case aui.tx_status when ''H'' then ''C'' else ''A'' end,			-- tx_state
			au.id_svc,	-- id_svc
			rr.id_source_sess, -- id_parent_source_sess
			au.id_acc,
			au.amount,
			au.am_currency
			from t_acc_usage au
			inner join ' + @table_name + N' rr on au.id_parent_sess = rr.id_sess
			and au.id_usage_interval = rr.id_interval
			inner join t_acc_usage_interval aui on au.id_usage_interval = aui.id_usage_interval
         and au.id_acc = aui.id_acc
			where not exists (select 1 from ' + @table_name + N' rr1 where rr1.id_sess = au.id_sess
			and rr1.id_interval = au.id_usage_interval)'
		EXEC sp_executesql @query

	 set @rows_changed = 1
	 -- complete the compound for failure cases.  In t_failed_transaction, you will have only the failed
	 -- portion of the failed transaction.
	 while (@rows_changed > 0)
	 begin
		set @rows_changed = 0
		-- find children for failed parent sessions
		-- find tables where children may live.
	  create table #tmpcursor1 (nm_table_name nvarchar(255), id_enum_data int)
	  set @query = N'insert into #tmpcursor1 (nm_table_name, id_enum_data)
			select distinct slog.nm_table_name, ed.id_enum_data
			from ' + @table_name + N'  rr
			inner join t_failed_transaction ft WITH (READCOMMITTED)
			on (rr.id_source_sess = ft.tx_failureCompoundID)
			inner join t_session_set ss WITH (READCOMMITTED)
			on ss.id_ss = ft.id_sch_ss
			inner join t_session_set childss WITH (READCOMMITTED)
			on ss.id_message = childss.id_message
			inner join t_enum_data ed
			on ed.id_enum_data = childss.id_svc
			inner join t_service_def_log slog
			on ed.nm_enum_data = slog.nm_service_def
			where id_parent_source_sess is null and tx_state = ''E''
			and childss.b_root = ''0'''
	  EXEC sp_executesql @query
		DECLARE tablename_cursor CURSOR FOR select nm_table_name, id_enum_data from #tmpcursor1
		OPEN tablename_cursor
		FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @svctablename
			set @query = 'insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
			select 
			conn.id_source_sess,	-- id_source_sess
			conn.c__CollectionID,	-- tx_batch
			NULL,	-- id_sess
			NULL,	-- id_parent_sess
			NULL,			-- TODO: root
			NULL,	-- id_interval
			NULL,		-- id_view
			''E'',			-- tx_state
			'+ @id_svc + N' , 	-- id_svc
			conn.id_parent_source_sess,
			null, -- id_payer
			null, -- amount
			null -- currency
			from ' + @table_name + N' rr
			inner join ' + @svctablename + N' conn WITH (READCOMMITTED)
			on rr.id_source_sess = conn.id_parent_source_sess
			where rr.id_parent_source_sess is null and tx_state = ''E''
			and not exists (select * from ' + @table_name + N' where ' +  @table_name + '.id_source_sess = conn.id_source_sess)'
			EXEC sp_executesql @query
			set @rows_changed = @rows_changed + @@ROWCOUNT
			FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		END
		CLOSE tablename_cursor
		DEALLOCATE tablename_cursor
    drop table #tmpcursor1
    		-- find parents for failed children sessions
		-- this query gives us all the svc tables in which the parents may live
	  create table #tmpcursor2 (nm_table_name nvarchar(255), id_enum_data int)
	  set @query =  N'insert into #tmpcursor2(nm_table_name, id_enum_data)
			select distinct slog.nm_table_name, cast(ed.id_enum_data as nvarchar(10))
			from ' + @table_name + N' rr
			inner join t_failed_transaction ft WITH (READCOMMITTED)
			on rr.id_source_sess = ft.tx_failureID
			inner join t_session_set ss WITH (READCOMMITTED)
			on ss.id_ss = ft.id_sch_ss
			inner join t_session_set parentss WITH (READCOMMITTED)
			on ss.id_message = parentss.id_message
			inner join t_enum_data ed
			on ed.id_enum_data = parentss.id_svc
			inner join t_service_def_log slog
			on ed.nm_enum_data = slog.nm_service_def
			where id_parent_source_sess is not null
			and tx_state = ''E''
			and ss.id_svc <> parentss.id_svc
			and parentss.b_root = ''1'''
	  EXEC sp_executesql @query
 		DECLARE tablename_cursor CURSOR FOR select nm_table_name, id_enum_data from #tmpcursor2
		OPEN tablename_cursor
		FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @svctablename
			set @query = 'insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
			select 
			call.id_source_sess,	-- id_source_sess
			call.c__CollectionID,	-- tx_batch
			NULL,	-- id_sess
			NULL,	-- id_parent_sess
			NULL,			-- TODO: root
			NULL,	-- id_interval
			NULL,		-- id_view
			''E'',			-- tx_state 
			'+ @id_svc + N' , 	-- id_svc
			call.id_parent_source_sess,
			null, -- id_payer
		  null, -- amount
		  null  -- currency
			from ' + @table_name + N' rr
			inner join ' + @svctablename + N' call WITH (READCOMMITTED)
			on rr.id_parent_source_sess = call.id_source_sess
			where rr.id_parent_source_sess is not null and tx_state = ''E''
			and not exists (select * from ' + @table_name + N' where ' +  @table_name + '.id_source_sess = call.id_source_sess)'
			EXEC sp_executesql @query
			set @rows_changed = @rows_changed + @@ROWCOUNT
			FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		END
		CLOSE tablename_cursor
		DEALLOCATE tablename_cursor
    DROP TABLE #tmpcursor2
	 end
	-- handle suspended and pending transactions.  We know we will have identified
	-- all suspended and pending parents.  Only children need to be looked at.
	-- following query tells us which tables to look for the children
	-- changing the cursor query.. for whatever reason,it takes too long, even when there are 
	-- no suspended transactions (CR: 13059)
	create table #tmpcursor3 (nm_table_name nvarchar(255), id_enum_data int)
	set @query =  N'insert into #tmpcursor3(nm_table_name, id_enum_data)
			select distinct slog.nm_table_name , cast(ss2.id_svc as nvarchar(10))
			from t_session_set ss2 WITH (READCOMMITTED)
			inner join t_enum_data ed
			on ss2.id_svc = ed.id_enum_data
			inner join t_service_def_log slog
			on ed.nm_enum_data = slog.nm_service_def
			where id_message in (
			select ss.id_message from '+ @table_name + N' rr
			inner join t_session sess WITH (READCOMMITTED)
			on sess.id_source_sess = rr.id_source_sess
			inner join t_session_set ss WITH (READCOMMITTED)
			on sess.id_ss = ss.id_ss
			inner join t_message msg WITH (READCOMMITTED)
			on msg.id_message = ss.id_message
			where rr.tx_state = ''NC'')
			and ss2.b_root = ''0'''
		EXEC sp_executesql @query
		DECLARE tablename_cursor CURSOR FOR select nm_table_name, id_enum_data from #tmpcursor3
		OPEN tablename_cursor
		FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @query = N'insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
				select svc.id_source_sess, null, 
				null, null, null, null, null, ''NA'', '
				+ cast(@id_svc as nvarchar(10)) + N' , rr.id_source_sess, null, null, null
				from ' + @table_name + N' rr
				inner join ' + @svctablename + N' svc WITH (READCOMMITTED)
				on rr.id_source_sess = svc.id_parent_source_sess
				where rr.tx_state = ''NC''
				and svc.id_source_sess not in (select id_source_sess from ' + @table_name +')'
			EXEC sp_executesql @query
			FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		END
		CLOSE tablename_cursor
		DEALLOCATE tablename_cursor
		set @query = N'update ' + @table_name + N'
			set tx_state = ''NA'' where
			tx_state = ''NC'''
		EXEC sp_executesql @query
		DROP TABLE #tmpcursor3
  end

GO
