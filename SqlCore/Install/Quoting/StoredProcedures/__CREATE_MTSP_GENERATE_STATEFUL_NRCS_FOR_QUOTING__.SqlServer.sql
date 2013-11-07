CREATE PROCEDURE [dbo].[MTSP_GENERATE_ST_NRCS_QUOTING]

@dt_start datetime,
@dt_end datetime,
@v_id_accounts VARCHAR(4000),
@v_id_poid VARCHAR(4000),
@v_id_interval int,
@v_id_batch varchar(256),
@v_n_batch_size int,
@v_run_date datetime,
@v_is_group_sub int,
@p_count int OUTPUT

AS BEGIN

DECLARE @id_nonrec int,
		@n_batches  int,
		@total_nrcs int,
		@id_message bigint,
		@id_ss int,
		@tx_batch binary(16);
		
IF OBJECT_ID('tempdb..#TMP_NRC_ACCOUNTS_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_NRC_ACCOUNTS_FOR_RUN

IF OBJECT_ID('tempdb..#TMP_RC_POID_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_RC_POID_FOR_RUN

IF OBJECT_ID('tempdb..#TMP_NRC') IS NOT NULL
DROP TABLE #TMP_NRC

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


SELECT * INTO #TMP_NRC_ACCOUNTS_FOR_RUN FROM(SELECT value as id_acc FROM CSVToInt(@v_id_accounts)) A;
SELECT * INTO #TMP_RC_POID_FOR_RUN FROM(SELECT value as id_po FROM CSVToInt(@v_id_poid)) A;

SELECT @tx_batch = cast(N'' as xml).value('xs:hexBinary(sql:variable("@v_id_batch"))', 'binary(16)');

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
			inner join #TMP_NRC_ACCOUNTS_FOR_RUN acc on acc.id_acc = mem.id_acc
			inner join #TMP_RC_POID_FOR_RUN po on po.id_po = sub.id_po
			inner join t_po on sub.id_po = t_po.id_po
			inner join t_pl_map plm on sub.id_po = plm.id_po and plm.id_paramtable IS NULL
			inner join t_base_props bp on bp.id_prop = plm.id_pi_instance and bp.n_kind = 30
			inner join t_nonrecur nrc on nrc.id_prop = bp.id_prop and nrc.n_event_type = 1
	WHERE	sub.vt_start >= @dt_start and sub.vt_start < @dt_end
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
			inner join #TMP_NRC_ACCOUNTS_FOR_RUN acc on acc.id_acc = sub.id_acc
			inner join #TMP_RC_POID_FOR_RUN po on po.id_po = sub.id_po
			inner join t_po on sub.id_po = t_po.id_po
			inner join t_pl_map plm on sub.id_po = plm.id_po and plm.id_paramtable IS NULL
			inner join t_base_props bp on bp.id_prop = plm.id_pi_instance and bp.n_kind = 30
			inner join t_nonrecur nrc on nrc.id_prop = bp.id_prop and nrc.n_event_type = 1
	WHERE	sub.vt_start >= @dt_start and sub.vt_start < @dt_end
	;

END

set @total_nrcs = (select count(*) from #tmp_nrc)

set @id_nonrec = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/nonrecurringcharge');

SET @n_batches = (@total_nrcs / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

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

drop table #tmp_nrc
SET @p_count = @total_nrcs
END