
/*  */
/*  Creates discount constraint groups */
/*  */
/*  For a given set of payers, the query will check all payees of */
/*  those payers during the current interval for subscriptions to POs containing discount PIs. */
/*  If any payees are found to be affiliated with a discount, all payers (on the same */
/*  billing cycle as the interval) of that account and any related accounts (siblings in a */
/*  gsub, discount account of the gsub) for the interval will be put in a constraint group. */
/*  */
/*  NOTE: this constraint applies even if a discount interval doesn't end in the current */
/*  billing interval. this is not strictly necessary but makes the constraint much easier to implement */
/*  */
begin
INSERT INTO t_billgroup_constraint_tmp (id_usage_interval, id_group, id_acc)
SELECT distinct
  ui.id_interval,
  source.id_acc id_group,
  otherpay.id_payer id_acc
FROM t_payment_redirection pay
inner join t_billgroup_source_acc source  ON pay.id_payer = source.id_acc
INNER JOIN t_acc_usage_interval aui ON aui.id_acc = source.id_acc
INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval 
and  pay.vt_start <= ui.dt_end AND pay.vt_end   >= ui.dt_start
inner join t_payment_redirection otherpay on otherpay.id_payee=pay.id_payee 
inner join t_acc_usage_interval aui2 on aui2.id_acc=otherpay.id_payer and aui2.id_usage_interval=aui.id_usage_interval and otherpay.vt_start <= ui.dt_end AND
                                        otherpay.vt_end >= ui.dt_start
where exists
    (
    select 1 from 
    t_sub sub
    where sub.id_acc = pay.id_payee AND
             sub.vt_start <= ui.dt_end AND
             sub.vt_end   >= ui.dt_start
    and  sub.id_group is null
    and exists
        (
        select 1 from t_pl_map typemap
        INNER JOIN t_discount disc ON disc.id_prop = typemap.id_pi_template
        where typemap.id_po = sub.id_po
        AND typemap.id_paramtable IS NULL
        )
    )
and
  source.id_materialization = %%ID_MATERIALIZATION%% AND
  ui.id_interval = %%ID_USAGE_INTERVAL%% AND 
  /* don't insert duplicate accounts into existing groups */
  otherpay.id_payer NOT IN
  (
    SELECT id_acc 
    FROM t_billgroup_constraint_tmp
    WHERE 
      id_group = source.id_acc AND
      id_usage_interval = ui.id_interval
  );

INSERT INTO t_billgroup_constraint_tmp (id_usage_interval, id_group, id_acc)
SELECT distinct
  ui.id_interval,
  source.id_acc id_group,
  otherpay.id_payer id_acc
FROM t_payment_redirection pay
inner join t_billgroup_source_acc source  ON pay.id_payer = source.id_acc
INNER JOIN t_acc_usage_interval aui ON aui.id_acc = source.id_acc
INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval 
and  pay.vt_start <= ui.dt_end AND pay.vt_end   >= ui.dt_start
inner join t_payment_redirection otherpay on otherpay.id_payee=pay.id_payee 
inner join t_acc_usage_interval aui2 on aui2.id_acc=otherpay.id_payer and aui2.id_usage_interval=aui.id_usage_interval and otherpay.vt_start <= ui.dt_end AND
                                        otherpay.vt_end >= ui.dt_start
where 
    exists
    (
    select 1 from 
    t_sub sub
    inner JOIN t_group_sub gsub ON gsub.id_group = sub.id_group
    inner JOIN t_gsubmember mem ON mem.id_group = gsub.id_group
    where mem.id_acc = pay.id_payee AND
             sub.vt_start <= ui.dt_end AND
             sub.vt_end   >= ui.dt_start
    and exists
        (
        select 1 from t_pl_map typemap 
        INNER JOIN t_discount disc ON disc.id_prop = typemap.id_pi_template
        where typemap.id_po = sub.id_po
        AND typemap.id_paramtable IS NULL
        and NOT (b_supportgroupops = 'Y' AND disc.id_usage_cycle IS NOT NULL) 
        )
    )
and
  source.id_materialization = %%ID_MATERIALIZATION%% AND
  ui.id_interval = %%ID_USAGE_INTERVAL%% AND 
  /* don't insert duplicate accounts into existing groups */
  otherpay.id_payer NOT IN
  (
    SELECT id_acc 
    FROM t_billgroup_constraint_tmp
    WHERE 
      id_group = source.id_acc AND
      id_usage_interval = ui.id_interval
  );

INSERT INTO t_billgroup_constraint_tmp (id_usage_interval, id_group, id_acc)
SELECT distinct
  ui.id_interval,
  source.id_acc id_group,
  otherpay.id_payer id_acc
FROM t_payment_redirection pay
inner join t_billgroup_source_acc source  ON pay.id_payer = source.id_acc
INNER JOIN t_acc_usage_interval aui ON aui.id_acc = source.id_acc
INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval 
and  pay.vt_start <= ui.dt_end AND pay.vt_end   >= ui.dt_start
inner join t_payment_redirection otherpay on otherpay.id_payee=pay.id_payee 
inner join t_acc_usage_interval aui2 on aui2.id_acc=otherpay.id_payer and aui2.id_usage_interval=aui.id_usage_interval and otherpay.vt_start <= ui.dt_end AND
                                        otherpay.vt_end >= ui.dt_start
where 
	exists
    (
        select 1 from 
        t_sub sub
        inner JOIN t_group_sub gsub ON gsub.id_group = sub.id_group
        inner JOIN t_gsubmember mem ON mem.id_group = gsub.id_group
        where gsub.id_discountaccount = pay.id_payee AND
                 sub.vt_start <= ui.dt_end AND
                 sub.vt_end   >= ui.dt_start
        and exists
            (
            select 1 from t_pl_map typemap 
            INNER JOIN t_discount disc ON disc.id_prop = typemap.id_pi_template
            where typemap.id_po = sub.id_po
            AND typemap.id_paramtable IS NULL
            and NOT (b_supportgroupops = 'Y' AND disc.id_usage_cycle IS NOT NULL) 
            )
    )
and
  source.id_materialization = %%ID_MATERIALIZATION%% AND
  ui.id_interval = %%ID_USAGE_INTERVAL%% AND 
  /* don't insert duplicate accounts into existing groups */
  otherpay.id_payer NOT IN
  (
    SELECT id_acc 
    FROM t_billgroup_constraint_tmp
    WHERE 
      id_group = source.id_acc AND
      id_usage_interval = ui.id_interval
  );

INSERT INTO t_billgroup_constraint_tmp (id_usage_interval, id_group, id_acc)
SELECT distinct
  ui.id_interval,
  source.id_acc id_group,
  otherpay.id_payer id_acc
FROM t_billgroup_source_acc source 
inner join t_payment_redirection pay  ON pay.id_payer = source.id_acc
cross join t_payment_redirection otherpay
INNER JOIN t_acc_usage_interval aui ON aui.id_acc = source.id_acc
INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval 
and  pay.vt_start <= ui.dt_end AND pay.vt_end   >= ui.dt_start
inner join t_acc_usage_interval aui2 on aui2.id_acc=otherpay.id_payer and aui2.id_usage_interval=aui.id_usage_interval and otherpay.vt_start <= ui.dt_end AND
                                        otherpay.vt_end >= ui.dt_start
where 
    exists
        (
        select 1 from 
        t_sub sub
        inner JOIN t_group_sub gsub ON gsub.id_group = sub.id_group
        inner JOIN t_gsubmember mem ON mem.id_group = gsub.id_group
        where gsub.id_discountaccount = pay.id_payee AND
                 sub.vt_start <= ui.dt_end AND
                 sub.vt_end   >= ui.dt_start
        and exists
            (
                select 1 from t_pl_map typemap 
                INNER JOIN t_discount disc ON disc.id_prop = typemap.id_pi_template
                where typemap.id_po = sub.id_po
                AND typemap.id_paramtable IS NULL
                and NOT (b_supportgroupops = 'Y' AND disc.id_usage_cycle IS NOT NULL) 
            )
        and exists
            (  SELECT 1
                  FROM 
				  t_gsubmember othermembers 
                  where othermembers.id_group = sub.id_group and
				  otherpay.id_payee = othermembers.id_acc and
                  ui.dt_start <= othermembers.vt_end AND
                  ui.dt_end   >= othermembers.vt_start
            )
        )
and
  source.id_materialization = %%ID_MATERIALIZATION%% AND
  ui.id_interval = %%ID_USAGE_INTERVAL%% AND 
  /* don't insert duplicate accounts into existing groups */
  otherpay.id_payer NOT IN
  (
    SELECT id_acc 
    FROM t_billgroup_constraint_tmp
    WHERE 
      id_group = source.id_acc AND
      id_usage_interval = ui.id_interval
  );

INSERT INTO t_billgroup_constraint_tmp (id_usage_interval, id_group, id_acc)
SELECT distinct
  ui.id_interval,
  source.id_acc id_group,
  otherpay.id_payer id_acc
FROM t_billgroup_source_acc source 
inner join t_payment_redirection pay  ON pay.id_payer = source.id_acc
cross join t_payment_redirection otherpay
INNER JOIN t_acc_usage_interval aui ON aui.id_acc = source.id_acc
INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval 
and  pay.vt_start <= ui.dt_end AND pay.vt_end   >= ui.dt_start
inner join t_acc_usage_interval aui2 on aui2.id_acc=otherpay.id_payer and aui2.id_usage_interval=aui.id_usage_interval and otherpay.vt_start <= ui.dt_end AND
                                        otherpay.vt_end >= ui.dt_start
where 
    exists
        (
        select 1 from 
        t_sub sub
        inner JOIN t_group_sub gsub ON gsub.id_group = sub.id_group
        inner JOIN t_gsubmember mem ON mem.id_group = gsub.id_group
        where mem.id_acc = pay.id_payee AND
                 sub.vt_start <= ui.dt_end AND
                 sub.vt_end   >= ui.dt_start
        and exists
            (
                select 1 from t_pl_map typemap 
                INNER JOIN t_discount disc ON disc.id_prop = typemap.id_pi_template
                where typemap.id_po = sub.id_po
                AND typemap.id_paramtable IS NULL
                and NOT (b_supportgroupops = 'Y' AND disc.id_usage_cycle IS NOT NULL) 
            )
        and exists
            (  SELECT 1
                  FROM 
				  t_gsubmember othermembers 
                  where othermembers.id_group = sub.id_group and
				  otherpay.id_payee = othermembers.id_acc and
                  ui.dt_start <= othermembers.vt_end AND
                  ui.dt_end   >= othermembers.vt_start
            )
        )
and
  source.id_materialization = %%ID_MATERIALIZATION%% AND
  ui.id_interval = %%ID_USAGE_INTERVAL%% AND 
  /* don't insert duplicate accounts into existing groups */
  otherpay.id_payer NOT IN
  (
    SELECT id_acc 
    FROM t_billgroup_constraint_tmp
    WHERE 
      id_group = source.id_acc AND
      id_usage_interval = ui.id_interval
  );

end;
