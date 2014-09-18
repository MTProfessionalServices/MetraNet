
CREATE PROCEDURE updatesub (
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