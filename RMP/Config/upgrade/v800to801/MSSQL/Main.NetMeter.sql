
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error int)
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO


PRINT N'Altering [dbo].[t_sub_history]'
GO
ALTER TABLE [dbo].[t_sub_history] ADD
[tx_quoting_batch] [varbinary] (16) NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[t_sub]'
GO
ALTER TABLE [dbo].[t_sub] ADD
[tx_quoting_batch] [varbinary] (16) NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO


PRINT N'Altering [dbo].[t_rec_win_bcp_for_reverse]'
GO
ALTER TABLE [dbo].[t_rec_win_bcp_for_reverse] ADD
[c_CycleEffectiveDate] [datetime] NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
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
@p_tx_quoting_batch varbinary(16),
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
declare @temp_tx_quoting_batch varbinary(16)

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
		(id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,tx_quoting_batch,vt_start,vt_end,tt_start,tt_end)
		select 
			id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,tx_quoting_batch,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime
			from t_sub_history 
			where
			id_sub = @p_id_sub AND vt_end = dbo.subtractSecond(@tempstartdate)
		UNION ALL
		select
			id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,tx_quoting_batch,@realenddate,vt_end,@p_systemdate,@varMaxDateTime
			from t_sub_history
			where
			id_sub = @p_id_sub  AND vt_start = dbo.addsecond(@tempenddate)

	end

	-- detect directly adjacent records with a adjacent start and end date.  If the
	-- key comparison matches successfully, use the start and/or end date of the original record 
	-- instead.
    if 1=1 begin
        select @realstartdate = @startdate
        select @realenddate = @enddate;
    end 
    else begin
	    select @realstartdate = vt_start
	    from 
	    t_sub_history  where id_sub = @p_id_sub AND
		    @startdate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime
	    if @realstartdate is NULL begin
		    select @realstartdate = @startdate
	    end;
	    --CR 10620 fix: Do not add a second to end date
	    select @realenddate = vt_end
	    from
	    t_sub_history  where id_sub = @p_id_sub AND
	    @enddate between vt_start AND vt_end and tt_end = @varMaxDateTime
	    if @realenddate is NULL begin
		    select @realenddate = @enddate
	    end;
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
@temp_dt_crt = dt_crt,
@temp_tx_quoting_batch = tx_quoting_batch

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
   (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,tx_quoting_batch,vt_start,vt_end,tt_start,tt_end)
   select 
    @temp_id_sub,@temp_id_sub_ext,@temp_id_acc,@temp_id_group,@temp_id_po,@temp_dt_crt,@temp_tx_quoting_batch,@tempStartDate,dbo.subtractsecond(@realstartdate),
    @p_systemdate,@varMaxDateTime
    where @tempstartdate is not NULL AND @tempStartDate <> @realstartdate
    -- the previous statement may fail
		if @realenddate <> @tempendDate AND @realenddate <> @varMaxDateTime begin
			insert into t_sub_history 
			(id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,tx_quoting_batch,vt_start,vt_end,tt_start,tt_end)
	    select
	    @temp_id_sub,@temp_id_sub_ext,@temp_id_acc,@temp_id_group,@temp_id_po,@temp_dt_crt,@temp_tx_quoting_batch,@realenddate,@tempEndDate,
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
 (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,tx_quoting_batch,vt_start,vt_end,tt_start,tt_end)
 select 
 id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,tx_quoting_batch,@realenddate,vt_end,@p_systemdate,@varMaxDateTime
 from 
 t_sub_history  where
 id_sub = @p_id_sub AND 
 vt_start > @realstartdate and vt_start < @realenddate 
 and tt_end = @varMaxDateTime
 
 if 1=1 begin
     update t_sub_history
    set tt_end = @onesecond_systemdate
    where
    id_sub = @p_id_sub     and tt_end = @varMaxDateTime;
  end else begin
    update t_sub_history
    set tt_end = @onesecond_systemdate
    where
    id_sub = @p_id_sub AND 
    vt_start > @realstartdate and vt_start < @realenddate 
    and tt_end = @varMaxDateTime
 end
  
 -- step 4: update existing payment records that are overlapping on the end
 -- range
 -- Existing Record |--------------|
 -- New Record:             |-----------|
 insert into t_sub_history
 (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,tx_quoting_batch,vt_start,vt_end,tt_start,tt_end)
 select
 id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,tx_quoting_batch,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime
 from t_sub_history
 where
 id_sub = @p_id_sub AND 
 vt_end > @realstartdate AND vt_end < @realenddate
 AND tt_end = @varMaxDateTime
 
  if 1=1 begin
     update t_sub_history
     set tt_end = @onesecond_systemdate
     where id_sub = @p_id_sub
     AND tt_end = @varMaxDateTime;
   end else begin
        update t_sub_history
    set tt_end = @onesecond_systemdate
    where
    id_sub = @p_id_sub  AND 
      vt_end > @realstartdate AND vt_end < @realenddate 
      and tt_end = @varMaxDateTime
  end

 -- used to be realenddate
 -- step 7: create the new payment redirection record.  If the end date 
 -- is not max date, make sure the enddate is subtracted by one second
 insert into t_sub_history 
 (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,tx_quoting_batch,vt_start,vt_end,tt_start,tt_end)
 select 
 @p_id_sub,@p_id_sub_ext,@p_id_acc,@p_id_group,@p_id_po,@p_dt_crt,@p_tx_quoting_batch,@realstartdate,
  case when @realenddate = dbo.mtmaxdate() then @realenddate else 
  @realenddate end,
  @p_systemdate,@varMaxDateTime
  
delete from t_sub where id_sub = @p_id_sub
insert into t_sub (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,tx_quoting_batch,vt_start,vt_end)
select id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,tx_quoting_batch,vt_start,vt_end
from t_sub_history  where
id_sub = @p_id_sub and tt_end = @varMaxDateTime
 select @status = 1
 end
			
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[T_VW_EFFECTIVE_SUBS]'
GO
EXEC sp_refreshview N'[dbo].[T_VW_EFFECTIVE_SUBS]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[addsubscriptionbase]'
GO
ALTER procedure addsubscriptionbase(
@p_id_acc int,
@p_id_group int,
@p_id_po int,
@p_startdate datetime,
@p_enddate datetime,
@p_GUID varbinary(16),
@p_systemdate datetime,
@p_id_sub int,
@p_status int output,
@p_datemodified varchar output,
@p_allow_acc_po_curr_mismatch int = 0,
@p_allow_multiple_pi_sub_rcnrc int = 0,
@p_quoting_batch_id varchar(256) = null)
as
declare @varSystemGMTDateTime datetime,
				@varMaxDateTime datetime,
				@realstartdate datetime,
				@realenddate datetime,
				@realguid varbinary(16),
				@tx_quoting_batchid binary(16)
begin
	select @varMaxDateTime = dbo.mtmaxdate()
	-- We've got a lot of business rules to check but we need to 
	-- set up our X locks explicitly early on in the game.
	select 1 from t_sub with(updlock) where id_sub=@p_id_sub

	select @p_status = 0
	exec AdjustSubDates @p_id_po,@p_startdate,@p_enddate,@realstartdate OUTPUT,
		@realenddate OUTPUT,@p_datemodified OUTPUT,@p_status OUTPUT
	
	if @p_status <> 1 begin
		return
	end

	-- Check availability of the product offering
	select @p_status = case
		when ta.n_begintype = 0 or ta.n_endtype = 0 then -289472451
		when ta.n_begintype <> 0 and ta.dt_start > @p_systemdate then -289472449
		when ta.n_endtype <> 0 and ta.dt_end < @p_systemdate then -289472450
		else 1
		end
	from t_po po
	inner join t_effectivedate ta on po.id_avail=ta.id_eff_date
	where
	po.id_po=@p_id_po

	if (@p_status <> 1) begin
    return
	end

if (@p_id_acc is not NULL) begin
	select @p_status = dbo.CheckSubscriptionConflicts(@p_id_acc,@p_id_po,@realstartdate,@realenddate,-1,@p_allow_acc_po_curr_mismatch,@p_allow_multiple_pi_sub_rcnrc)
	if (@p_status <> 1) begin
    return
	end

 -- check if the po is BCR constrained.  If it is, make sure that the 
-- usage cycles for all the payers during the subscription interval
-- matches the cycle type on the po.
IF EXISTS (
  SELECT 1
  FROM
	t_payment_redirection pr
  INNER JOIN t_acc_usage_cycle auc ON pr.id_payer=auc.id_acc
  INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = auc.id_usage_cycle
	WHERE
  pr.id_payee = @p_id_acc
  AND
	pr.vt_start <= @realenddate
  AND
  @realstartdate <= pr.vt_end
	AND
  EXISTS (
    SELECT 1 FROM t_pl_map plm
    WHERE plm.id_paramtable IS NULL AND plm.id_po=@p_id_po
    AND
    (
      EXISTS (
        SELECT 1 FROM t_aggregate a WHERE a.id_prop = plm.id_pi_instance
        AND a.id_cycle_type IS NOT NULL AND a.id_cycle_type <> uc.id_cycle_type
      ) OR EXISTS (
        SELECT 1 FROM t_discount d WHERE d.id_prop = plm.id_pi_instance
        AND d.id_cycle_type IS NOT NULL AND d.id_cycle_type <> uc.id_cycle_type
      ) OR EXISTS (
        SELECT 1 FROM t_recur r WHERE r.id_prop = plm.id_pi_instance AND r.tx_cycle_mode = 'BCR Constrained'
        AND r.id_cycle_type IS NOT NULL AND r.id_cycle_type <> uc.id_cycle_type
      )
    )
  )
)
BEGIN
SET @p_status = -289472464 -- MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0030)
RETURN
END

IF EXISTS (
  SELECT 1
  FROM
	t_payment_redirection pr
  INNER JOIN t_acc_usage_cycle auc ON pr.id_payer=auc.id_acc
  INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = auc.id_usage_cycle
	WHERE
  pr.id_payee = @p_id_acc
  AND
	pr.vt_start <= @realenddate
  AND
  @realstartdate <= pr.vt_end
	AND
  EXISTS (
    SELECT 1 FROM t_pl_map plm
    WHERE plm.id_paramtable IS NULL AND plm.id_po=@p_id_po
    AND EXISTS (
        SELECT 1 FROM t_recur rc WHERE rc.id_prop = plm.id_pi_instance AND rc.tx_cycle_mode = 'EBCR'
        --Weekly and biweekly can coexist
        AND NOT (((rc.id_cycle_type = 4) OR (rc.id_cycle_type = 5))
        AND ((uc.id_cycle_type = 4) OR (uc.id_cycle_type = 5)))
        -- Monthly, quarterly, semiannually, and annually can coexist
        AND NOT ((rc.id_cycle_type in (1,7,8,9))
        AND (uc.id_cycle_type in (1,7,8,9)))
    )
  )
)
BEGIN
SET  @p_status = -289472444 -- MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0044)
RETURN
END
end

if (@p_GUID is NULL)
	begin
	select @realguid = newid()
	end
else
	begin
	select @realguid = @p_GUID
	end

if (@p_quoting_batch_id is NULL)
	begin
		SELECT @tx_quoting_batchid = null;
	end
else
	begin
		SELECT @tx_quoting_batchid = cast(N'' as xml).value('xs:hexBinary(sql:variable("@p_quoting_batch_id"))', 'binary(16)');
	end

	exec CreateSubscriptionRecord
		@p_id_sub,
		@realguid,
		@p_id_acc,
		@p_id_group,
		@p_id_po,
		@p_systemdate,
		@tx_quoting_batchid,
		@realstartdate,
		@realenddate,
		@p_systemdate,
		@status = @p_status OUTPUT
end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[AddNewSub]'
GO
ALTER procedure AddNewSub(
 @p_id_acc int,
 @p_dt_start datetime,
 @p_dt_end datetime,
 @p_NextCycleAfterStartDate varchar,
 @p_NextCycleAfterEndDate varchar,
 @p_id_po int,
 @p_GUID varbinary(16),
 @p_systemdate datetime,
 @p_id_sub int,
 @p_status int output,
 @p_datemodified varchar(1) output,
 @p_allow_acc_po_curr_mismatch int = 0,
 @p_allow_multiple_pi_sub_rcnrc int = 0,
 @p_quoting_batch_id varchar(256)=null)
as
begin
declare @real_begin_date as datetime
declare @real_end_date as datetime
declare @po_effstartdate as datetime
declare @varMaxDateTime datetime
declare @datemodified varchar(1)
select @varMaxDateTime = dbo.MTMaxDate()
	select @p_status =0
-- compute usage cycle dates if necessary
if (upper(@p_NextCycleAfterStartDate) = 'Y')
 begin
 select @real_begin_date = dbo.NextDateAfterBillingCycle(@p_id_acc,@p_dt_start)
 end
else
 begin
   select @real_begin_date = @p_dt_start
 end
if (upper(@p_NextCycleAfterEndDate) = 'Y' AND @p_dt_end is not NULL)
 begin
 select @real_end_date = dbo.NextDateAfterBillingCycle(@p_id_acc,@p_dt_end)
   end
else
 begin
 select @real_end_date = @p_dt_end
 end
if (@p_dt_end is NULL)
 begin
 select @real_end_date = @varMaxDateTime
 end

exec AddSubscriptionBase
			@p_id_acc,
			NULL,
			@p_id_po,
			@real_begin_date,
			@real_end_date,
			@p_GUID,
			@p_systemdate,
			@p_id_sub,
			@p_status output,
			@datemodified output,
			@p_allow_acc_po_curr_mismatch,
			@p_allow_multiple_pi_sub_rcnrc,
			@p_quoting_batch_id

select @p_datemodified = @datemodified
end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[updatesub]'
GO
ALTER PROCEDURE updatesub (
@p_id_sub INT,
@p_dt_start datetime,
@p_dt_end datetime,
@p_nextcycleafterstartdate VARCHAR,
@p_nextcycleafterenddate VARCHAR,
@p_id_po INT,
@p_id_acc INT,
@p_systemdate datetime,
@p_status INT OUTPUT,
@p_datemodified varchar OUTPUT,
@p_allow_acc_po_curr_mismatch int = 0,
@p_allow_multiple_pi_sub_rcnrc int = 0
)
AS
BEGIN
	DECLARE @real_begin_date as datetime
	DECLARE @real_end_date as datetime
	declare @varMaxDateTime datetime
	declare @temp_guid varbinary(16)
	declare @id_group as integer
  	declare @cycle_type as integer
  	declare @po_cycle as integer

	select @varMaxDateTime = dbo.MTMaxDate()
	-- step 1: compute usage cycle dates if necessary
	select @p_status = 0
	SELECT @temp_guid = id_sub_ext
	FROM t_sub with(updlock)
	WHERE id_sub = @p_id_sub

	SELECT top 1 *
	FROM t_sub with(updlock)
	WHERE id_sub > @p_id_sub
	order by id_sub asc

	if @p_id_acc is not NULL
        begin
	
		IF (@p_nextcycleafterstartdate = 'Y') begin
			select @real_begin_date =dbo.nextdateafterbillingcycle (@p_id_acc, @p_dt_start)
		end
		ELSE begin
			select @real_begin_date = @p_dt_start
		END
		IF (@p_nextcycleafterenddate = 'Y') begin
		-- CR 5785: make sure the end date of the subscription if using billing cycle
		-- relative is at the end of the current billing cycle
			select @real_end_date = dbo.subtractsecond (
		                        dbo.nextdateafterbillingcycle (@p_id_acc, @p_dt_end))
		end
		ELSE begin
			select @real_end_date = @p_dt_end
		END
		-- step 2: if the begin date is after the end date, make the begin date match the end date
		IF (@real_begin_date > @real_end_date) begin
			select @real_begin_date = @real_end_date
		END
		select @p_status = dbo.checksubscriptionconflicts (
		                 @p_id_acc,@p_id_po,@real_begin_date,@real_end_date,
		                 @p_id_sub,@p_allow_acc_po_curr_mismatch,@p_allow_multiple_pi_sub_rcnrc)
		IF (@p_status <> 1) begin
		  RETURN
		END

		-- check if the po is BCR constrained.  If it is, make sure that the 
		-- usage cycles for all the payers during the subscription interval
		-- matches the cycle type on the po.
		IF EXISTS (
		  SELECT 1
		  FROM
			t_payment_redirection pr
		  INNER JOIN t_acc_usage_cycle auc ON pr.id_payer=auc.id_acc
		  INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = auc.id_usage_cycle
			WHERE
		  pr.id_payee = @p_id_acc
		  AND
			pr.vt_start <= @real_end_date
		  AND
		  @real_begin_date <= pr.vt_end
			AND
		  EXISTS (
		    SELECT 1 FROM t_pl_map plm
		    WHERE plm.id_paramtable IS NULL AND plm.id_po=@p_id_po
		    AND
		    (
		      EXISTS (
		        SELECT 1 FROM t_aggregate a WHERE a.id_prop = plm.id_pi_instance
		        AND a.id_cycle_type IS NOT NULL AND a.id_cycle_type <> uc.id_cycle_type
		      ) OR EXISTS (
		        SELECT 1 FROM t_discount d WHERE d.id_prop = plm.id_pi_instance
		        AND d.id_cycle_type IS NOT NULL AND d.id_cycle_type <> uc.id_cycle_type
		      ) OR EXISTS (
		        SELECT 1 FROM t_recur r WHERE r.id_prop = plm.id_pi_instance AND r.tx_cycle_mode = 'BCR Constrained'
		        AND r.id_cycle_type IS NOT NULL AND r.id_cycle_type <> uc.id_cycle_type
		      )
		    )
		  )
		)
		BEGIN
		SET @p_status = -289472464 -- MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0030)
		RETURN
		END
		
		IF EXISTS (
		  SELECT 1
		  FROM
			t_payment_redirection pr
		  INNER JOIN t_acc_usage_cycle auc ON pr.id_payer=auc.id_acc
		  INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = auc.id_usage_cycle
			WHERE
		  pr.id_payee = @p_id_acc
		  AND
			pr.vt_start <= @real_end_date
		  AND
		  @real_begin_date <= pr.vt_end
			AND
		  EXISTS (
		    SELECT 1 FROM t_pl_map plm
		    WHERE plm.id_paramtable IS NULL AND plm.id_po=@p_id_po
		    AND EXISTS (
		        SELECT 1 FROM t_recur rc WHERE rc.id_prop = plm.id_pi_instance AND rc.tx_cycle_mode = 'EBCR'
		        AND NOT (((rc.id_cycle_type = 4) OR (rc.id_cycle_type = 5))
		        AND ((uc.id_cycle_type = 4) OR (uc.id_cycle_type = 5)))
		        AND NOT (((rc.id_cycle_type = 1) OR (rc.id_cycle_type = 7) OR (rc.id_cycle_type = 8) OR (rc.id_cycle_type = 9))
		        AND ((uc.id_cycle_type = 1) OR (uc.id_cycle_type = 7) OR (uc.id_cycle_type = 8) OR (uc.id_cycle_type = 9)))
		    )
		  )
		)
		BEGIN
		SET  @p_status = -289472444 -- MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0044)
		RETURN
		END

	end
	else begin
		select @real_begin_date = @p_dt_start
		select @real_end_date = @p_dt_end
		select @id_group = id_group from t_sub where id_sub = @p_id_sub
	end

	-- verify that the start and end dates are inside the product offering effective
	-- date
	exec AdjustSubDates @p_id_po,@real_begin_date,@real_end_date,
		@real_begin_date OUTPUT,@real_end_date OUTPUT,@p_datemodified OUTPUT,
		@p_status OUTPUT
	if @p_status <> 1 begin
		return
	end

	exec CreateSubscriptionRecord
		@p_id_sub,
		@temp_guid,
		@p_id_acc,
		@id_group,
		@p_id_po,
		@p_systemdate,
		null,
		@real_begin_date,
		@real_end_date,
		@p_systemdate,
		@p_status OUTPUT
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[T_VW_ACCTRES]'
GO
EXEC sp_refreshview N'[dbo].[T_VW_ACCTRES]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[InsertChargesIntoSvcTables]'
GO
ALTER PROCEDURE InsertChargesIntoSvcTables
    AS
BEGIN
    DECLARE @id_run INT
    declare @idMessage BIGINT
    DECLARE @idServiceFlat int
    DECLARE @idServiceUdrc int
    DECLARE @numBlocks INT
    DECLARE @partition INT

	SELECT @numBlocks = COUNT(1) FROM #tmp_rc;
 	EXEC GetIdBlock @numBlocks, 'id_dbqueuesch', @idMessage OUTPUT;
    EXEC GetIdBlock @numBlocks, 'id_dbqueuess', @id_run OUTPUT;
    
	select @partition = MAX(current_id_partition) FROM t_archive_queue_partition;
	--print @partition;
	 
    set @idServiceFlat = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data LIKE
	  'metratech.com/flatrecurringcharge');
    set @idServiceUdrc = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data LIKE
      'metratech.com/udrecurringcharge');
    
    INSERT INTO t_session
      SELECT @id_run + ROW_NUMBER() OVER (ORDER BY idSourceSess) - 1 AS id_ss,
             idSourceSess AS id_source_sess, @partition as id_partition
      FROM #tmp_rc;
         
   INSERT INTO t_session_set
     SELECT @idMessage + ROW_NUMBER() OVER (ORDER BY idSourceSess) - 1 AS id_message,
            @id_run + ROW_NUMBER() OVER (ORDER BY idSourceSess) - 1 AS id_ss,
            case when c_unitValue IS NULL then @idServiceFlat ELSE @idServiceUdrc END AS id_svc,
            1 AS b_root,
            1 AS session_count,
			@partition as id_partition
     FROM #tmp_rc;
 
   INSERT INTO t_message
      select
        @idMessage + ROW_NUMBER() OVER (ORDER BY idSourceSess) - 1 AS id_message,
        NULL as id_route,
        dbo.metratime(1,'RC') as dt_crt,
        dbo.metratime(1,'RC') as dt_metered,
        NULL as dt_assigned,
        NULL as id_listener,
        NULL as id_pipeline,
        NULL as dt_completed,
        NULL as id_feedback,
        NULL as tx_TransactionID,
        NULL as tx_sc_username,
        NULL as tx_sc_password,
        NULL as tx_sc_namespace,
        NULL as tx_sc_serialized,
       '127.0.0.1' as tx_ip_address,
		@partition as id_partition
   FROM #tmp_rc;
   
   INSERT INTO t_svc_FlatRecurringCharge
   (
   	id_source_sess
         ,id_parent_source_sess
         ,id_external
         ,c_RCActionType
         ,c_RCIntervalStart
         ,c_RCIntervalEnd
         ,c_BillingIntervalStart
         ,c_BillingIntervalEnd
         ,c_RCIntervalSubscriptionStart
         ,c_RCIntervalSubscriptionEnd
         ,c_SubscriptionStart
         ,c_SubscriptionEnd
         ,c_Advance
         ,c_ProrateOnSubscription
         ,c_ProrateInstantly
         ,c_ProrateOnUnsubscription
         ,c_ProrationCycleLength
         ,c__AccountID
         ,c__PayingAccount
         ,c__PriceableItemInstanceID
         ,c__PriceableItemTemplateID
         ,c__ProductOfferingID
         ,c_BilledRateDate
         ,c__SubscriptionID
         ,c__IntervalID
         ,c__Resubmit
         ,c__TransactionCookie
         ,c__CollectionID
   )
       SELECT
         idSourceSess AS id_source_sess
         ,NULL AS id_parent_source_sess
         ,NULL AS id_external
         ,c_RCActionType
         ,c_RCIntervalStart
         ,c_RCIntervalEnd
         ,c_BillingIntervalStart
         ,c_BillingIntervalEnd
         ,c_RCIntervalSubscriptionStart
         ,c_RCIntervalSubscriptionEnd
         ,c_SubscriptionStart
         ,c_SubscriptionEnd
         ,c_Advance
         ,c_ProrateOnSubscription
         ,c_ProrateInstantly
         ,c_ProrateOnUnsubscription
         ,c_ProrationCycleLength
         ,c__AccountID
         ,c__PayingAccount
         ,c__PriceableItemInstanceID
         ,c__PriceableItemTemplateID
         ,c__ProductOfferingID
         ,c_BilledRateDate
         ,c__SubscriptionID
         ,c__IntervalID
         ,'0' AS c__Resubmit
         ,NULL AS c__TransactionCookie
         ,c__QuoteBatchId AS c__CollectionID
      FROM #tmp_rc WHERE c_UnitValue IS NULL;
    
      INSERT INTO t_svc_UDRecurringCharge
      (
      	    id_source_sess
           ,id_parent_source_sess
           ,id_external
           ,c_RCActionType
           ,c_RCIntervalStart
           ,c_RCIntervalEnd
           ,c_BillingIntervalStart
           ,c_BillingIntervalEnd
           ,c_RCIntervalSubscriptionStart
           ,c_RCIntervalSubscriptionEnd
           ,c_SubscriptionStart
           ,c_SubscriptionEnd
           ,c_Advance
           ,c_ProrateOnSubscription
           ,c_UnitValueStart
           ,c_UnitValueEnd
           ,c_UnitValue
           ,c_RatingType
           ,c_ProrateOnUnsubscription
           ,c_ProrationCycleLength
           ,c_BilledRateDate
           ,c__SubscriptionID
           ,c__AccountID
           ,c__PayingAccount
           ,c__PriceableItemInstanceID
           ,c__PriceableItemTemplateID
           ,c__ProductOfferingID
           ,c__IntervalID
           ,c__Resubmit
           ,c__TransactionCookie
           ,c__CollectionID
           )
        SELECT
           idSourceSess AS id_source_sess
           ,NULL AS id_parent_source_sess
           ,NULL AS id_external
           ,c_RCActionType
           ,c_RCIntervalStart
           ,c_RCIntervalEnd
           ,c_BillingIntervalStart
           ,c_BillingIntervalEnd
           ,c_RCIntervalSubscriptionStart
           ,c_RCIntervalSubscriptionEnd
           ,c_SubscriptionStart
           ,c_SubscriptionEnd
           ,c_Advance
           ,c_ProrateOnSubscription
           ,c_UnitValueStart
           ,c_UnitValueEnd
           ,c_UnitValue
           ,c_RatingType
           ,c_ProrateOnUnsubscription
           ,c_ProrationCycleLength
           ,c_BilledRateDate
           ,c__SubscriptionID
           ,c__AccountID
           ,c__PayingAccount
           ,c__PriceableItemInstanceID
           ,c__PriceableItemTemplateID
           ,c__ProductOfferingID
           ,c__IntervalID
           ,'0' AS c__Resubmit
           ,NULL AS c__TransactionCookie
           ,c__QuoteBatchId AS c__CollectionID
       FROM #tmp_rc WHERE c_UnitValue IS not NULL
    ;
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MeterInitialFromRecurWindow]'
GO
ALTER PROCEDURE [dbo].[MeterInitialFromRecurWindow]
	@currentDate DATETIME
AS
    BEGIN
  /* SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements. */
SET NOCOUNT ON;
  IF (( SELECT VALUE FROM t_db_values WHERE parameter = N'InstantRc' ) = 'false' ) RETURN;

  SELECT 'Initial'                                                                                  AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)                                  AS c_RCIntervalSubscriptionStart,
         dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)                                      AS c_RCIntervalSubscriptionEnd,
         rw.c_SubscriptionStart                                                                     AS c_SubscriptionStart,
         rw.c_SubscriptionEnd                                                                       AS c_SubscriptionEnd,
         dbo.MTMinOfTwoDates(pci.dt_end, rw.c_SubscriptionEnd)                                      AS c_BilledRateDate,
         rcr.n_rating_type                                                                          AS c_RatingType,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,
         CASE WHEN rcr.b_prorate_on_activate = 'Y' THEN '1' ELSE '0' END                            AS c_ProrateOnSubscription,
         CASE WHEN rcr.b_prorate_instantly = 'Y' THEN '1' ELSE '0' END                              AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         CASE WHEN rcr.b_prorate_on_deactivate = 'Y' THEN '1' ELSE '0' END                          AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__payingaccount                                                                        AS c__PayingAccount,
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         currentui.id_interval                                                                      AS c__IntervalID,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         NEWID()                                                                                    AS idSourceSess,
         sub.tx_quoting_batch                                                                       as c__QuoteBatchId
INTO #tmp_rc
  FROM   t_usage_interval ui
         INNER JOIN #recur_window_holder rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND rw.c_SubscriptionStart < ui.dt_end   AND rw.c_SubscriptionEnd > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
         INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
         INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER LOOP JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
                                        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                                        ELSE NULL
                                       END
         INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
         INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
              AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON rw.c_SubscriptionStart BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
  WHERE 
        /* Only meter new subscriptions as initial -- so select only items that have at most one entry in t_sub_history */ 
        NOT EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate()) 
         /* Also no old unit values */
        AND NOT EXISTS (SELECT 1 FROM t_recur_value trv WHERE trv.id_sub = rw.c__SubscriptionID AND trv.tt_end < dbo.MTMaxDate())
        /* Meter only in 1-st billing interval */
        AND ui.dt_start <= rw.c_SubscriptionStart
        AND ui.dt_start < @currentDate
        AND rw.c__IsAllowGenChargeByTrigger = 1;

  /* If no charges to meter, return immediately */
  IF (NOT EXISTS (SELECT 1 FROM #tmp_rc)) RETURN;

  EXEC InsertChargesIntoSvcTables;

  MERGE
  INTO    #recur_window_holder trw
  USING   (
            SELECT MAX(c_RCIntervalSubscriptionEnd) AS NewBilledThroughDate, c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
            FROM #tmp_rc
            GROUP BY c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
          ) trc
  ON      (
            trw.c__AccountID = trc.c__AccountID
            AND trw.c__SubscriptionID = trc.c__SubscriptionID
            AND trw.c__PriceableItemInstanceID = trc.c__PriceableItemInstanceID
            AND trw.c__PriceableItemTemplateID = trc.c__PriceableItemTemplateID
            AND trw.c__ProductOfferingID = trc.c__ProductOfferingID
            AND trw.c__IsAllowGenChargeByTrigger = 1
          )
  WHEN MATCHED THEN
  UPDATE
  SET     trw.c_BilledThroughDate = trc.NewBilledThroughDate;

END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MeterCreditFromRecurWindow]'
GO
ALTER PROCEDURE [dbo].[MeterCreditFromRecurWindow]
  @currentDate DATETIME
AS
BEGIN
  /* SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements. */
  SET NOCOUNT ON;
  IF (( SELECT VALUE FROM t_db_values WHERE parameter = N'InstantRc' ) = 'false' ) RETURN;

  DECLARE @newSubStart DATETIME,
          @newSubEnd   DATETIME,
          @curSubStart DATETIME,
          @curSubEnd   DATETIME,
          /* Borders of updated Sub.End range will stand for internal @subscriptionStart and @subscriptionEnd to charge this range. */
          @subscriptionStart        DATETIME,
          @subscriptionEnd          DATETIME,
          @rcAction                 VARCHAR(20),
          @isEndDateUpdated         BIT = 0,
  /* TODO: Remove duplicated values once 1-st and 2-nd query is executed conditionally */
          /* Borders of updated Sub.Start range will stand for internal @subscriptionStart2 and @subscriptionEnd2 to charge this range. */
          @subscriptionStart2       DATETIME,
          @subscriptionEnd2         DATETIME,
          @rcAction2                VARCHAR(20),
          @isStartDateUpdated       BIT = 0,
          /* Values for full recharge of Arrears if End date update crosses EOP border */
          @subscriptionStart3       DATETIME,
          @subscriptionEnd3         DATETIME,
          @rcAction3                VARCHAR(20)

  SELECT @subscriptionStart = dbo.MTMinDate(), @subscriptionEnd = dbo.MTMinDate();

  /* Assuming only 1 subscription can be changed at a time */
  SELECT TOP 1 /* Using only 1-st PI of RC */
         @newSubStart = new_sub.vt_start, @newSubEnd = new_sub.vt_end,
         @curSubStart = current_sub.vt_start, @curSubEnd = current_sub.vt_end
  FROM #recur_window_holder rw
      INNER LOOP JOIN t_sub_history new_sub ON new_sub.id_acc = rw.c__AccountID
          AND new_sub.id_sub = rw.c__SubscriptionID
          AND new_sub.tt_end = dbo.MTMaxDate()
      INNER LOOP JOIN t_sub_history current_sub ON current_sub.id_acc = rw.c__AccountID
          AND current_sub.id_sub = rw.c__SubscriptionID
          AND current_sub.tt_end = dbo.SubtractSecond(new_sub.tt_start)
  /* Work with RC only. Exclude UDRC. */
  WHERE rw.c_UnitValue IS NULL

  /* It is a new subscription - nothing to recharge */
  IF @curSubStart IS NULL RETURN;
          
  IF (@newSubEnd <> @curSubEnd)
  BEGIN
      /* TODO: Run only 1-st query if condition is true */
      SET @isEndDateUpdated = 1

      SELECT @subscriptionStart = dbo.MTMinOfTwoDates(@newSubEnd, @curSubEnd),
             @subscriptionEnd = dbo.MTMaxOfTwoDates(@newSubEnd, @curSubEnd),
             @rcAction = CASE 
                              WHEN @newSubEnd > @curSubEnd THEN 
                                   'Debit'
                              ELSE 'Credit'
                         END;
      /* Sub. start date has 23:59:59 time. We need next day and 00:00:00 time for the start date */
      SET @subscriptionStart = dbo.AddSecond(@subscriptionStart);

      IF (@newSubEnd > @curSubEnd)
      BEGIN
          SET @subscriptionStart3 = @curSubStart
          SET @subscriptionEnd3   = @curSubEnd
          SET @rcAction3          = 'Credit'
      END
      ELSE
      BEGIN
          SET @subscriptionStart3 = @newSubStart
          SET @subscriptionEnd3   = @newSubEnd
          SET @rcAction3          = 'Debit'
      END
  END;

  IF (@newSubStart <> @curSubStart)
  BEGIN
      /* TODO: Run only 2-nd query if condition is true */
      SET @isStartDateUpdated = 1

      SELECT @subscriptionStart2 = dbo.MTMinOfTwoDates(@newSubStart, @curSubStart),
             @subscriptionEnd2 = dbo.MTMaxOfTwoDates(@newSubStart, @curSubStart),
             @rcAction2 =  CASE 
                                WHEN @newSubStart < @curSubStart THEN 
                                     'InitialDebit'
                                ELSE 'InitialCredit'
                           END;
      /* Sub. end date has 00:00:00 time. We need previous day and 23:59:59 time for the end date */
      SELECT @subscriptionEnd2 = dbo.SubtractSecond(@subscriptionEnd2);
  END;


  SELECT
         /* First, credit or debit the difference in the ending of the subscription.  If the new one is later, this will be a debit, otherwise a credit.
         * TODO: Remove this comment:"There's a weird exception when this is (a) an arrears charge, (b) the old subscription end was after the pci end date, and (c) the new sub end is inside the pci end date." */
         @rcAction                                                                                  AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, @subscriptionStart)                                      AS c_RCIntervalSubscriptionStart,
         dbo.mtminoftwodates(pci.dt_end, @subscriptionEnd)                                          AS c_RCIntervalSubscriptionEnd,
         @subscriptionStart                                                                         AS c_SubscriptionStart,
         @subscriptionEnd                                                                           AS c_SubscriptionEnd,
         dbo.MTMinOfTwoDates(pci.dt_end, @subscriptionStart)                                        AS c_BilledRateDate,
         rcr.n_rating_type                                                                          AS c_RatingType,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,
         CASE WHEN rcr.b_prorate_on_activate = 'Y' THEN '1' ELSE '0' END                            AS c_ProrateOnSubscription,
         CASE WHEN rcr.b_prorate_instantly = 'Y' THEN '1' ELSE '0' END                              AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         CASE WHEN rcr.b_prorate_on_deactivate = 'Y' THEN '1' ELSE '0' END                          AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__payingaccount                                                                        AS c__PayingAccount,
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         currentui.id_interval                                                                      AS c__IntervalID,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         sub.tx_quoting_batch                                                                       AS c__QuoteBatchId,
         0                                                                                          AS IsArrearsRecalculation
         INTO #tmp_rc_1
  FROM   t_usage_interval ui
         INNER JOIN #recur_window_holder rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              /* AddSecond() relates to CORE-8443*/
              AND @subscriptionStart <= dbo.AddSecond(ui.dt_end) AND @subscriptionEnd > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */  
         INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER LOOP JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, @subscriptionStart, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND @subscriptionStart       < pci.dt_end AND @subscriptionEnd       > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON @currentDate BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
  WHERE
         ui.dt_start < @currentDate
         /* We're working only with Bill. interval where subscription starts, except future one */
         AND @newSubStart BETWEEN ui.dt_start AND ui.dt_end
         AND @isEndDateUpdated = 1
         AND NOT (rw.c_advance = 'N' AND @newSubEnd > ui.dt_end)
         /* Skip if this is an Arrears AND end date update crosses the EOP border (this case will be handled below) */
         AND NOT (rw.c_advance = 'N' AND @subscriptionStart <= dbo.AddSecond(ui.dt_end) AND ui.dt_end < @subscriptionEnd)

  UNION ALL

  SELECT
         /* Now, credit or debit the difference in the start of the subscription.  If the new one is earlier, this will be a debit, otherwise a credit*/
         @rcAction2                                                                                 AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, @subscriptionStart2)                                     AS c_RCIntervalSubscriptionStart,         
         /* If new Subscription Start somewhere in future, after EOP - always use End of RC cycle */
         CASE
              WHEN ui.dt_end <= @subscriptionEnd2 THEN pci.dt_end
              ELSE dbo.mtminoftwodates(pci.dt_end, @subscriptionEnd2)
         END                                                                                        AS c_RCIntervalSubscriptionEnd,
         @subscriptionStart2                                                                        AS c_SubscriptionStart,
         @subscriptionEnd2                                                                          AS c_SubscriptionEnd,
         dbo.MTMinOfTwoDates(pci.dt_end, @subscriptionStart2)                                       AS c_BilledRateDate,
         rcr.n_rating_type                                                                          AS c_RatingType,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,
         CASE WHEN rcr.b_prorate_on_activate = 'Y' THEN '1' ELSE '0' END                            AS c_ProrateOnSubscription,
         CASE WHEN rcr.b_prorate_instantly = 'Y' THEN '1' ELSE '0' END                              AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         CASE WHEN rcr.b_prorate_on_deactivate = 'Y' THEN '1' ELSE '0' END                          AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__payingaccount                                                                        AS c__PayingAccount,
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         currentui.id_interval                                                                      AS c__IntervalID,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         sub.tx_quoting_batch                                                                       AS c__QuoteBatchId,
         0                                                                                          AS IsArrearsRecalculation
  FROM   t_usage_interval ui
         INNER JOIN #recur_window_holder rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND @subscriptionStart2      < ui.dt_end AND @subscriptionEnd2      > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */  
         INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER LOOP JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, @subscriptionStart2, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND @subscriptionStart2      < pci.dt_end AND @subscriptionEnd2      > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON @currentDate BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
  WHERE
         ui.dt_start < @currentDate
         AND @isStartDateUpdated = 1
         AND NOT (rw.c_advance = 'N' AND @newSubEnd > ui.dt_end)
         /* Skip if this is an Arrears AND end date update crosses the EOP border (this case will be handled below) */
         AND NOT (rw.c_advance = 'N' AND @subscriptionStart <= dbo.AddSecond(ui.dt_end) AND ui.dt_end < @subscriptionEnd)

  UNION ALL

  SELECT
         /* Handle the case if this is an Arrears AND end date update crosses the EOP border */
         @rcAction3                                                                                 AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, @subscriptionStart3)                                     AS c_RCIntervalSubscriptionStart,
         dbo.mtminoftwodates(pci.dt_end, @subscriptionEnd3)                                         AS c_RCIntervalSubscriptionEnd,
         @subscriptionStart3                                                                        AS c_SubscriptionStart,
         @subscriptionEnd3                                                                          AS c_SubscriptionEnd,
         dbo.MTMinOfTwoDates(pci.dt_end, @subscriptionStart3)                                       AS c_BilledRateDate,
         rcr.n_rating_type                                                                          AS c_RatingType,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,
         CASE WHEN rcr.b_prorate_on_activate = 'Y' THEN '1' ELSE '0' END                            AS c_ProrateOnSubscription,
         CASE WHEN rcr.b_prorate_instantly = 'Y' THEN '1' ELSE '0' END                              AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         CASE WHEN rcr.b_prorate_on_deactivate = 'Y' THEN '1' ELSE '0' END                          AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__payingaccount                                                                        AS c__PayingAccount,
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         currentui.id_interval                                                                      AS c__IntervalID,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         sub.tx_quoting_batch                                                                       AS c__QuoteBatchId,
         1                                                                                          AS IsArrearsRecalculation
  FROM   t_usage_interval ui
         INNER JOIN #recur_window_holder rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND @subscriptionStart3      < ui.dt_end AND @subscriptionEnd3      > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */  
         INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER LOOP JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, @subscriptionStart3, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND @subscriptionStart3      < pci.dt_end AND @subscriptionEnd3      > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON @currentDate BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
  WHERE
         ui.dt_start < @currentDate
         /* Handle the case if this is an Arrears AND end date update crosses the EOP border */
         AND rw.c_advance = 'N' AND @subscriptionStart <= dbo.AddSecond(ui.dt_end) AND ui.dt_end < @subscriptionEnd;

  /* Remove extra charges for RCs with No Proration (CORE-6789) */
  IF (@isEndDateUpdated = 1)
  BEGIN
    /* PIs, that starts outside of End Date Update range, should not be handled here */
    DELETE FROM #tmp_rc_1 WHERE c_ProrateOnUnsubscription = '0'
        AND c_RCIntervalStart < @subscriptionStart
        AND IsArrearsRecalculation = 0;

    /* Turn On "Prorate On Subscription" if this is the 1-st RC Cycle of PI with "Prorate on Unsubscription" */
    UPDATE #tmp_rc_1
    SET c_ProrateOnSubscription = '1'
    WHERE c_ProrateOnUnsubscription = '1' AND @newSubStart BETWEEN c_RCIntervalStart AND c_RCIntervalEnd
  END
  IF (@isStartDateUpdated = 1)
    /* PIs, that ends outside of Start Date Update range, should not be handled here */
    DELETE FROM #tmp_rc_1 WHERE c_ProrateOnSubscription = '0' AND c_RCIntervalEnd > @subscriptionEnd2
      AND @subscriptionEnd2 < c_BillingIntervalEnd
      AND IsArrearsRecalculation = 0; /* If start date was updated To or From "after EOP date" all PIs should be charged. Don't delete anything. */

  SELECT c__SubscriptionID, c__PriceableItemInstanceID, c__PriceableItemTemplateID
         INTO #unbilledPIs
  FROM   #tmp_rc_1
  WHERE
         c_Advance = 0 AND c_BillingIntervalEnd BETWEEN @curSubEnd AND @newSubEnd
  UNION ALL
  SELECT c__SubscriptionID, c__PriceableItemInstanceID, c__PriceableItemTemplateID
  FROM   #tmp_rc_1
  WHERE
         c_Advance = 1 AND c_BillingIntervalEnd BETWEEN @curSubStart AND @newSubStart

  /* Changes related to ESR-6709:"Subscription refunded many times" */
  /* Now determine if the interval and if the RC adapter has run, if no remove those advanced charge credits */
  DECLARE @prev_interval INT, @cur_interval INT, @do_credit INT

  SELECT @prev_interval = pui.id_interval, @cur_interval = cui.id_interval
  FROM   t_usage_interval cui WITH(NOLOCK)
         INNER JOIN #tmp_rc_1 ON #tmp_rc_1.c__IntervalID = cui.id_interval
         INNER JOIN t_usage_cycle uc WITH(NOLOCK) ON cui.id_usage_cycle = uc.id_usage_cycle
         INNER JOIN t_usage_interval pui WITH(NOLOCK) ON pui.dt_end = dbo.SubtractSecond(cui.dt_start)
              AND pui.id_usage_cycle = cui.id_usage_cycle

  SELECT @do_credit = (
             CASE 
                  WHEN ISNULL(rei.id_arg_interval, 0) = 0 THEN 0
                  ELSE CASE 
                            WHEN (rr.tx_type = 'Execute' AND rei.tx_status = 'Succeeded') THEN 
                                 1
                            ELSE 0
                       END
             END
         )
  FROM   t_recevent re
         LEFT OUTER JOIN t_recevent_inst rei
              ON  re.id_event = rei.id_event
              AND rei.id_arg_interval = @prev_interval
         LEFT OUTER JOIN t_recevent_run rr
              ON  rr.id_instance = rei.id_instance
  WHERE  re.dt_deactivated IS NULL
         AND re.tx_name = 'RecurringCharges'
         AND rr.id_run = (
                 SELECT MAX(rr.id_run)
                 FROM   t_recevent re
                        LEFT OUTER JOIN t_recevent_inst rei
                             ON  re.id_event = rei.id_event
                             AND rei.id_arg_interval = @prev_interval
                        LEFT OUTER JOIN t_recevent_run rr
                             ON  rr.id_instance = rei.id_instance
                 WHERE  re.dt_deactivated IS NULL
                        AND re.tx_name = 'RecurringCharges'
             )

  IF @do_credit = 0
  BEGIN
      DELETE rcred
      FROM   #tmp_rc_1 rcred
             INNER JOIN t_usage_interval ui
                  ON  ui.id_interval = @cur_interval
                  AND rcred.c_BillingIntervalStart = ui.dt_start
  END;
  /* End of ESR-6709 */

  SELECT c_RCActionType,
         c_RCIntervalStart,
         c_RCIntervalEnd,
         c_BillingIntervalStart,
         c_BillingIntervalEnd,
         c_RCIntervalSubscriptionStart,
         c_RCIntervalSubscriptionEnd,
         c_SubscriptionStart,
         c_SubscriptionEnd,
         c_Advance,
         c_ProrateOnSubscription,
         c_ProrateInstantly,
         c_UnitValueStart,
         c_UnitValueEnd,
         c_UnitValue,
         c_RatingType,
         c_ProrateOnUnsubscription,
         c_ProrationCycleLength,
         c__AccountID,
         c__PayingAccount,
         c__PriceableItemInstanceID,
         c__PriceableItemTemplateID,
         c__ProductOfferingID,
         c_BilledRateDate,
         c__SubscriptionID,
         c__IntervalID,
         NEWID() AS idSourceSess,
         c__QuoteBatchId
         INTO #tmp_rc
  FROM #tmp_rc_1;

  /* If no charges to meter, return immediately */
  IF (NOT EXISTS (SELECT 1 FROM #tmp_rc)) RETURN;
 
  EXEC InsertChargesIntoSvcTables;

  MERGE
  INTO    #recur_window_holder trw
  USING   (
            SELECT MAX(dbo.mtminoftwodates(c_RCIntervalEnd, @newSubEnd)) AS NewBilledThroughDate,
                   c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c__SubscriptionID
            FROM #tmp_rc
            GROUP BY c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c__SubscriptionID
          ) trc
  ON      (
            trw.c__AccountID = trc.c__AccountID
            AND trw.c__SubscriptionID = trc.c__SubscriptionID
            AND trw.c__PriceableItemInstanceID = trc.c__PriceableItemInstanceID
            AND trw.c__PriceableItemTemplateID = trc.c__PriceableItemTemplateID
            AND trw.c__ProductOfferingID = trc.c__ProductOfferingID
            AND trw.c__IsAllowGenChargeByTrigger = 1
          )
  WHEN MATCHED THEN
  UPDATE
  SET     trw.c_BilledThroughDate = trc.NewBilledThroughDate;

  UPDATE rw
  SET    c_BilledThroughDate = dbo.mtmindate()
  FROM   #recur_window_holder rw
  WHERE
         rw.c__SubscriptionID IN (SELECT c__SubscriptionID FROM #unbilledPIs)
         AND rw.c__PriceableItemInstanceID IN (SELECT c__PriceableItemInstanceID FROM #unbilledPIs)
         AND rw.c__IsAllowGenChargeByTrigger = 1;

END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[AllowInitialArrersCharge]'
GO
ALTER FUNCTION AllowInitialArrersCharge(@b_advance char, @id_acc int, @sub_end datetime, @current_date datetime, @isQuote int = 0) RETURNS bit
AS
BEGIN
	IF @b_advance = 'Y'
	BEGIN
	   /* allows to create initial for ADVANCE */
		RETURN 1
	END

	IF @isQuote > 0
	BEGIN
	   /* disable to create initial for ARREARS in case of quote */
		RETURN 0
	END

	IF @current_date IS NULL
		SET @current_date = dbo.metratime(1,'RC')
		
	/* Creates Initial charges in case it fits inder current interval*/
	IF EXISTS (select 1 from t_usage_interval us_int
				join t_acc_usage_cycle acc
				on us_int.id_usage_cycle = acc.id_usage_cycle
				where acc.id_acc = @id_acc
				AND @current_date BETWEEN DT_START AND DT_END
				AND @sub_end BETWEEN DT_START AND DT_END)
				
		RETURN 1

	RETURN 0
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MeterUdrcFromRecurWindow]'
GO
ALTER PROCEDURE [dbo].[MeterUdrcFromRecurWindow]
  @currentDate DATETIME,
  @actionType NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @id_run INT
	declare @idMessage BIGINT
	DECLARE @idService INT
	DECLARE @numBlocks INT

  IF ((SELECT value FROM t_db_values WHERE parameter = N'InstantRc') = 'false') return;

  SELECT 
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)                                  AS c_RCIntervalSubscriptionStart,
         dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)                                      AS c_RCIntervalSubscriptionEnd,
         rw.c_SubscriptionStart                                                                     AS c_SubscriptionStart,
         rw.c_SubscriptionEnd                                                                       AS c_SubscriptionEnd,        
         dbo.MTMinOfTwoDates(pci.dt_end, rw.c_SubscriptionEnd)                                      AS c_BilledRateDate,
         rcr.n_rating_type                                                                          AS c_RatingType,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,         
         CASE WHEN rcr.b_prorate_on_activate = 'Y' THEN '1' ELSE '0' END                            AS c_ProrateOnSubscription,
         CASE WHEN rcr.b_prorate_instantly = 'Y' THEN '1' ELSE '0' END                              AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         CASE WHEN rcr.b_prorate_on_deactivate = 'Y' THEN '1' ELSE '0' END                          AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,         
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__payingaccount                                                                        AS c__PayingAccount,
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         trv.vt_start                                                                               AS c_UnitValueStart,
         trv.vt_end                                                                                 AS c_UnitValueEnd,
         trv.n_value                                                                                AS c_UnitValue,
         currentui.id_interval                                                                      AS c__IntervalID,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         sub.tx_quoting_batch                                                                       as c__QuoteBatchId
        INTO #tmp_udrc_1
  FROM   t_usage_interval ui
         INNER JOIN #recur_window_holder rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND rw.c_SubscriptionStart   < ui.dt_end AND rw.c_SubscriptionEnd   > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
         INNER JOIN #tmp_changed_units trv ON trv.id_sub = rw.C__SubscriptionID AND trv.id_prop = rw.c__PriceableItemInstanceID
              AND trv.vt_start < rw.c_UnitValueEnd AND trv.vt_end > rw.c_UnitValueStart
         INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER LOOP JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
         INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
              AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON rw.c_SubscriptionStart BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
  WHERE 
        /* Only issue corrections if there's a previous iteration. */
        EXISTS (SELECT 1 FROM t_recur_value rv WHERE rv.id_sub = rw.c__SubscriptionID AND rv.tt_end < dbo.MTMaxDate())
        /* Meter only in 1-st billing interval */
        AND ui.dt_start <= rw.c_SubscriptionStart
        AND ui.dt_start < @currentDate
        AND rw.c__IsAllowGenChargeByTrigger = 1; 

  SELECT @actionType AS c_RCActionType,
         c_RCIntervalStart,
         c_RCIntervalEnd,
         c_BillingIntervalStart,
         c_BillingIntervalEnd,
         c_RCIntervalSubscriptionStart,
         c_RCIntervalSubscriptionEnd,
         c_SubscriptionStart,
         c_SubscriptionEnd,
         c_Advance,
         c_ProrateOnSubscription,
         'N' AS c_ProrateInstantly,
         c_UnitValueStart,
         c_UnitValueEnd,
         c_UnitValue,
         c_RatingType,
         c_ProrateOnUnsubscription,
         c_ProrationCycleLength,
         c_BilledRateDate,
         c__SubscriptionID,
         c__AccountID,
         c__PayingAccount,
         c__PriceableItemInstanceID,
         c__PriceableItemTemplateID,
         c__ProductOfferingID,
         c__IntervalID,
         NEWID() AS idSourceSess,
         c__QuoteBatchId INTO #tmp_rc
  FROM   #tmp_udrc_1;

  /* If no charges to meter, return immediately */
  IF (NOT EXISTS (SELECT 1 FROM #tmp_rc)) RETURN;

  EXEC InsertChargesIntoSvcTables;

  IF (@actionType = 'DebitCorrection')
  BEGIN
    MERGE
    INTO    #recur_window_holder trw
    USING   (
              SELECT MAX(c_RCIntervalSubscriptionEnd) AS NewBilledThroughDate, c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
              FROM #tmp_rc
              GROUP BY c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
            ) trc
    ON      (
              trw.c__AccountID = trc.c__AccountID
              AND trw.c__SubscriptionID = trc.c__SubscriptionID
              AND trw.c__PriceableItemInstanceID = trc.c__PriceableItemInstanceID
              AND trw.c__PriceableItemTemplateID = trc.c__PriceableItemTemplateID
              AND trw.c__ProductOfferingID = trc.c__ProductOfferingID
              AND trw.c__IsAllowGenChargeByTrigger = 1
            )
    WHEN MATCHED THEN
    UPDATE
    SET     trw.c_BilledThroughDate = trc.NewBilledThroughDate;
  END;

 END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MeterPayerChangesFromRecurWindow]'
GO
ALTER  PROCEDURE [dbo].[MeterPayerChangesFromRecurWindow]
@currentDate datetime
AS
BEGIN
  SET NOCOUNT ON;

  IF ((SELECT value FROM t_db_values WHERE parameter = N'InstantRc') = 'false') RETURN;

  SELECT
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,         
         dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)                                  AS c_RCIntervalSubscriptionStart,
         dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)                                      AS c_RCIntervalSubscriptionEnd,
         rw.c_SubscriptionStart                                                                     AS c_SubscriptionStart,
         rw.c_SubscriptionEnd                                                                       AS c_SubscriptionEnd,
         dbo.MTMinOfTwoDates(pci.dt_end, rw.c_SubscriptionEnd)                                      AS c_BilledRateDate,
         rcr.n_rating_type                                                                          AS c_RatingType,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,
         CASE WHEN rcr.b_prorate_on_activate = 'Y' THEN '1' ELSE '0' END                            AS c_ProrateOnSubscription,
         CASE WHEN rcr.b_prorate_instantly = 'Y' THEN '1' ELSE '0' END                              AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         CASE WHEN rcr.b_prorate_on_deactivate = 'Y' THEN '1' ELSE '0' END                          AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__payingaccount                                                                        AS c__PayingAccount,         
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         currentui.id_interval                                                                      AS c__IntervalID,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID
      ,sub.tx_quoting_batch  as c__QuoteBatchId
    INTO #tmp_rc_1      
  FROM   t_usage_interval ui
         INNER JOIN #recur_window_holder rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
           AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend > ui.dt_start /* next interval overlaps with membership */
              AND rw.c_SubscriptionStart   < ui.dt_end AND rw.c_SubscriptionEnd   > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
         INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER LOOP JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
	    WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle 
	    WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
                                            ELSE NULL
                                       END
         INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
         INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON rw.c_SubscriptionStart BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
  WHERE
         ui.dt_start <= rw.c_SubscriptionStart
         AND ui.dt_start < @currentDate
         AND rw.c__IsAllowGenChargeByTrigger = 1;

  SELECT 'InitialDebit' AS c_RCActionType,
         c_RCIntervalStart,
         c_RCIntervalEnd,
         c_BillingIntervalStart,
         c_BillingIntervalEnd,
         c_RCIntervalSubscriptionStart,
         c_RCIntervalSubscriptionEnd,
         c_SubscriptionStart,
         c_SubscriptionEnd,
         c_Advance,
         c_ProrateOnSubscription,
         c_ProrateInstantly,
         c_UnitValueStart,
         c_UnitValueEnd,
         c_UnitValue,
         c_RatingType,
         c_ProrateOnUnsubscription,
         c_ProrationCycleLength,
         c_BilledRateDate,
         c__SubscriptionID,
         c__AccountID,
         c__PayingAccount,
         c__PriceableItemInstanceID,
         c__PriceableItemTemplateID,
         c__ProductOfferingID,
         c__IntervalID,
         NEWID() AS idSourceSess,
         c__QuoteBatchId
         INTO #tmp_rc
  FROM   #tmp_rc_1 
  UNION ALL
  SELECT 'InitialCredit' AS c_RCActionType,
         tmp.c_RCIntervalStart,
         tmp.c_RCIntervalEnd,
         tmp.c_BillingIntervalStart,
         tmp.c_BillingIntervalEnd,
         tmp.c_RCIntervalSubscriptionStart,
         tmp.c_RCIntervalSubscriptionEnd,
         tmp.c_SubscriptionStart,
         tmp.c_SubscriptionEnd,
         tmp.c_Advance,
         tmp.c_ProrateOnSubscription,
         tmp.c_ProrateInstantly,
         tmp.c_UnitValueStart,
         tmp.c_UnitValueEnd,
         tmp.c_UnitValue,
         tmp.c_RatingType,
         tmp.c_ProrateOnUnsubscription,
         tmp.c_ProrationCycleLength,
         tmp.c_BilledRateDate,
         tmp.c__SubscriptionID,
         tmp.c__AccountID,
         rwold.c__PayingAccount,
         tmp.c__PriceableItemInstanceID,
         tmp.c__PriceableItemTemplateID,
         tmp.c__ProductOfferingID,
         tmp.c__IntervalID,
         NEWID() AS idSourceSess,
         tmp.c__QuoteBatchId
  FROM   #tmp_rc_1 tmp
        JOIN #tmp_oldrw rwold
          ON tmp.c__SubscriptionID = rwold.c__SubscriptionID
          AND tmp.c__PriceableItemInstanceID = rwold.c__PriceableItemInstanceID
          AND tmp.c__PriceableItemTemplateID = rwold.c__PriceableItemTemplateID;

  /* If no charges to meter, return immediately */
  IF NOT EXISTS (SELECT 1 FROM #tmp_rc) RETURN;

  EXEC InsertChargesIntoSvcTables;

  MERGE
  INTO    #recur_window_holder trw
  USING   (
            SELECT MAX(c_RCIntervalSubscriptionEnd) AS NewBilledThroughDate, c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
            FROM #tmp_rc
            WHERE c_RCActionType = 'InitialDebit'
            GROUP BY c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
          ) trc
  ON      (
            trw.c__AccountID = trc.c__AccountID
            AND trw.c__SubscriptionID = trc.c__SubscriptionID
            AND trw.c__PriceableItemInstanceID = trc.c__PriceableItemInstanceID
            AND trw.c__PriceableItemTemplateID = trc.c__PriceableItemTemplateID
            AND trw.c__ProductOfferingID = trc.c__ProductOfferingID
            AND trw.c__IsAllowGenChargeByTrigger = 1
          )
  WHEN MATCHED THEN
  UPDATE
  SET     trw.c_BilledThroughDate = trc.NewBilledThroughDate;

END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[t_vw_expanded_sub]'
GO
EXEC sp_refreshview N'[dbo].[t_vw_expanded_sub]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[VW_AJ_INFO]'
GO
EXEC sp_refreshview N'[dbo].[VW_AJ_INFO]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[t_vw_pilookup]'
GO
EXEC sp_refreshview N'[dbo].[t_vw_pilookup]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[t_vw_rc_arrears_fixed]'
GO
EXEC sp_refreshview N'[dbo].[t_vw_rc_arrears_fixed]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[vw_all_billing_groups_status]'
GO
EXEC sp_refreshview N'[dbo].[vw_all_billing_groups_status]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[t_vw_rc_arrears_relative]'
GO
EXEC sp_refreshview N'[dbo].[t_vw_rc_arrears_relative]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[vw_interval_billgroup_counts]'
GO
EXEC sp_refreshview N'[dbo].[vw_interval_billgroup_counts]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[T_VW_ACCTRES_BYID]'
GO
EXEC sp_refreshview N'[dbo].[T_VW_ACCTRES_BYID]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[vw_paying_accounts]'
GO
EXEC sp_refreshview N'[dbo].[vw_paying_accounts]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[vw_unassigned_accounts]'
GO
EXEC sp_refreshview N'[dbo].[vw_unassigned_accounts]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[MTSP_GENERATE_CHARGES_QUOTING]'
GO
ALTER PROCEDURE [dbo].[MTSP_GENERATE_CHARGES_QUOTING]
	@v_id_interval  int
	,@v_id_billgroup int
	,@v_id_run       int
	,@v_id_accounts VARCHAR(4000)
	,@v_id_poid VARCHAR(4000)
	,@v_id_batch     varchar(256)
	,@v_n_batch_size int
	,@v_run_date   datetime
	,@v_is_group_sub int
	,@dt_start datetime
	,@dt_end datetime,
	@p_count int OUTPUT

AS BEGIN

DECLARE @id_nonrec int,
		@n_batches  int,
		@total_nrcs int,
		@id_message bigint,
		@id_ss int,
		@tx_batch binary(16),
		@total_rcs  int,
        @total_flat int,
        @total_udrc int,
        @id_flat    int,
        @id_udrc    int
        
IF OBJECT_ID('tempdb..#TMP_RC_ACCOUNTS_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_RC_ACCOUNTS_FOR_RUN

IF OBJECT_ID('tempdb..#TMP_RC_POID_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_RC_POID_FOR_RUN

IF OBJECT_ID('tempdb..#TMP_NRC') IS NOT NULL
DROP TABLE #TMP_NRC

IF OBJECT_ID('tempdb..#TMP_RC') IS NOT NULL
DROP TABLE #TMP_RC

CREATE TABLE #TMP_NRC
  (
  id_source_sess uniqueidentifier,
  c_NRCEventType int,
  c_NRCIntervalStart datetime,
  c_NRCIntervalEnd datetime,
  c_NRCIntervalSubscriptionStart datetime,
  c_NRCIntervalSubscriptionEnd datetime,
  c__AccountID int,
  c__PriceableItemInstanceID int,
  c__PriceableItemTemplateID int,
  c__ProductOfferingID int,
  c__SubscriptionID int,
  c__IntervalID int,
  c__Resubmit int,
  c__TransactionCookie int,
  c__CollectionID binary (16)
  )


SELECT * INTO #TMP_RC_ACCOUNTS_FOR_RUN FROM(SELECT value as id_acc FROM CSVToInt(@v_id_accounts)) A;
SELECT * INTO #TMP_RC_POID_FOR_RUN FROM(SELECT value as id_po FROM CSVToInt(@v_id_poid)) A;

SELECT @tx_batch = cast(N'' as xml).value('xs:hexBinary(sql:variable("@v_id_batch"))', 'binary(16)');

SELECT
*
INTO
#TMP_RC
FROM(
SELECT
newid() AS idSourceSess,
      'Arrears' AS c_RCActionType
      ,pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)          AS c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
      ,case when rcr.b_prorate_on_deactivate ='Y' then '1' else '0' end       AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccount
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,pci.dt_end      AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
	  ,rw.c_payerstart
	  ,rw.c_payerend
	  ,case when rw.c_unitvaluestart < '1970-01-01 00:00:00'
      THEN '1970-01-01 00:00:00'
      ELSE rw.c_unitvaluestart END AS c_unitvaluestart
	  ,rw.c_unitvalueend
	  ,rw.c_unitvalue
	  ,rcr.n_rating_type AS c_RatingType
      FROM t_usage_interval ui
      /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
	  LEFT JOIN #TMP_RC_ACCOUNTS_FOR_RUN bgm ON 1=1
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount
                                   AND rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* interval overlaps with cycle */
                                   AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < ui.dt_end AND rw.c_subscriptionend   > ui.dt_start /* interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* interval overlaps with UDRC */
      INNER JOIN #TMP_RC_POID_FOR_RUN po on po.id_po = rw.c__ProductOfferingID
      INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER LOOP JOIN t_usage_cycle ccl
          ON ccl.id_usage_cycle = CASE
                                        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
                                        WHEN rcr.tx_cycle_mode LIKE 'BCR%' THEN ui.id_usage_cycle
                                        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
            ELSE NULL
                                  END
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_end BETWEEN ui.dt_start        AND ui.dt_end                             /* rc end falls in this interval */
                                   AND pci.dt_end BETWEEN rw.c_payerstart    AND rw.c_payerend                         /* rc end goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      	  
      where 1=1
      and ui.id_interval = @v_id_interval
      /*and bg.id_billgroup = @v_id_billgroup*/
      and rcr.b_advance <> 'Y'
UNION ALL
SELECT
newid() AS idSourceSess,
      'Advance' AS c_RCActionType
      ,pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate
       THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start)
       ELSE pci.dt_start END as c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
      ,case when rcr.b_prorate_on_deactivate ='Y' then '1' else '0' end       AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccount
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,pci.dt_start      AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
	  ,rw.c_payerstart
	  ,rw.c_payerend
	  ,case when rw.c_unitvaluestart < '1970-01-01 00:00:00' THEN '1970-01-01 00:00:00' ELSE rw.c_unitvaluestart END AS c_unitvaluestart
	  ,rw.c_unitvalueend
	  ,rw.c_unitvalue
	  ,rcr.n_rating_type AS c_RatingType
     FROM t_usage_interval ui
      INNER LOOP JOIN t_usage_interval nui ON ui.id_usage_cycle = nui.id_usage_cycle AND dbo.AddSecond(ui.dt_end) = nui.dt_start
      /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
	  LEFT JOIN #TMP_RC_ACCOUNTS_FOR_RUN bgm ON 1=1
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount
                                   AND rw.c_payerstart          < nui.dt_end AND rw.c_payerend          > nui.dt_start /* next interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < nui.dt_end AND rw.c_cycleeffectiveend > nui.dt_start /* next interval overlaps with cycle */
                                   AND rw.c_membershipstart     < nui.dt_end AND rw.c_membershipend     > nui.dt_start /* next interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < nui.dt_end AND rw.c_subscriptionend   > nui.dt_start /* next interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < nui.dt_end AND rw.c_unitvalueend      > nui.dt_start /* next interval overlaps with UDRC */
      INNER JOIN #TMP_RC_POID_FOR_RUN po on po.id_po = rw.c__ProductOfferingID
	  INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle WHEN rcr.tx_cycle_mode LIKE 'BCR%' THEN ui.id_usage_cycle WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) ELSE NULL END
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_start BETWEEN nui.dt_start     AND nui.dt_end                            /* rc start falls in this interval */
                                   AND pci.dt_start BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      where 1=1
      and ui.id_interval = @v_id_interval
      /*and bg.id_billgroup = @v_id_billgroup*/
      and rcr.b_advance = 'Y'
)A      ;

SELECT @total_rcs  = COUNT(1) FROM #tmp_rc;


IF @v_is_group_sub > 0
BEGIN

	INSERT INTO #TMP_NRC
	(
		id_source_sess,
		c_NRCEventType,
		c_NRCIntervalStart,
		c_NRCIntervalEnd,
		c_NRCIntervalSubscriptionStart,
		c_NRCIntervalSubscriptionEnd,
		c__AccountID,
		c__PriceableItemInstanceID,
		c__PriceableItemTemplateID,
		c__ProductOfferingID,
		c__SubscriptionID,
		c__IntervalID,
		c__Resubmit,
		c__TransactionCookie,
		c__CollectionID
	)
	
	SELECT
			newid() AS id_source_sess,
			nrc.n_event_type AS	c_NRCEventType,
			@dt_start AS c_NRCIntervalStart,
			@dt_end AS 	c_NRCIntervalEnd,
			mem.vt_start AS	c_NRCIntervalSubscriptionStart,
			mem.vt_end AS	c_NRCIntervalSubscriptionEnd,
			mem.id_acc AS	c__AccountID,
			plm.id_pi_instance AS	c__PriceableItemInstanceID,
			plm.id_pi_template AS	c__PriceableItemTemplateID,
			sub.id_po AS c__ProductOfferingID,
			sub.id_sub AS	c__SubscriptionID,
			@v_id_interval AS c__IntervalID,
			'0' AS c__Resubmit,
			NULL AS c__TransactionCookie,
			@tx_batch AS c__CollectionID
	FROM	t_sub sub
			inner join t_gsubmember mem on mem.id_group = sub.id_group
			inner join #TMP_RC_ACCOUNTS_FOR_RUN acc on acc.id_acc = mem.id_acc
			inner join #TMP_RC_POID_FOR_RUN po on po.id_po = sub.id_po
			inner join t_po on sub.id_po = t_po.id_po
			inner join t_pl_map plm on sub.id_po = plm.id_po and plm.id_paramtable IS NULL
			inner join t_base_props bp on bp.id_prop = plm.id_pi_instance and bp.n_kind = 30
			inner join t_nonrecur nrc on nrc.id_prop = bp.id_prop and nrc.n_event_type = 1
	;

END
ELSE
BEGIN

	INSERT INTO #TMP_NRC
	(
		id_source_sess,
		c_NRCEventType,
		c_NRCIntervalStart,
		c_NRCIntervalEnd,
		c_NRCIntervalSubscriptionStart,
		c_NRCIntervalSubscriptionEnd,
		c__AccountID,
		c__PriceableItemInstanceID,
		c__PriceableItemTemplateID,
		c__ProductOfferingID,
		c__SubscriptionID,
		c__IntervalID,
		c__Resubmit,
		c__TransactionCookie,
		c__CollectionID
	)
	SELECT
			newid() AS id_source_sess,
			nrc.n_event_type AS	c_NRCEventType,
			@dt_start AS c_NRCIntervalStart,
			@dt_end AS 	c_NRCIntervalEnd,
			sub.vt_start AS	c_NRCIntervalSubscriptionStart,
			sub.vt_end AS	c_NRCIntervalSubscriptionEnd,
			sub.id_acc AS	c__AccountID,
			plm.id_pi_instance AS	c__PriceableItemInstanceID,
			plm.id_pi_template AS	c__PriceableItemTemplateID,
			sub.id_po AS c__ProductOfferingID,
			sub.id_sub AS	c__SubscriptionID,
			@v_id_interval AS c__IntervalID,
			'0' AS c__Resubmit,
			NULL AS c__TransactionCookie,
			@tx_batch AS c__CollectionID
	FROM	t_sub sub
			inner join #TMP_RC_ACCOUNTS_FOR_RUN acc on acc.id_acc = sub.id_acc
			inner join #TMP_RC_POID_FOR_RUN po on po.id_po = sub.id_po
			inner join t_po on sub.id_po = t_po.id_po
			inner join t_pl_map plm on sub.id_po = plm.id_po and plm.id_paramtable IS NULL
			inner join t_base_props bp on bp.id_prop = plm.id_pi_instance and bp.n_kind = 30
			inner join t_nonrecur nrc on nrc.id_prop = bp.id_prop and nrc.n_event_type = 1
	;

END

SELECT @total_nrcs = count(1) from #tmp_nrc;

if @total_rcs > 0
BEGIN

SELECT @total_flat = COUNT(1) FROM #tmp_rc where c_unitvalue is null;
SELECT @total_udrc = COUNT(1) FROM #tmp_rc where c_unitvalue is not null;

if @total_flat > 0
begin

    
set @id_flat = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/flatrecurringcharge');
    
SET @n_batches = (@total_flat / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc where c_unitvalue is null;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_flat AS id_svc,
    1 AS b_root
FROM #tmp_rc
 where c_unitvalue is null) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;
 
INSERT INTO t_svc_FlatRecurringCharge
(id_source_sess
    ,id_parent_source_sess
    ,id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
    ,c_ProrateInstantly
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,c__IntervalID
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID)
SELECT
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
    ,c_ProrateInstantly
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
FROM #tmp_rc
 where c_unitvalue is null;
          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NULL
              ) a
            GROUP BY a.id_message;

END;
if @total_udrc > 0
begin

set @id_udrc = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/udrecurringcharge');
    
SET @n_batches = (@total_udrc / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc where c_unitvalue is not null;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_udrc AS id_svc,
    1 AS b_root
FROM #tmp_rc
 where c_unitvalue is not null) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;
 
INSERT INTO t_svc_UDRecurringCharge
(id_source_sess, id_parent_source_sess, id_external, c_RCActionType, c_RCIntervalStart,c_RCIntervalEnd,c_BillingIntervalStart,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,c__IntervalID
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID
	,c_unitvaluestart
	,c_unitvalueend
	,c_unitvalue
	,c_ratingtype)
SELECT
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
	,c_unitvaluestart
	,c_unitvalueend
	,c_unitvalue
	,c_ratingtype
FROM #tmp_rc
 where c_unitvalue is not null;

          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NOT NULL
              ) a
            GROUP BY a.id_message;
END;
 
 END;

if @total_nrcs > 0
BEGIN
set @id_nonrec = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/nonrecurringcharge');

SET @n_batches = (@total_nrcs / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_ss,
    id_source_sess
FROM #tmp_nrc
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, @id_nonrec, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_ss,
    1 AS b_root
FROM #tmp_nrc) a
GROUP BY a.id_message, a.id_ss, a.b_root;
 
INSERT INTO t_svc_NonRecurringCharge
(
	id_source_sess,
    id_parent_source_sess,
    id_external,
    c_NRCEventType,
	c_NRCIntervalStart,
	c_NRCIntervalEnd,
	c_NRCIntervalSubscriptionStart,
	c_NRCIntervalSubscriptionEnd,
	c__AccountID,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c__SubscriptionID,
    c__IntervalID,
    c__Resubmit,
    c__TransactionCookie,
    c__CollectionID
)
SELECT
    id_source_sess,
    NULL AS id_parent_source_sess,
    NULL AS id_external,
	c_NRCEventType,
	c_NRCIntervalStart,
	c_NRCIntervalEnd,
	c_NRCIntervalSubscriptionStart,
	c_NRCIntervalSubscriptionEnd,
	c__AccountID,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c__SubscriptionID,
    c__IntervalID,
    c__Resubmit,
    c__TransactionCookie,
    c__CollectionID
FROM #tmp_nrc

INSERT 	INTO t_message
(
	id_message,
	id_route,
	dt_crt,
	dt_metered,
	dt_assigned,
	id_listener,
	id_pipeline,
	dt_completed,
	id_feedback,
	tx_TransactionID,
	tx_sc_username,
	tx_sc_password,
	tx_sc_namespace,
	tx_sc_serialized,
	tx_ip_address
)
SELECT
	id_message,
	NULL,
	@v_run_date,
	@v_run_date,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	'127.0.0.1'
FROM
	(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_message
	FROM #tmp_nrc
	) a
GROUP BY a.id_message;

drop table #tmp_nrc
END

SET @p_count = @total_rcs + @total_nrcs
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[VW_ADJUSTMENT_DETAILS]'
GO
EXEC sp_refreshview N'[dbo].[VW_ADJUSTMENT_DETAILS]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[VW_NOTDELETED_ADJ_DETAILS]'
GO
EXEC sp_refreshview N'[dbo].[VW_NOTDELETED_ADJ_DETAILS]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[CreateGroupSubscription]'
GO
ALTER procedure CreateGroupSubscription(
@p_sub_GUID varbinary(16),
@p_group_GUID varbinary(16),
@p_name  nvarchar(255),
@p_desc nvarchar(255),
@p_usage_cycle int,
@p_startdate datetime,
@p_enddate datetime,
@p_id_po int,
@p_proportional varchar,
@p_supportgroupops varchar,
@p_discountaccount int,
@p_CorporateAccount int,
@p_systemdate datetime,
@p_enforce_same_corporation varchar,
@p_allow_acc_po_curr_mismatch int = 0,
@p_id_sub int,
@p_quoting_batch_id     varchar(256),
@p_id_group int OUTPUT,
@p_status int OUTPUT,
@p_datemodified varchar OUTPUT
)
as
begin
declare @existingPO as int
declare @realenddate as datetime
declare @varMaxDateTime as datetime
select @p_datemodified = 'N'
 -- business rule checks
select @varMaxDateTime = dbo.MTMaxDate()
select @p_status = 0
exec CheckGroupSubBusinessRules @p_name,@p_desc,@p_startdate,@p_enddate,@p_id_po,@p_proportional,
@p_discountaccount,@p_CorporateAccount,NULL,@p_usage_cycle,@p_systemdate, @p_enforce_same_corporation, @p_allow_acc_po_curr_mismatch, @p_status OUTPUT
if (@p_status <> 1)
	begin
	return
	end
	-- set the end date to max date if it is not specified
if (@p_enddate is null)
	begin
	select @realenddate = @varMaxDateTime
	end
else
	begin
	select @realenddate = @p_enddate
	end
	insert into t_group_sub (id_group_ext,tx_name,tx_desc,b_visable,b_supportgroupops,
	id_usage_cycle,b_proportional,id_discountAccount,id_corporate_account)
	select @p_group_GUID,@p_name,@p_desc,'N',@p_supportgroupops,@p_usage_cycle,
	@p_proportional,@p_discountaccount,@p_CorporateAccount
	-- group subscription ID
	select @p_id_group =@@identity
 -- add group entry
   exec AddSubscriptionBase
      NULL,
      @p_id_group,
      @p_id_po,
      @p_startdate,
      @p_enddate,
      @p_group_GUID,
      @p_systemdate,
      @p_id_sub,
      @p_status output,
      @p_datemodified output,
      0,
      0,
      @p_quoting_batch_id
end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering trigger [dbo].[trig_update_recur_window_on_t_gsub_recur_map] on [dbo].[t_gsub_recur_map]'
GO
ALTER trigger dbo.trig_update_recur_window_on_t_gsub_recur_map
ON dbo.t_gsub_recur_map
for insert, UPDATE, delete
as
begin
declare @temp                         datetime,
        @num_notnull_quote_batchids   INT

delete from t_recur_window where exists (
    select 1 from deleted gsrm
      join t_sub sub on gsrm.id_group = sub.id_group
	  join t_pl_map plm on sub.id_po = plm.id_po
		  and t_recur_window.c__PriceableItemInstanceID = plm.id_pi_instance and t_recur_window.c__PriceableItemTemplateID = plm.id_pi_template
         and t_recur_window.c__SubscriptionID = sub.id_sub
         and t_recur_window.c__AccountID = gsrm.id_acc
		  and t_recur_window.c__PriceableItemInstanceID = gsrm.id_prop);

  MERGE into t_recur_window USING (
    select distinct sub.id_sub, gsrm.id_acc, gsrm.vt_start, gsrm.vt_end
      FROM
       INSERTED gsrm inner join t_recur_window trw on
         trw.c__AccountID = gsrm.id_acc
         inner join t_sub sub on sub.id_group = gsrm.id_group
            and trw.c__SubscriptionID = sub.id_sub) AS source
     ON (t_recur_window.c__SubscriptionID = source.id_sub
       and t_recur_window.c__AccountID = source.id_acc)
   WHEN matched AND t_recur_window.c__AccountID = source.id_acc THEN
	UPDATE SET c_MembershipStart = source.vt_start,
	           c_MembershipEnd = source.vt_end;
			   
	select @temp = tt_start from inserted;
	 
   SELECT @num_notnull_quote_batchids = count(1)
    FROM inserted gsrm
      join t_sub sub on gsrm.id_group = sub.id_group
    WHERE tx_quoting_batch is not null
      AND tx_quoting_batch!=0x00000000000000000000000000000000;
			   
  SELECT
       sub.vt_start AS c_CycleEffectiveDate
      ,sub.vt_start AS c_CycleEffectiveStart
      ,sub.vt_end AS c_CycleEffectiveEnd
      ,sub.vt_start          AS c_SubscriptionStart
      ,sub.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , @temp as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , grm.vt_start AS c_MembershipStart
      , grm.vt_end AS c_MembershipEnd
      , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, sub.dt_crt, @num_notnull_quote_batchids) AS c__IsAllowGenChargeByTrigger
	  into #recur_window_holder
FROM inserted grm
      /* TODO: GRM dates or sub dates or both for filtering */
      INNER JOIN t_sub sub ON grm.id_group = sub.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = grm.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL and plm.id_sub is null and plm.id_pi_instance = grm.id_prop
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub
        AND rv.tt_end = dbo.MTMaxDate()
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE
		not EXISTS
	        (SELECT 1 FROM T_RECUR_WINDOW where c__AccountID = grm.id_acc
	          	AND c__SubscriptionID = sub.id_sub
				AND c__priceableiteminstanceid = grm.id_prop
				AND c__priceableitemtemplateid = plm.id_pi_template
			)
	      AND grm.tt_end = dbo.mtmaxdate()
	      AND rcr.b_charge_per_participant = 'N'
	      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);
      
    
	/* adds charges to METER tables */
	EXEC MeterInitialFromRecurWindow @currentDate = @temp;
    EXEC MeterCreditFromRecurWindow @currentDate = @temp;
	 
	INSERT INTO t_recur_window
	SELECT c_CycleEffectiveDate,
	c_CycleEffectiveStart,
	c_CycleEffectiveEnd,
	c_SubscriptionStart,
	c_SubscriptionEnd,
	c_Advance,
	c__AccountID,
	c__PayingAccount,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c_PayerStart,
	c_PayerEnd,
	c__SubscriptionID,
	c_UnitValueStart,
	c_UnitValueEnd,
	c_UnitValue,
	c_BilledThroughDate,
	c_LastIdRun,
	c_MembershipStart,
	c_MembershipEnd
	FROM #recur_window_holder;
	
/* step 2) update the cycle effective windows */
UPDATE t_recur_window
 SET c_CycleEffectiveEnd =
 (
  SELECT MIN(IsNull(c_CycleEffectiveDate,c_SubscriptionEnd)) FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate
 )
 WHERE 1=1
 AND EXISTS
(SELECT 1 FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId
    AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate)
;
END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering trigger [dbo].[trig_update_recur_window_on_t_gsubmember] on [dbo].[t_gsubmember]'
GO
ALTER trigger trig_update_recur_window_on_t_gsubmember
ON t_gsubmember
for insert, UPDATE, delete
as
begin
declare @startDate                    datetime,
        @num_notnull_quote_batchids   INT
        
delete from t_recur_window where exists (
  select 1 from deleted gsm
         join t_sub sub on gsm.id_group = sub.id_group and
         t_recur_window.c__SubscriptionID = sub.id_sub and t_recur_window.c__AccountID = gsm.id_acc
	    join t_pl_map plm on sub.id_po = plm.id_po
		  and t_recur_window.c__PriceableItemInstanceID = plm.id_pi_instance and t_recur_window.c__PriceableItemTemplateID = plm.id_pi_template
INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
AND rcr.b_charge_per_participant = 'Y');
         
         
MERGE into t_recur_window USING (
	select distinct sub.id_sub, gsubmember.id_acc, gsubmember.vt_start, gsubmember.vt_end, plm.id_pi_template, plm.id_pi_instance
	FROM
       INSERTED gsubmember inner join t_recur_window trw on
         trw.c__AccountID = gsubmember.id_acc
         inner join t_sub sub on sub.id_group = gsubmember.id_group
            and trw.c__SubscriptionID = sub.id_sub
         inner join t_pl_map plm on sub.id_po = plm.id_po
            and plm.id_sub = null and plm.id_paramtable = null
			) AS source
     ON (t_recur_window.c__SubscriptionID = source.id_sub
     and t_recur_window.c__AccountID = source.id_acc)
WHEN matched AND t_recur_window.c__SubscriptionID = source.id_sub
    AND t_recur_window.c__AccountID = source.id_acc
    and t_recur_window.c__PriceableItemInstanceID = source.id_pi_instance
    AND t_recur_window.c__PriceableItemTemplateID = source.id_pi_template	THEN
	UPDATE SET c_MembershipStart = source.vt_start,
	           c_MembershipEnd = source.vt_end;
	
	
	SET @startDate = dbo.metratime(1,'RC');
  
   SELECT @num_notnull_quote_batchids = count(1)
    FROM inserted gsm
         join t_sub sub on gsm.id_group = sub.id_group
    WHERE tx_quoting_batch is not null
      AND tx_quoting_batch!=0x00000000000000000000000000000000;
			   
	SELECT
       gsm.vt_start AS c_CycleEffectiveDate
      ,gsm.vt_start AS c_CycleEffectiveStart
      ,gsm.vt_end AS c_CycleEffectiveEnd
      ,gsm.vt_start          AS c_SubscriptionStart
      ,gsm.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , @startDate as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd
      , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, @startDate, @num_notnull_quote_batchids) AS c__IsAllowGenChargeByTrigger
	INTO #recur_window_holder
    FROM INSERTED gsm
      INNER JOIN t_sub sub ON sub.id_group = gsm.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start AND pay.vt_start < gsm.vt_end AND pay.vt_end > gsm.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate() AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start AND rv.vt_start < gsm.vt_end AND rv.vt_end > gsm.vt_start
      WHERE
		not EXISTS
        (SELECT 1 FROM T_RECUR_WINDOW where c__AccountID = gsm.id_acc
          AND c__SubscriptionID = sub.id_sub
		  and c__PriceableItemInstanceID = plm.id_pi_instance
		  and c__PriceableItemTemplateID = plm.id_pi_template)
      AND rcr.b_charge_per_participant = 'Y'
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);
	
	/* adds charges to METER tables */
    EXEC MeterInitialFromRecurWindow @currentDate = @startDate;
    EXEC MeterCreditFromRecurWindow @currentDate = @startDate;
	  
	INSERT INTO t_recur_window
	SELECT c_CycleEffectiveDate,
	c_CycleEffectiveStart,
	c_CycleEffectiveEnd,
	c_SubscriptionStart,
	c_SubscriptionEnd,
	c_Advance,
	c__AccountID,
	c__PayingAccount,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c_PayerStart,
	c_PayerEnd,
	c__SubscriptionID,
	c_UnitValueStart,
	c_UnitValueEnd,
	c_UnitValue,
	c_BilledThroughDate,
	c_LastIdRun,
	c_MembershipStart,
	c_MembershipEnd
	FROM #recur_window_holder;
	
/* step 2) update the cycle effective windows */

/* sql */
UPDATE t_recur_window
 SET c_CycleEffectiveEnd =
 (
  SELECT MIN(IsNull(c_CycleEffectiveDate,c_SubscriptionEnd)) FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate
 )
 WHERE EXISTS
(SELECT 1 FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId
    AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate)
;
END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering trigger [dbo].[trig_update_t_recur_window_with_t_payment_redirection] on [dbo].[t_payment_redirection]'
GO
ALTER trigger [dbo].[trig_update_t_recur_window_with_t_payment_redirection]
ON [dbo].[t_payment_redirection]
/* We don't want to trigger on delete, because the insert comes right after a delete, and we can get the info that was deleted
  from payment_redir_history*/
for insert
as 
begin
--Grab everything that was changed
--Get the old vt_start and vt_end for payees that have changed
select distinct redirold.id_payer, redirold.id_payee, redirold.vt_start, redirold.vt_end
  into #tmp_redir from inserted
  inner loop join t_payment_redir_history redirnew on redirnew.id_payee = inserted.id_payee 
       and redirnew.tt_end = dbo.MTMaxDate()
  inner loop join t_payment_redir_history redirold on redirnew.id_payee = redirold.id_payee 
       and redirold.tt_end  = dbo.subtractSecond(redirnew.tt_start);
    
--Get the old windows for payees that have changed
select *  into #tmp_oldrw from t_recur_window trw JOIN #tmp_redir ON trw.c__AccountID = #tmp_redir.id_payee
  AND trw.c_PayerStart = #tmp_redir.vt_start AND trw.c_PayerEnd = #tmp_redir.vt_end; 
 
DECLARE @currentDate DATETIME
SET @currentDate = dbo.metratime(1,'RC');
 
  SELECT orw.c_CycleEffectiveDate,
         orw.c_CycleEffectiveStart,
         orw.c_CycleEffectiveEnd,
         orw.c_SubscriptionStart,
         orw.c_SubscriptionEnd,
         orw.c_Advance,
         orw.c__AccountID,
         INSERTED.id_payer AS c__PayingAccount,
         orw.c__PriceableItemInstanceID,
         orw.c__PriceableItemTemplateID,
         orw.c__ProductOfferingID,
         INSERTED.vt_start AS c_PayerStart,
         INSERTED.vt_end AS c_PayerEnd,
         orw.c__SubscriptionID,
         orw.c_UnitValueStart,
         orw.c_UnitValueEnd,
         orw.c_UnitValue,
         orw.c_BilledThroughDate,
         orw.c_LastIdRun,
         orw.c_MembershipStart,
         orw.c_MembershipEnd,
         dbo.AllowInitialArrersCharge(orw.c_Advance, INSERTED.id_payer, orw.c_SubscriptionEnd, @currentDate, 0) AS c__IsAllowGenChargeByTrigger 
         INTO #recur_window_holder
  FROM   #tmp_oldrw orw
         JOIN INSERTED
              ON  orw.c__AccountId = INSERTED.id_payee;

exec MeterPayerChangesFromRecurWindow @currentDate;

delete FROM t_recur_window WHERE EXISTS (SELECT 1 FROM
 #tmp_oldrw orw where
   t_recur_window.c__PayingAccount = orw.c__PayingAccount
       and t_recur_window.c__ProductOfferingID = orw.c__ProductOfferingID
       and t_recur_window.c_PayerStart = orw.c_PayerStart
       and t_recur_window.c_PayerEnd = orw.c_PayerEnd
       and t_recur_window.c__SubscriptionID = orw.c__SubscriptionID
);	 
  
INSERT INTO t_recur_window    
	SELECT DISTINCT c_CycleEffectiveDate,
	c_CycleEffectiveStart,
	c_CycleEffectiveEnd,
	c_SubscriptionStart,
	c_SubscriptionEnd,
	c_Advance,
	c__AccountID,
	c__PayingAccount,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c_PayerStart,
	c_PayerEnd,
	c__SubscriptionID,
	c_UnitValueStart,
	c_UnitValueEnd,
	c_UnitValue,
	c_BilledThroughDate,
	c_LastIdRun,
	c_MembershipStart,
	c_MembershipEnd
	FROM #recur_window_holder;


UPDATE t_recur_window
SET c_CycleEffectiveEnd = 
 (
  SELECT MIN(IsNull(c_CycleEffectiveDate,c_SubscriptionEnd)) FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId AND t_recur_window.c_PayerStart = w2.c_PayerStart 
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd 
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart 
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd 
    AND t_recur_window.c_membershipstart = w2.c_membershipstart 
    AND t_recur_window.c_membershipend = w2.c_membershipend 
    AND t_recur_window.c__accountid = w2.c__accountid 
    AND t_recur_window.c__payingaccount = w2.c__payingaccount 
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate
)
WHERE 1=1
AND c__PayingAccount in (select c__PayingAccount from #recur_window_holder)
AND EXISTS 
(SELECT 1 FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId 
    AND t_recur_window.c_PayerStart = w2.c_PayerStart 
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd 
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart 
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd 
    AND t_recur_window.c_membershipstart = w2.c_membershipstart 
    AND t_recur_window.c_membershipend = w2.c_membershipend 
    AND t_recur_window.c__accountid = w2.c__accountid 
    AND t_recur_window.c__payingaccount = w2.c__payingaccount 
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate)
;
end
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering trigger [dbo].[trig_update_t_recur_window_with_recur_value] on [dbo].[t_recur_value]'
GO
ALTER TRIGGER trig_update_t_recur_window_with_recur_value
ON t_recur_value FOR INSERT, UPDATE, DELETE
AS
BEGIN
/* Notes:
Trigger is executed 7 times after each update of UDRC values.
5 first times INSERTED and DELETED tables are empty.
On 6 time we have update (INSERTED and DELETED have same number of rows)
On 7 time we have insert (INSERTED only have rows)
*/
  IF @@ROWCOUNT = 0 RETURN;

  DECLARE @startDate              datetime,
          @num_notnull_quote_batchids   INT
          
  SELECT @startDate = tt_start FROM inserted;

  SELECT *, 1 AS c__IsAllowGenChargeByTrigger INTO #recur_window_holder FROM t_recur_window WHERE 1=0;
  SELECT * INTO #tmp_changed_units FROM t_recur_value WHERE 1=0;

  IF EXISTS (SELECT * FROM DELETED)
  BEGIN
    INSERT INTO #tmp_changed_units SELECT * FROM DELETED;

    INSERT INTO #recur_window_holder
    SELECT *, 1 AS c__IsAllowGenChargeByTrigger
    FROM   t_recur_window
    WHERE  EXISTS
           (
               SELECT 1 FROM DELETED d
               WHERE  t_recur_window.c__SubscriptionID = d.id_sub
                      AND t_recur_window.c__PriceableItemInstanceID = d.id_prop
                      AND t_recur_window.c_UnitValueStart = d.vt_start
                      AND t_recur_window.c_UnitValueEnd = d.vt_end
           );

    UPDATE rw
    SET rw.c_SubscriptionStart = current_sub.vt_start,
        rw.c_SubscriptionEnd = current_sub.vt_end
    FROM #recur_window_holder rw
        INNER LOOP JOIN t_sub_history new_sub ON new_sub.id_acc = rw.c__AccountID
            AND new_sub.id_sub = rw.c__SubscriptionID
            AND new_sub.tt_end = dbo.MTMaxDate()
        INNER LOOP JOIN t_sub_history current_sub ON current_sub.id_acc = rw.c__AccountID
            AND current_sub.id_sub = rw.c__SubscriptionID
            AND current_sub.tt_end = dbo.SubtractSecond(new_sub.tt_start);

    DELETE
    FROM   t_recur_window
    WHERE  EXISTS
           (
               SELECT 1 FROM DELETED d
               WHERE  t_recur_window.c__SubscriptionID = d.id_sub
                      AND t_recur_window.c__PriceableItemInstanceID = d.id_prop
                      AND t_recur_window.c_UnitValueStart = d.vt_start
                      AND t_recur_window.c_UnitValueEnd = d.vt_end
           );

    EXEC MeterUdrcFromRecurWindow @currentDate = @startDate, @actionType = 'AdvanceCorrection';
    RETURN;
  END;
  
  INSERT INTO #tmp_changed_units SELECT * FROM INSERTED;
  
   SELECT @num_notnull_quote_batchids = count(1)
    FROM t_sub sub
      INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_changed_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate()
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
    WHERE tx_quoting_batch is not null
        AND tx_quoting_batch!=0x00000000000000000000000000000000;

		--SET @num_notnull_quote_batchids=0;
  
  INSERT INTO #recur_window_holder
  SELECT
       sub.vt_start AS c_CycleEffectiveDate
      ,sub.vt_start AS c_CycleEffectiveStart
      ,sub.vt_end AS c_CycleEffectiveEnd
      ,sub.vt_start          AS c_SubscriptionStart
      ,sub.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , dbo.mtmindate() as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd
      , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, @startDate, @num_notnull_quote_batchids) AS c__IsAllowGenChargeByTrigger
      FROM t_sub sub
      INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_changed_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate()
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE 1=1
      AND sub.id_group IS NULL
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)

UNION ALL
SELECT
       gsm.vt_start AS c_CycleEffectiveDate
      ,gsm.vt_start AS c_CycleEffectiveStart
      ,gsm.vt_end AS c_CycleEffectiveEnd
      ,gsm.vt_start          AS c_SubscriptionStart
      ,gsm.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , dbo.mtmindate() as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd
	  , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payee, gsm.vt_end, @startDate, @num_notnull_quote_batchids) AS c__IsAllowGenChargeByTrigger
      FROM t_gsubmember gsm
      INNER JOIN t_sub sub ON sub.id_group = gsm.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc
        AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
        AND pay.vt_start < gsm.vt_end AND pay.vt_end > gsm.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_changed_units rv ON rv.id_prop = rcr.id_prop
        AND sub.id_sub = rv.id_sub
        AND rv.tt_end = dbo.MTMaxDate()
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
        AND rv.vt_start < gsm.vt_end AND rv.vt_end > gsm.vt_start
      WHERE
      	rcr.b_charge_per_participant = 'Y'
      	AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
UNION ALL
SELECT
       sub.vt_start AS c_CycleEffectiveDate
      ,sub.vt_start AS c_CycleEffectiveStart
      ,sub.vt_end AS c_CycleEffectiveEnd
      ,sub.vt_start          AS c_SubscriptionStart
      ,sub.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , dbo.mtmindate() as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , grm.vt_start AS c_MembershipStart
      , grm.vt_end AS c_MembershipEnd
      , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, @startDate, @num_notnull_quote_batchids) AS c__IsAllowGenChargeByTrigger
      FROM t_gsub_recur_map grm
      /* TODO: GRM dates or sub dates or both for filtering */
      INNER JOIN t_sub sub ON grm.id_group = sub.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = grm.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_changed_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub
      AND rv.tt_end = dbo.MTMaxDate()
      AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
      AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE
      	grm.tt_end = dbo.mtmaxdate()
      	AND rcr.b_charge_per_participant = 'N'
      	AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);


  EXEC MeterInitialFromRecurWindow @currentDate = @startDate;
  EXEC MeterUdrcFromRecurWindow @currentDate = @startDate, @actionType = 'DebitCorrection';


	INSERT INTO t_recur_window
	SELECT DISTINCT c_CycleEffectiveDate,
	c_CycleEffectiveStart,
	c_CycleEffectiveEnd,
	c_SubscriptionStart,
	c_SubscriptionEnd,
	c_Advance,
	c__AccountID,
	c__PayingAccount,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c_PayerStart,
	c_PayerEnd,
	c__SubscriptionID,
	c_UnitValueStart,
	c_UnitValueEnd,
	c_UnitValue,
	c_BilledThroughDate,
	c_LastIdRun,
	c_MembershipStart,
	c_MembershipEnd
	FROM #recur_window_holder;


UPDATE t_recur_window
SET c_CycleEffectiveEnd =
 (
  SELECT MIN(IsNull(c_CycleEffectiveDate,c_SubscriptionEnd)) FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate
)
WHERE EXISTS
(SELECT 1 FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId
    AND t_recur_window.c_PayerStart = w2.c_PayerStart
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
    AND t_recur_window.c_membershipstart = w2.c_membershipstart
    AND t_recur_window.c_membershipend = w2.c_membershipend
    AND t_recur_window.c__accountid = w2.c__accountid
    AND t_recur_window.c__payingaccount = w2.c__payingaccount
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate)
    ;
end;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering trigger [dbo].[trig_update_recur_window_on_t_sub] on [dbo].[t_sub]'
GO
ALTER TRIGGER trig_update_recur_window_on_t_sub
ON t_sub
FOR  INSERT, UPDATE, DELETE
AS
BEGIN
  DECLARE @now          DATETIME,
          @newSubStart  DATETIME,
          @newSubEnd    DATETIME,
          @curSubStart  DATETIME,
          @curSubEnd    DATETIME,
          @idAcc        INT,
          @idSub        INT,
          @num_notnull_quote_batchids INT

  DELETE
  FROM   t_recur_window
  WHERE  EXISTS (
             SELECT 1
             FROM   DELETED sub
             WHERE  t_recur_window.c__AccountID = sub.id_acc
                    AND t_recur_window.c__SubscriptionID = sub.id_sub
                    AND t_recur_window.c_SubscriptionStart = sub.vt_start
                    AND t_recur_window.c_SubscriptionEnd = sub.vt_end
         );

  MERGE INTO t_recur_window
    USING (
              SELECT DISTINCT sub.id_sub,
                     sub.id_acc,
                     sub.vt_start,
                     sub.vt_end,
                     plm.id_pi_template,
                     plm.id_pi_instance
              FROM   INSERTED sub
                     INNER JOIN t_recur_window trw
                          ON  trw.c__AccountID = sub.id_acc
                          AND trw.c__SubscriptionID = sub.id_sub
                     INNER JOIN t_pl_map plm
                          ON  sub.id_po = plm.id_po
                          AND plm.id_sub = sub.id_sub
                          AND plm.id_paramtable = NULL
          ) AS source
    ON (
           t_recur_window.c__SubscriptionID = source.id_sub
           AND t_recur_window.c__AccountID = source.id_acc
       )
  WHEN MATCHED AND t_recur_window.c__SubscriptionID = source.id_sub
               AND t_recur_window.c__AccountID      = source.id_acc
    THEN UPDATE SET c_SubscriptionStart = source.vt_start,
                    c_SubscriptionEnd   = source.vt_end;
 
  SELECT @num_notnull_quote_batchids = count(1)
  FROM inserted
  WHERE tx_quoting_batch is not null
    AND tx_quoting_batch!=0x00000000000000000000000000000000;

  SELECT sub.vt_start AS c_CycleEffectiveDate,
         sub.vt_start AS c_CycleEffectiveStart,
         sub.vt_end AS c_CycleEffectiveEnd,
         sub.vt_start AS c_SubscriptionStart,
         sub.vt_end AS c_SubscriptionEnd,
         rcr.b_advance AS c_Advance,
         pay.id_payee AS c__AccountID,
         pay.id_payer AS c__PayingAccount,
         plm.id_pi_instance AS c__PriceableItemInstanceID,
         plm.id_pi_template AS c__PriceableItemTemplateID,
         plm.id_po AS c__ProductOfferingID,
         pay.vt_start AS c_PayerStart,
         pay.vt_end AS c_PayerEnd,
         sub.id_sub AS c__SubscriptionID,
         ISNULL(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart,
         ISNULL(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd,
         rv.n_value AS c_UnitValue,
         dbo.mtmindate() AS c_BilledThroughDate,
         -1 AS c_LastIdRun,
         dbo.mtmindate() AS c_MembershipStart,
         dbo.mtmaxdate() AS c_MembershipEnd,
         dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, sub.dt_crt, @num_notnull_quote_batchids) AS c__IsAllowGenChargeByTrigger
         /* We'll use #recur_window_holder in the stored proc that operates only on the latest data */
         INTO #recur_window_holder
  FROM   INSERTED sub
         INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc
         /* AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start */
         INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
         INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
         INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
         LEFT OUTER JOIN t_recur_value rv ON  rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub
              AND rv.tt_end = dbo.MTMaxDate()
              AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
              AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
  WHERE  /* Make sure not to insert a row that already takes care of this account/sub id */
         NOT EXISTS
         (
             SELECT 1
             FROM   T_RECUR_WINDOW
             WHERE  c__AccountID = sub.id_acc
                    AND c__SubscriptionID = sub.id_sub
         )
         AND sub.id_group IS NULL
         AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)

  SELECT @now = tsh.tt_start FROM t_sub_history tsh JOIN INSERTED sub ON tsh.id_acc = sub.id_acc AND tsh.id_sub = sub.id_sub AND tsh.tt_end = dbo.MTMaxDate();

   /* adds charges to METER tables */
  EXEC MeterInitialFromRecurWindow @currentDate = @now;
  /* If this is update of existing subscription add also Credit/Debit charges */
  EXEC MeterCreditFromRecurWindow  @currentDate = @now;

  INSERT INTO t_recur_window
  SELECT c_CycleEffectiveDate,
         c_CycleEffectiveStart,
         c_CycleEffectiveEnd,
         c_SubscriptionStart,
         c_SubscriptionEnd,
         c_Advance,
         c__AccountID,
         c__PayingAccount,
         c__PriceableItemInstanceID,
         c__PriceableItemTemplateID,
         c__ProductOfferingID,
         c_PayerStart,
         c_PayerEnd,
         c__SubscriptionID,
         c_UnitValueStart,
         c_UnitValueEnd,
         c_UnitValue,
         c_BilledThroughDate,
         c_LastIdRun,
         c_MembershipStart,
         c_MembershipEnd
  FROM   #recur_window_holder;

END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO


PRINT N'Altering trigger [dbo].[trig_update_recur_window_on_acc_usage_interval] on [dbo].[t_acc_usage_interval]'
GO
ALTER TRIGGER [dbo].[trig_update_recur_window_on_acc_usage_interval]
on [dbo].[t_acc_usage_interval]
FOR INSERT, UPDATE, delete
AS 
if (not exists (select 1 from inserted where tx_status ='H') and not exists (select 1 from inserted where tx_status ='S'))
BEGIN

DELETE FROM t_recur_window WHERE exists (
	select 1 from DELETED auideleted 
		where t_recur_window.c__AccountID = auideleted .id_acc 
		and t_recur_window.c_CycleEffectiveDate = auideleted .dt_effective
	)
   	  
INSERT INTO t_recur_window
  SELECT
       aui.dt_effective AS c_CycleEffectiveDate
      ,dbo.AddSecond(aui.dt_effective) AS c_CycleEffectiveStart
      ,sub.vt_end AS c_CycleEffectiveEnd
      ,sub.vt_start          AS c_SubscriptionStart
      ,sub.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , dbo.MTMinDate() as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd
      FROM t_sub sub
      INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc
        AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN inserted aui ON pay.id_payer = aui.id_acc 
        AND dbo.AddSecond(aui.dt_effective) < sub.vt_end AND dbo.AddSecond(aui.dt_effective) >= sub.vt_start 
        AND dbo.AddSecond(aui.dt_effective) < pay.vt_end AND dbo.AddSecond(aui.dt_effective) >= pay.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub 
        AND rv.tt_end = dbo.MTMaxDate() 
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start 
        AND dbo.AddSecond(aui.dt_effective) < rv.vt_end AND dbo.AddSecond(aui.dt_effective) >= rv.vt_start
      WHERE 1=1
      AND sub.id_group IS NULL
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
UNION ALL
SELECT
       aui.dt_effective AS c_CycleEffectiveDate
      ,dbo.AddSecond(aui.dt_effective) AS c_CycleEffectiveStart
      ,gsm.vt_end AS c_CycleEffectiveEnd
      ,gsm.vt_start          AS c_SubscriptionStart
      ,gsm.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , dbo.MTMinDate() as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd
      FROM t_gsubmember gsm
      INNER JOIN t_sub sub ON sub.id_group = gsm.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc 
        AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start 
        AND pay.vt_start < gsm.vt_end AND pay.vt_end > gsm.vt_start
      INNER JOIN inserted aui ON pay.id_payer = aui.id_acc 
        AND dbo.AddSecond(aui.dt_effective) < sub.vt_end AND dbo.AddSecond(aui.dt_effective) >= sub.vt_start 
        AND dbo.AddSecond(aui.dt_effective) < pay.vt_end AND dbo.AddSecond(aui.dt_effective) >= pay.vt_start 
        AND dbo.AddSecond(aui.dt_effective) < gsm.vt_end AND dbo.AddSecond(aui.dt_effective) >= gsm.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub 
        AND rv.tt_end = dbo.MTMaxDate() 
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start 
        AND dbo.AddSecond(aui.dt_effective) < rv.vt_end AND aui.dt_effective > rv.vt_start 
        AND rv.vt_start < gsm.vt_end AND rv.vt_end > gsm.vt_start
      WHERE 1=1
      AND rcr.b_charge_per_participant = 'Y'
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
UNION ALL
SELECT
       aui.dt_effective AS c_CycleEffectiveDate
      ,dbo.AddSecond(aui.dt_effective) AS c_CycleEffectiveStart
      ,sub.vt_end AS c_CycleEffectiveEnd
      ,sub.vt_start          AS c_SubscriptionStart
      ,sub.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , dbo.MTMinDate() as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , grm.vt_start AS c_MembershipStart
      , grm.vt_end AS c_MembershipEnd
      FROM t_gsub_recur_map grm
      /* TODO: GRM dates or sub dates or both for filtering */
      INNER JOIN t_sub sub ON grm.id_group = sub.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = grm.id_acc 
        AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN inserted aui ON pay.id_payer = aui.id_acc 
        AND dbo.AddSecond(aui.dt_effective) < sub.vt_end AND dbo.AddSecond(aui.dt_effective) >= sub.vt_start 
        AND dbo.AddSecond(aui.dt_effective) < pay.vt_end AND dbo.AddSecond(aui.dt_effective) >= pay.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub 
        AND rv.tt_end = dbo.MTMaxDate() 
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start 
        AND dbo.AddSecond(aui.dt_effective) < rv.vt_end AND aui.dt_effective > rv.vt_start
      WHERE 1=1
      AND grm.tt_end = dbo.mtmaxdate()
      AND rcr.b_charge_per_participant = 'N'
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
;
UPDATE t_recur_window
 SET c_CycleEffectiveEnd = 
 (
  SELECT MIN(IsNull(c_CycleEffectiveDate,c_SubscriptionEnd)) FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId AND t_recur_window.c_PayerStart = w2.c_PayerStart 
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd 
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart 
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd 
    AND t_recur_window.c_membershipstart = w2.c_membershipstart 
    AND t_recur_window.c_membershipend = w2.c_membershipend 
    AND t_recur_window.c__accountid = w2.c__accountid 
    AND t_recur_window.c__payingaccount = w2.c__payingaccount 
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate
 )
 WHERE 1=1
 AND c__PayingAccount in(select id_acc from inserted)  
 AND EXISTS 
(SELECT 1 FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId 
    AND t_recur_window.c_PayerStart = w2.c_PayerStart 
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd 
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart 
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd 
    AND t_recur_window.c_membershipstart = w2.c_membershipstart 
    AND t_recur_window.c_membershipend = w2.c_membershipend 
    AND t_recur_window.c__accountid = w2.c__accountid 
    AND t_recur_window.c__payingaccount = w2.c__payingaccount 
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate)
;
end;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO


PRINT N'Altering PROCEDURE [dbo].[mtsp_generate_stateful_rcs]'
GO
ALTER PROCEDURE [dbo].[mtsp_generate_stateful_rcs]
                                            @v_id_interval  int
                                           ,@v_id_billgroup int
                                           ,@v_id_run       int
                                           ,@v_id_batch     varchar(256)
                                           ,@v_n_batch_size int
                                                               ,@v_run_date   datetime
                                           ,@p_count      int OUTPUT
AS
BEGIN
      /* SET NOCOUNT ON added to prevent extra result sets from
         interfering with SELECT statements. */
      SET NOCOUNT ON;
	  SET XACT_ABORT ON;
  DECLARE @total_rcs  int,
          @total_flat int,
          @total_udrc int,
          @n_batches  int,
          @id_flat    int,
          @id_udrc    int,
          @id_message bigint,
          @id_ss      int,
          @tx_batch   binary(16);
          
  IF OBJECT_ID (N't_rec_win_bcp_for_reverse', N'U') IS NOT NULL
    DROP TABLE t_rec_win_bcp_for_reverse

  SELECT c_BilledThroughDate, c_CycleEffectiveDate, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c__ProductOfferingID, c__SubscriptionID
  INTO t_rec_win_bcp_for_reverse FROM t_recur_window

  
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Retrieving RC candidates');
SELECT
*
INTO
#TMP_RC
FROM(
	SELECT
      'Arrears'                                                                            AS c_RCActionType
      ,pci.dt_start                                                                        AS c_RCIntervalStart
      ,pci.dt_end                                                                          AS c_RCIntervalEnd
      ,ui.dt_start                                                                         AS c_BillingIntervalStart
      ,ui.dt_end                                                                           AS c_BillingIntervalEnd
      ,dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)                           AS c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)                               AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart                                                              AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd                                                                AS c_SubscriptionEnd
      ,pci.dt_end                                                                          AS c_BilledRateDate
      ,rcr.n_rating_type                                                                   AS c_RatingType
      ,case when rw.c_advance  ='Y' then '1' else '0' end                                  AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end                      AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end                       AS c_ProrateInstantly /* NOTE: c_ProrateInstantly - No longer used */
      ,case when rcr.b_prorate_on_deactivate ='Y' then '1' else '0' end                    AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END AS c_ProrationCycleLength
      ,rw.c__accountid                                                                     AS c__AccountID
      ,rw.c__payingaccount                                                                 AS c__PayingAccount
      ,rw.c__priceableiteminstanceid                                                       AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid                                                       AS c__PriceableItemTemplateID
      ,rw.c__productofferingid                                                             AS c__ProductOfferingID
      ,rw.c_payerstart                                                                     AS c_payerstart
      ,rw.c_payerend                                                                       AS c_payerend
      ,case when rw.c_unitvaluestart < '1970-01-01 00:00:00'
         THEN '1970-01-01 00:00:00'
         ELSE rw.c_unitvaluestart END                                                      AS c_unitvaluestart 
      ,rw.c_unitvalueend                                                                   AS c_unitvalueend
      ,rw.c_unitvalue                                                                      AS c_unitvalue
      ,rw.c__subscriptionid                                                                AS c__SubscriptionID
      ,newid()                                                                             AS idSourceSess
      FROM t_usage_interval ui      
      INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup      
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount 
                                   AND rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* interval overlaps with cycle */
                                   AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < ui.dt_end AND rw.c_subscriptionend   > ui.dt_start /* interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* interval overlaps with UDRC */
      INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop      
      INNER LOOP JOIN t_usage_cycle ccl
           ON ccl.id_usage_cycle = CASE
                                         WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                         WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                         WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                                         ELSE NULL
                                   END
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_end BETWEEN ui.dt_start        AND ui.dt_end                             /* rc end falls in this interval */
                                   AND pci.dt_end BETWEEN rw.c_payerstart    AND rw.c_payerend                         /* rc end goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      WHERE
        ui.id_interval = @v_id_interval
        AND bg.id_billgroup = @v_id_billgroup
        AND rcr.b_advance <> 'Y'
 /* Exclude any accounts which have been billed through the charge range.
	     This is because they will have been billed through to the end of last period (advanced charged)
		 OR they will have ended their subscription in which case all of the charging has been done.
		 ONLY subscriptions which are scheduled to end this period which have not been ended by subscription change will be caught 
		 in these queries
		 */
      AND rw.c_BilledThroughDate < dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)
      /* CORE-8365. If Subscription started and ended in this Bill.cycle, than this is an exception case, when Arrears are generated by trigger.
      Do not charge them here, in EOP. */
      AND NOT (rw.c_SubscriptionStart >= ui.dt_start AND rw.c_SubscriptionEnd <= ui.dt_end)
UNION ALL
SELECT
      'Advance'                                                                            AS c_RCActionType
      ,pci.dt_start		                                                                     AS c_RCIntervalStart		/* Start date of Next RC Interval - the one we'll pay for In Advance in current interval */
      ,pci.dt_end		                                                                       AS c_RCIntervalEnd			/* End date of Next RC Interval - the one we'll pay for In Advance in current interval */
      ,ui.dt_start		                                                                     AS c_BillingIntervalStart	/* Start date of Current Billing Interval */
      ,ui.dt_end	                                                                      	 AS c_BillingIntervalEnd		/* End date of Current Billing Interval */
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate 
         THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start)
         ELSE dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart) END                AS c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)                               AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart                                                              AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd                                                                AS c_SubscriptionEnd
      ,pci.dt_start                                                                        AS c_BilledRateDate
      ,rcr.n_rating_type                                                                   AS c_RatingType
      ,case when rw.c_advance  ='Y' then '1' else '0' end                                  AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end                      AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end                       AS c_ProrateInstantly /* NOTE: c_ProrateInstantly - No longer used */
      ,case when rcr.b_prorate_on_deactivate ='Y' then '1' else '0' end                    AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END AS c_ProrationCycleLength
      ,rw.c__accountid                                                                     AS c__AccountID
      ,rw.c__payingaccount                                                                 AS c__PayingAccount
      ,rw.c__priceableiteminstanceid                                                       AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid                                                       AS c__PriceableItemTemplateID
      ,rw.c__productofferingid                                                             AS c__ProductOfferingID
      ,rw.c_payerstart                                                                     AS c_payerstart
      ,rw.c_payerend                                                                       AS c_payerend
      ,case when rw.c_unitvaluestart < '1970-01-01 00:00:00'
         THEN '1970-01-01 00:00:00'
         ELSE rw.c_unitvaluestart END                                                      AS c_unitvaluestart 
      ,rw.c_unitvalueend                                                                   AS c_unitvalueend
      ,rw.c_unitvalue                                                                      AS c_unitvalue
      ,rw.c__subscriptionid                                                                AS c__SubscriptionID
      ,newid()                                                                             AS idSourceSess
      FROM t_usage_interval ui
      INNER LOOP JOIN t_usage_interval nui ON ui.id_usage_cycle = nui.id_usage_cycle AND dbo.AddSecond(ui.dt_end) = nui.dt_start
      INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup      
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount 
                                   AND rw.c_payerstart          < nui.dt_end AND rw.c_payerend          > nui.dt_start /* next interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < nui.dt_end AND rw.c_cycleeffectiveend > nui.dt_start /* next interval overlaps with cycle */
                                   AND rw.c_membershipstart     < nui.dt_end AND rw.c_membershipend     > nui.dt_start /* next interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < nui.dt_end AND rw.c_subscriptionend   > nui.dt_start /* next interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < nui.dt_end AND rw.c_unitvalueend      > nui.dt_start /* next interval overlaps with UDRC */
      INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop      
      INNER LOOP JOIN t_usage_cycle ccl
           ON ccl.id_usage_cycle = CASE
                                         WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                         WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                         WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                                         ELSE NULL
                                   END
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND (
                                      pci.dt_start BETWEEN nui.dt_start AND nui.dt_end /* RCs that starts in Next Account's Billing Cycle */
                                      
                                      /* Fix for CORE-7060:
                                      In case subscription starts after current EOP we should also charge:
                                      RCs that ends in Next Account's Billing Cycle
                                      and if Next Account's Billing Cycle in the middle of RCs interval.
                                      As in this case, they haven't been charged as Instant RC (by trigger) */
                                      OR (
                                          rw.c_SubscriptionStart >= nui.dt_start
                                          AND pci.dt_end >= nui.dt_start
                                          AND pci.dt_start < nui.dt_end
                                        )
                                   )
                                   AND (
                                      pci.dt_start BETWEEN rw.c_payerstart  AND rw.c_payerend	/* rc start goes to this payer */
                                      
                                      /* Fix for CORE-7273:
                                      Logic above, that relates to Account Billing Cycle, should be duplicated for Payer's Billing Cycle.
                                      
                                      CORE-7273 related case: If Now = EOP = Subscription Start then:
                                      1. Not only RC's that starts in this payer's cycle should be charged, but also the one, that ends and overlaps it;
                                      2. Proration wasn't calculated by trigger and should be done by EOP. */
                                      OR (
                                          rw.c_SubscriptionStart >= rw.c_payerstart
                                          AND pci.dt_end >= rw.c_payerstart
                                          AND pci.dt_start < rw.c_payerend
                                        )
                                   )                                   
                                   AND rw.c_unitvaluestart		< pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart		< pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectiveend	> pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_subscriptionend		> pci.dt_start /* rc overlaps with this subscription */
      WHERE
        ui.id_interval = @v_id_interval
        AND bg.id_billgroup = @v_id_billgroup
        AND rcr.b_advance = 'Y'
 /* Exclude any accounts which have been billed through the charge range.
	     This is because they will have been billed through to the end of last period (advanced charged)
		 OR they will have ended their subscription in which case all of the charging has been done.
		 ONLY subscriptions which are scheduled to end this period which have not been ended by subscription change will be caught 
		 in these queries
		 */
        AND rw.c_BilledThroughDate < dbo.mtmaxoftwodates(
                   (
                       CASE 
                           WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate 
                           THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start) 
                           ELSE pci.dt_start END
                   ),
                   rw.c_SubscriptionStart
               )
)A;

SELECT @total_rcs  = COUNT(1) FROM #tmp_rc;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'RC Candidate Count: ' + CAST(@total_rcs AS VARCHAR));

if @total_rcs > 0
BEGIN

SELECT @total_flat = COUNT(1) FROM #tmp_rc where c_unitvalue is null;
SELECT @total_udrc = COUNT(1) FROM #tmp_rc where c_unitvalue is not null;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Flat RC Candidate Count: ' + CAST(@total_flat AS VARCHAR));
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'UDRC RC Candidate Count: ' + CAST(@total_udrc AS VARCHAR));

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Session Set Count: ' + CAST(@v_n_batch_size AS VARCHAR));
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch: ' + @v_id_batch);

SELECT @tx_batch = cast(N'' as xml).value('xs:hexBinary(sql:variable("@v_id_batch"))', 'binary(16)');
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch ID: ' + CAST(@tx_batch AS varchar));

IF (@tx_batch IS NOT NULL)
BEGIN
UPDATE t_batch SET n_metered = @total_rcs, n_expected = @total_rcs WHERE tx_batch = @tx_batch;
END;

if @total_flat > 0
begin

    
set @id_flat = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
      'metratech.com/flatrecurringcharge');
    
SET @n_batches = (@total_flat / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session 
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc where c_unitvalue is null;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_flat AS id_svc,
    1 AS b_root
FROM #tmp_rc
where c_unitvalue is null) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;

INSERT INTO t_svc_FlatRecurringCharge
(id_source_sess
    ,id_parent_source_sess
    ,id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
    ,c_ProrateInstantly 
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,c__IntervalID
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID)
SELECT 
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
    ,c_ProrateInstantly 
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
FROM #tmp_rc
where c_unitvalue is null;
          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NULL
              ) a
            GROUP BY a.id_message;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting Flat RCs');

END;
if @total_udrc > 0
begin

set @id_udrc = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
      'metratech.com/udrecurringcharge');
    
SET @n_batches = (@total_udrc / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session 
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc where c_unitvalue is not null;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_udrc AS id_svc,
    1 AS b_root
FROM #tmp_rc
where c_unitvalue is not null) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;

INSERT INTO t_svc_UDRecurringCharge
(id_source_sess, id_parent_source_sess, id_external, c_RCActionType, c_RCIntervalStart,c_RCIntervalEnd,c_BillingIntervalStart,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,c__IntervalID
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID
      ,c_unitvaluestart
      ,c_unitvalueend
      ,c_unitvalue
      ,c_ratingtype)
SELECT 
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
    ,c_RCIntervalStart
    ,c_RCIntervalEnd
    ,c_BillingIntervalStart
    ,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
      ,c_unitvaluestart
      ,c_unitvalueend
      ,c_unitvalue
      ,c_ratingtype
FROM #tmp_rc
where c_unitvalue is not null;

          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NOT NULL
              ) a
            GROUP BY a.id_message;

                  INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting UDRC RCs');

END;
    /** UPDATE THE BILLED THROUGH DATE TO THE END OF THE ADVANCED CHARGE 
			 ** (IN CASE THE END THE SUB BEFORE THE END OF THE MONTH)
			 ** THIS WILL MAKE SURE THE CREDIT IS CORRECT AND MAKE SURE THERE ARE NOT CHARGES 
			 ** REGENERATED FOR ALL THE MONTHS WHERE RC ADAPTER RAN (But forgot to mark)
			 ** Only for advanced charges.
		     **/
    MERGE
    INTO    t_recur_window trw
    USING   (
              SELECT MAX(c_RCIntervalSubscriptionEnd) AS NewBilledThroughDate, c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
              FROM #tmp_rc
              WHERE c_RCActionType = 'Advance'
              GROUP BY c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
            ) trc
    ON      (
              trw.c__AccountID = trc.c__AccountID
              AND trw.c__SubscriptionID = trc.c__SubscriptionID
              AND trw.c__PriceableItemInstanceID = trc.c__PriceableItemInstanceID
              AND trw.c__PriceableItemTemplateID = trc.c__PriceableItemTemplateID
              AND trw.c__ProductOfferingID = trc.c__ProductOfferingID
            )
    WHEN MATCHED THEN
    UPDATE
    SET     trw.c_BilledThroughDate = trc.NewBilledThroughDate;

 END;

 SET @p_count = @total_rcs;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Info', 'Finished submitting RCs, count: ' + CAST(@total_rcs AS VARCHAR));

END;
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO


IF EXISTS (SELECT * FROM #tmpErrors) ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT>0 BEGIN
PRINT 'The database update succeeded'
COMMIT TRANSACTION
END
ELSE PRINT 'The database update failed'
GO
DROP TABLE #tmpErrors
GO
