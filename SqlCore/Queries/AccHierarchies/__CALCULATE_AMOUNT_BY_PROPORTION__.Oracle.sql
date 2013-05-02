
				select 
				td.amount*proc1.proportion c__Amount,
				proc1.id_acc c__AccountID,
				tmp_2.id_pi_instance c__PriceableItemInstanceID,
				tmp_2.id_pi_template c__PriceableItemTemplateID,
				tmp_2.id_po c__ProductOfferingID,
				tmp_2.b_dt_start c_BillingIntervalStart,
				tmp_2.b_dt_end c_BillingIntervalEnd,
				tmp_2.s_dt_start c_SubscriptionStart,
				tmp_2.s_dt_end c_SubscriptionEnd,
				tmp_2.dt_cre_start c_DiscountIntervalStart,
				tmp_2.dt_cre_end c_DiscountIntervalEnd,
				tmp_2.pc_dt_start c_DiscountIntervalSubStart,
				tmp_2.pc_dt_end c_DiscountIntervalSubEnd
				from
				 tempGroupDiscount td
				 INNER JOIN t_prop_processing proc1 on proc1.id_group_sub = td.id_sub
				 INNER JOIN tmp_discount_2 tmp_2 on tmp_2.id_acc = proc1.id_group_sub
				