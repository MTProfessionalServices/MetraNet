
CREATE PROCEDURE InsertChargesIntoSvcTables
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