
begin
%%INSERT_INTO_CLAUSE%% 
/*  Store non-acc_usage related information in tmp_discount_1 */
SELECT 
   sub.id_acc,
   pay.id_payer,
   typemap.id_pi_instance,
   typemap.id_pi_template,
   typemap.id_po,
   CASE WHEN disc.id_usage_cycle IS NULL THEN   /* is the discount billing cycle relative */
         auc.id_usage_cycle   /* use the payers billing cycle */
   ELSE  /* the discount is not billing cycle relative, so use the discount cycle */
      disc.id_usage_cycle 
   END id_usage_cycle,
   /* handles billing cycle updates for the payer */
   CASE WHEN dbo.AddSecond(accinterval.dt_effective) > binterval.dt_start THEN
      dbo.AddSecond(accinterval.dt_effective)
   ELSE
      binterval.dt_start 
   END dt_bill_start,
   binterval.dt_end dt_bill_end,
   CASE WHEN sub.vt_start IS NULL THEN
      /* TO_DATE('1900-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss') */
      {ts '1900-01-01 00:00:00'}
   ELSE
      sub.vt_start
   END dt_sub_start,
   CASE WHEN sub.vt_end IS NULL THEN
      /* TO_DATE('4000-12-31 23:59:59', 'yyyy-mm-dd hh24:mi:ss') */
      {ts '4000-12-31 23:59:59'}
   ELSE
      sub.vt_end
   END dt_sub_end,
  pay.vt_start vt_pay_start,
  pay.vt_end vt_pay_end,
  pay.tt_start tt_pay_start,
  pay.tt_end tt_pay_end
%%INTO_CLAUSE%%
FROM t_usage_interval binterval
INNER JOIN t_acc_usage_interval accinterval ON accinterval.id_usage_interval = binterval.id_interval
INNER JOIN t_payment_redir_history pay ON pay.id_payer = accinterval.id_acc
/*  NOTE: the t_vw_expanded_sub view is inlined here.  The optimizer seems to */
/*        get confused when the view is used. */
/* INNER JOIN t_vw_expanded_sub sub ON sub.id_acc = pay.id_payee */
INNER JOIN t_sub sub on sub.id_acc = pay.id_payee
INNER JOIN t_pl_map typemap ON typemap.id_po = sub.id_po
INNER JOIN t_discount disc ON disc.id_prop = typemap.id_pi_instance
INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = pay.id_payer
INNER JOIN t_billgroup_member bgmember ON bgmember.id_acc = pay.id_payer
WHERE typemap.id_paramtable IS NULL AND
      typemap.id_pi_template = %%ID_PI%% AND
      binterval.id_interval = %%ID_INTERVAL%% AND
      bgmember.id_billgroup =  %%ID_BILLGROUP%%;

%%INSERT_INTO_CLAUSE2%% 
/*  Store non-acc_usage related information in tmp_discount_1 */
SELECT 
   mem.id_acc,
   pay.id_payer,
   typemap.id_pi_instance,
   typemap.id_pi_template,
   typemap.id_po,
   CASE WHEN disc.id_usage_cycle IS NULL THEN   /* is the discount billing cycle relative */
      CASE WHEN gsub.id_usage_cycle IS NULL THEN /* and it is not a group subscription */
         auc.id_usage_cycle   /* use the payers billing cycle */
      ELSE
         gsub.id_usage_cycle         /* use the group subs cycle */
      END
   ELSE  /* the discount is not billing cycle relative, so use the discount cycle */
      disc.id_usage_cycle 
   END id_usage_cycle,
   /* handles billing cycle updates for the payer */
   CASE WHEN dbo.AddSecond(accinterval.dt_effective) > binterval.dt_start THEN
      dbo.AddSecond(accinterval.dt_effective)
   ELSE
      binterval.dt_start 
   END dt_bill_start,
   binterval.dt_end dt_bill_end,
   mem.vt_start dt_sub_start,
   mem.vt_end dt_sub_end,
  pay.vt_start vt_pay_start,
  pay.vt_end vt_pay_end,
  pay.tt_start tt_pay_start,
  pay.tt_end tt_pay_end
FROM t_usage_interval binterval
INNER JOIN t_acc_usage_interval accinterval ON accinterval.id_usage_interval = binterval.id_interval
INNER JOIN t_payment_redir_history pay ON pay.id_payer = accinterval.id_acc
/*  NOTE: the t_vw_expanded_sub view is inlined here.  The optimizer seems to */
/*        get confused when the view is used. */
/* INNER JOIN t_vw_expanded_sub sub ON sub.id_acc = pay.id_payee */
inner JOIN t_gsubmember mem ON  mem.id_acc = pay.id_payee
inner JOIN t_group_sub gsub ON mem.id_group = gsub.id_group
INNER JOIN  t_sub sub on gsub.id_group = sub.id_group
INNER JOIN t_pl_map typemap ON typemap.id_po = sub.id_po
INNER JOIN t_discount disc ON disc.id_prop = typemap.id_pi_instance
INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = pay.id_payer
INNER JOIN t_billgroup_member bgmember ON bgmember.id_acc = pay.id_payer
WHERE typemap.id_paramtable IS NULL AND
      typemap.id_pi_template = %%ID_PI%% AND
      binterval.id_interval = %%ID_INTERVAL%% AND
      bgmember.id_billgroup =  %%ID_BILLGROUP%% AND
      gsub.b_supportgroupops = 'N';
end;
