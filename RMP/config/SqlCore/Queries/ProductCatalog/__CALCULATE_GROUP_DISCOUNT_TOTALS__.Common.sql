
SELECT
/*  this rowset gets metered to the first pass discount stage */
	%%INFO_LABEL%%
	%%EXPOSE_COUNTERS%%
	singlemember.id_group c_GroupSubscriptionID,
	'1' c_GroupDiscountPass,
	singlemember.id_acc c__AccountID,
	tmp_2.id_pi_instance c__PriceableItemInstanceID,
	tmp_2.id_pi_template c__PriceableItemTemplateID,
	tmp_2.id_po c__ProductOfferingID,
	CASE WHEN tmp_2.dt_sub_start = {ts '1900-01-01 00:00:00'} /* TO_DATE('1900-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss')  */
	THEN NULL ELSE tmp_2.dt_sub_start END c_SubscriptionStart,
	CASE WHEN tmp_2.dt_sub_end = {ts '4000-12-31 23:59:59'}   /* TO_DATE('4000-12-31 23:59:59', 'yyyy-mm-dd hh24:mi:ss')  */
	THEN NULL ELSE tmp_2.dt_sub_end END c_SubscriptionEnd,
  	tmp_2.dt_disc_start c_DiscountIntervalStart, 
  	tmp_2.dt_disc_end c_DiscountIntervalEnd, 
	tmp_2.dt_effdisc_start c_DiscountIntervalSubStart,
	CASE WHEN singlemember.vt_end < tmp_2.dt_effdisc_end THEN
	  singlemember.vt_end
        ELSE
	  tmp_2.dt_effdisc_end
	END c_DiscountIntervalSubEnd,
  tmp_2.id_interval c_GroupDiscountIntervalID
FROM
	%%%TEMP_TABLE_PREFIX%%%tmp_discount_2 tmp_2
%%COUNTERS_SUBSELECT%%
INNER JOIN (
  /* for each group sub, gets the member with the latest association end date */
  /* if there is a tie, it is broken by picking the minimal account ID */
  SELECT 
    MIN(tgs.id_acc) id_acc,
    tmp_2.id_interval,
    tgs.id_group,
    tgs.vt_end
  FROM	  
  (
    SELECT
      MAX(tgs.vt_end) vt_end,
      tmp_2.id_interval,
      tgs.id_group
    FROM 
      t_gsubmember tgs
    INNER JOIN %%%TEMP_TABLE_PREFIX%%%tmp_discount_2 tmp_2 ON tmp_2.id_acc = tgs.id_group
    /* the member must have been active at some point during the discount interval */
    WHERE 
      tmp_2.dt_effdisc_start <= tgs.vt_end AND 
      tmp_2.dt_effdisc_end >= tgs.vt_start
    GROUP BY 
      tmp_2.id_interval,
      tgs.id_group
  ) maxactivemember
  INNER JOIN t_gsubmember tgs ON tgs.id_group = maxactivemember.id_group AND
                                 tgs.vt_end = maxactivemember.vt_end
  INNER JOIN %%%TEMP_TABLE_PREFIX%%%tmp_discount_2 tmp_2 ON 
    tmp_2.id_interval = maxactivemember.id_interval AND
    tmp_2.id_acc = tgs.id_group
  WHERE 
    tmp_2.dt_effdisc_start <= tgs.vt_end AND 
    tmp_2.dt_effdisc_end >= tgs.vt_start
  GROUP BY
    tmp_2.id_interval,
    tgs.id_group,
    tgs.vt_end
) singlemember ON singlemember.id_interval = tmp_2.id_interval AND
                  singlemember.id_group = tmp_2.id_acc
