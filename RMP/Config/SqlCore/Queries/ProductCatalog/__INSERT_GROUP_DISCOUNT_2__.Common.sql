
/* %%INSERT_INTO_CLAUSE2%% Added this hack since we need to just add this in insert_simple_discount_1 but code is same for both the queries*/
%%INSERT_INTO_CLAUSE%%
/*  calculates the actual discount intervals and inserts them into tmp_discount_2  */
SELECT 
   di.id_interval,
   gsub.id_group id_acc,
   NULL id_payer,
   typemap.id_pi_instance,
   typemap.id_pi_template,
   typemap.id_po,
   NULL dt_bill_start,
   NULL dt_bill_end,
   sub.vt_start dt_sub_start,
   sub.vt_end dt_sub_end,
   CASE WHEN di.dt_start >= sub.vt_start THEN di.dt_start ELSE sub.vt_start END dt_effdisc_start,
   CASE WHEN di.dt_end <= sub.vt_end THEN di.dt_end ELSE sub.vt_end END dt_effdisc_end,
   di.dt_start dt_disc_start,
   di.dt_end dt_disc_end,
   NULL tt_pay_end
%%INTO_CLAUSE%%
FROM t_discount disc
INNER JOIN (SELECT t_pl_map.id_pi_instance, t_pl_map.id_pi_template, t_pl_map.id_po
            FROM t_pl_map
            WHERE id_pi_template = %%ID_PI%% AND
                  id_paramtable IS NULL
            ) typemap ON typemap.id_pi_instance = disc.id_prop
INNER JOIN t_sub sub ON sub.id_po = typemap.id_po
INNER JOIN t_group_sub gsub ON gsub.id_group = sub.id_group
INNER JOIN t_pc_interval di ON di.id_cycle = disc.id_usage_cycle OR
                        		  /* handles the billing cycle relative case	       */
                              (disc.id_usage_cycle IS NULL AND di.id_cycle = gsub.id_usage_cycle)
WHERE 
   gsub.b_supportgroupops = 'Y' AND
   %%DISCOUNT_INTERVAL_FILTER%% AND
   di.dt_start <= sub.vt_end AND 
   di.dt_end >= sub.vt_start
   %%BILLING_GROUP_FILTER%%
