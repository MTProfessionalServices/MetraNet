
SELECT 
  /* __GET_ACCOUNTS_AND_BALANCES_TO_CHECK_WITH_EXTERNAL_AR_SYSTEM__ */
  am.ExtAccount as ExtAccountID,
  inv.current_balance 
    + {fn ifnull(Payments.amount,0)} 
    + {fn ifnull(ARAdjustments.amount,0)} 
    + {fn ifnull(PBAdjustments.amount,0)} as Balance
  /* Extra Info For Troubleshooting
    ,{fn ifnull(Payments.amount,0)} as PaymentsAfterIntervalEnd,
    {fn ifnull(ARAdjustments.amount,0)} as ARAdjustmentsAfterIntervalEnd,
    {fn ifnull(PBAdjustments.amount,0)} as PostBillAdjustmentsAfterIntervalEnd,
    inv.current_balance as 'Previous Invoice Amount' */
FROM VW_AR_ACC_MAPPER am
INNER JOIN t_invoice inv ON am.id_acc = inv.id_acc
INNER JOIN t_billgroup_member bg ON inv.id_acc = bg.id_acc 
  and bg.id_billgroup = %%ID_BILLGROUP%%
left outer join
  (
    select 
      id_acc, 
      sum(au.amount) as Amount 
      from t_pv_payment pay
    join t_acc_usage au on au.id_sess=pay.id_sess 
      and au.dt_crt > (select dt_end from t_usage_interval where id_interval = %%ID_INTERVAL%%)
      and pay.c_Source <> 'AR' group by id_acc
  ) Payments on am.id_acc=Payments.id_acc
left outer join
  (
    select 
      id_acc, 
      sum(au.amount) as Amount 
      from t_pv_ARAdjustment aradj
    join t_acc_usage au on au.id_sess=aradj.id_sess 
      and au.dt_crt > (select dt_end from t_usage_interval where id_interval = %%ID_INTERVAL%%)
      and aradj.c_Source <> 'AR' group by id_acc
  ) ARAdjustments on am.id_acc = ARAdjustments.id_acc
left outer join
  (
    select id_acc_payer, 
      sum(CASE WHEN adj.AdjustmentAmount > 0 
          THEN -adj.AdjustmentAmount 
          ELSE adj.AdjustmentAmount END) as Amount
    FROM t_adjustment_transaction adj
    WHERE adj.c_status = 'A' /* approved */
      AND n_adjustmenttype = 1 /* postbill */
      AND adj.dt_crt > (select dt_end from t_usage_interval where id_interval = %%ID_INTERVAL%%)			
    GROUP BY id_acc_payer
  ) PBAdjustments on am.id_acc =  PBAdjustments.id_acc_payer
WHERE am.ExtNamespace = '%%NAME_SPACE%%'
         