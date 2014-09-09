
    create or replace
procedure insertChargesIntoSvcTables (meterType1 in VARCHAR2, meterType2 in varchar2) as
    idRun INT;
    idMessage INT;
    idServiceFlat int;
    idServiceUdrc int;
    numBlocks int;
    v_block_next t_current_id.id_current%TYPE;    
begin
    select count(1) into numBlocks from tmp_rc where (c_RCActionType like meterType1 or c_RcActionType like meterType2);
    if (numBlocks = 0) then return; end if;
    
/*    getidblock(numBlocks, 'id_dbqueuesch', idMessage);*/

    UPDATE t_current_id
        SET id_current    = id_current + numBlocks
        WHERE nm_current = 'id_dbqueuesch'
        RETURNING id_current
        INTO v_block_next;

    IF sql%FOUND
    THEN
        idMessage   := v_block_next - numBlocks;
    ELSE
        raise_application_error (-20001,
                                'T_CURRENT_ID Update failed for ' || 'id_dbqueuesch'
        );
    END IF;

    
/*    getIdBlock(numBlocks, 'id_dbqueuess', idRun);*/
    UPDATE t_current_id
        SET id_current    = id_current + numBlocks
        WHERE nm_current = 'id_dbqueuess'
        RETURNING id_current
        INTO v_block_next;

    IF sql%FOUND
    THEN
        idRun   := v_block_next - numBlocks;
    ELSE
        raise_application_error (-20001,
                                'T_CURRENT_ID Update failed for ' || 'id_dbqueuess'
        );
    END IF;


    SELECT id_enum_data into idServiceFlat FROM t_enum_data ted WHERE ted.nm_enum_data LIKE
         'metratech.com/flatrecurringcharge';
    SELECT id_enum_data into idServiceUdrc FROM t_enum_data ted WHERE ted.nm_enum_data LIKE
         'metratech.com/udrecurringcharge';  
       
    INSERT INTO t_session
      SELECT idRun + ROW_NUMBER() OVER (ORDER BY id_Source_Sess) - 1 AS id_ss,
        id_source_sess,
        1 as id_partition
      FROM tmp_rc
        where (c_RCActionType like meterType1 or c_RcActionType like meterType2);

    INSERT INTO t_session_set
      SELECT idMessage + ROW_NUMBER() OVER (ORDER BY id_Source_Sess) - 1 AS id_message,
      idRun + ROW_NUMBER() OVER (ORDER BY id_Source_Sess) - 1 AS id_ss,
      case when c_unitValue IS NULL then idServiceFlat ELSE idServiceUdrc END AS id_svc,
      1 AS b_root,
      1 AS session_count,
      1 as id_partition
    FROM tmp_rc
      where (c_RCActionType like meterType1 or c_RcActionType like meterType2);
    
    INSERT INTO t_message
    select idMessage + ROW_NUMBER() OVER (ORDER BY id_Source_Sess) - 1 AS id_message,
        NULL as id_route,
        metratime(1,'RC') as dt_crt ,
        metratime(1,'RC') as dt_metered ,
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
      1 as id_partition
   FROM tmp_rc 
     where (c_RCActionType like meterType1 or c_RcActionType like meterType2);
    
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
    ,c__CollectionID,
    id_partition)
    SELECT 
    id_source_sess
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
    ,c__QuoteBatchId AS c__CollectionID,
    1 as id_partition
FROM tmp_rc where c_UnitValue is null
    and (c_RCActionType like meterType1 or c_RcActionType like meterType2);
     
    INSERT INTO t_svc_UDRecurringCharge(
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
    ,id_partition)
SELECT 
    id_source_sess
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
    ,1 as id_partition
   FROM tmp_rc where c_UnitValue is not null
     and (c_RCActionType like meterType1 or c_RcActionType like meterType2);

/* WHY?! */
delete FROM tmp_rc where (c_RCActionType like meterType1 or c_RcActionType like meterType2);
end insertchargesintosvctables;
