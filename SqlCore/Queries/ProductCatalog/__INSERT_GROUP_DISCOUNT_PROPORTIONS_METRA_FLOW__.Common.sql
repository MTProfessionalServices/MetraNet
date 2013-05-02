
INSERT INTO %%%TEMP_TABLE_PREFIX%%%tmp_discount_3 (id_interval, id_group, id_acc, id_pi_instance, proportion)
/*  inserts each member's proportion of the total group discount into tmp_discount_3 */
SELECT
   tmp.pci_id_usage_interval AS id_interval,
   tmp.gs_id_group AS id_group,
   tmp.sub_id_acc AS id_acc,
   tmp.plm_id_pi_instance AS id_pi_instance,
   tmp.c_DistributionCounter/rated_discount.c_DistributionCounter proportion
FROM tmp_grp_disc_contrib tmp
INNER JOIN t_pv_groupdiscount_temp rated_discount ON tmp.gs_id_group=rated_discount.c_GroupSubscriptionID AND tmp.pci_id_usage_interval=rated_discount.c_GroupDiscountIntervalID
INNER JOIN t_acc_usage au ON au.id_sess=rated_discount.id_sess AND au.id_usage_interval=rated_discount.id_usage_interval AND au.id_pi_instance=tmp.plm_id_pi_instance
WHERE
tmp.c_DistributionCounter <> 0
