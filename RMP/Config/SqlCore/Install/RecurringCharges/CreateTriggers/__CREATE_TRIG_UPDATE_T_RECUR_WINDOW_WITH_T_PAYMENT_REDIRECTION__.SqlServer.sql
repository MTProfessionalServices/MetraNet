CREATE trigger [dbo].[trig_update_t_recur_window_with_t_payment_redirection]
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
