
			select                 
                tbp.nm_display_name PITemplateDisplayName,
                ad.AdjustmentCreationDate,
                ad.c_Status Status,
                ad.amount Amount,
                ad.tx_desc Description,
                ad.PendingPostbillAdjAmt PendingPostbillAdjAmt,
                ad.PendingPrebillAdjAmt PendingPrebillAdjAmt,
                ad.PostbillAdjAmt PostbillAdjAmt,
                ad.PrebillAdjAmt PrebillAdjAmt,
                ad.id_sess SessionId,
                am.nm_login UserNamePayer, 
				        am2.nm_login UserNamePayee,
                ad.id_parent_sess ParentSessionId
			from 
			VW_NOTDELETED_ADJ_DETAILS ad
			inner join t_account_mapper am on ad.id_acc_payer = am.id_acc
			INNER JOIN t_namespace ns on ns.nm_space = am.nm_space 
				AND ns.tx_typ_space IN ('system_mps')
			INNER JOIN t_enum_data ed on %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%('metratech.com/accountcreation/contacttype/bill-to')
			inner join t_account_mapper am2 on ad.id_payee = am2.id_acc
			INNER JOIN t_namespace ns2 on ns2.nm_space = am2.nm_space 
				AND ns2.tx_typ_space IN ('system_mps')
			inner join t_base_props  tbp on ad.id_pi_template = tbp.id_prop
			WHERE
			/* CR 9689: if transaction interval is closed */
			/* then prebill adjustments can not be managed */
			((ad.IsPrebill = 'N' AND ad.n_adjustmenttype = 1 AND ad.CanManageAdjustments = 'Y')
			OR
			(ad.IsPrebill = 'Y' AND ad.CanManageAdjustments = 'Y'))
			AND ad.LanguageCode = %%ID_LANG%%
			