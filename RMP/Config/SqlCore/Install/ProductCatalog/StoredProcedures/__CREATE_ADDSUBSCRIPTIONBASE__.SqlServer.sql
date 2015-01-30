
CREATE procedure addsubscriptionbase(
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