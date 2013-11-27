
        CREATE OR REPLACE PROCEDURE GetNonBillAccountsWithBalance
						(p_BillGroup int,
						 p_strNamespace nvarchar2,
						 p_cur out sys_refcursor)
		as
			return_code int;
		begin
			MTSP_INSERTINVOICE_BALANCES(p_BillGroup, 1, NULL, return_code);

			OPEN p_cur FOR SELECT
				tacc.id_acc as AccountID,
				am.nm_login as AccountName,
				amar.ExtAccount as ExtAccountID,
				amar.ExtNamespace as ExtAccountNamespace,
				tacc.id_payer as PayerID,
				amp.nm_login as PayerName,
				ampar.ExtAccount as ExtPayerID,
				ampar.ExtNamespace as ExtPayerNamespace,
				tacc.id_payer_interval as PayerInterval,
				nvl(tpb.previous_balance, 0.0)
					+ tacc.payment_ttl_amt
					+ tacc.ar_adj_ttl_amt
					+ nvl(tadj.PostbillAdjAmt, 0.0) as BalanceForward,
				tacc.current_charges
					+ nvl(tadj.PrebillAdjAmt,0)
					+ tacc.tax_ttl_amt as CurrentCharges,
				tacc.invoice_currency as Currency
				FROM tmp_acc_amounts tacc
				LEFT OUTER JOIN tmp_prev_balance tpb ON tpb.id_acc = tacc.id_acc
				LEFT OUTER JOIN tmp_adjustments tadj ON tadj.id_acc = tacc.id_acc
				LEFT OUTER JOIN t_account_mapper am ON am.id_acc = tacc.id_acc and am.nm_space = p_strnamespace
				LEFT OUTER JOIN VW_AR_ACC_MAPPER amar ON amar.id_acc = tacc.id_acc
				LEFT OUTER JOIN t_account_mapper amp ON amp.id_acc = tacc.id_payer and amp.nm_space = p_strnamespace
				LEFT OUTER JOIN VW_AR_ACC_MAPPER ampar ON ampar.id_acc = tacc.id_payer
				WHERE (tacc.id_acc != tacc.id_payer);
		end GetNonBillAccountsWithBalance;
        