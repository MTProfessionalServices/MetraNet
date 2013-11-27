
       CREATE PROCEDURE GetNonBillAccountsWithBalance
						(@BillGroup integer,
						 @strNamespace nvarchar(2000))
		as
		declare @return_code int

        CREATE TABLE #tmp_acc_amounts
          (tmp_seq int IDENTITY,
          namespace nvarchar(40),
          id_interval int,
          id_acc int,
          invoice_currency nvarchar(10),
          payment_ttl_amt numeric(22,10),
          postbill_adj_ttl_amt numeric(22,10),
          ar_adj_ttl_amt numeric(22,10),
          previous_balance numeric(22,10),
          tax_ttl_amt numeric(22,10),
          current_charges numeric(22,10),
          id_payer int,
          id_payer_interval int)
        CREATE TABLE #tmp_prev_balance
        ( id_acc int,
          previous_balance numeric(22,10))
        CREATE TABLE #tmp_adjustments
        ( id_acc int,
          PrebillAdjAmt numeric(22,10),
          PrebillTaxAdjAmt numeric(22,10),
          PostbillAdjAmt numeric(22,10),
          PostbillTaxAdjAmt numeric(22,10))

        -- Create the driver table with all id_accs
		CREATE TABLE #tmp_all_accounts
		(tmp_seq int IDENTITY,
		 id_acc int NOT NULL,
		 namespace nvarchar(80) NOT NULL)

        EXEC MTSP_INSERTINVOICE_BALANCES @BillGroup, 1, NULL, @return_code OUTPUT

        SELECT

          tacc.id_acc as AccountID,

          am.nm_login as AccountName,

          amar.ExtAccount as ExtAccountID,
          amar.ExtNamespace as ExtAccountNamespace,

          tacc.id_payer as PayerID,
          amp.nm_login as PayerName,

          ampar.ExtAccount as ExtPayerID,
          ampar.ExtNamespace as ExtPayerNamespace,

          tacc.id_payer_interval as PayerInterval,

          ISNULL(tpb.previous_balance, 0.0)
            + payment_ttl_amt
            + ar_adj_ttl_amt
            + ISNULL(tadj.PostbillAdjAmt, 0.0) as BalanceForward,

          tacc.current_charges
            + ISNULL(tadj.PrebillAdjAmt,0)
            + tax_ttl_amt as CurrentCharges,

          tacc.invoice_currency as Currency

        FROM #tmp_acc_amounts tacc
        LEFT OUTER JOIN #tmp_prev_balance tpb ON tpb.id_acc = tacc.id_acc
        LEFT OUTER JOIN #tmp_adjustments tadj ON tadj.id_acc = tacc.id_acc
        LEFT OUTER JOIN t_account_mapper am with(index(t_account_mapper_idx1)) ON am.id_acc = tacc.id_acc and am.nm_space = @strNamespace 
        LEFT OUTER JOIN VW_AR_ACC_MAPPER amar ON amar.id_acc = tacc.id_acc
        LEFT OUTER JOIN t_account_mapper amp with(index(t_account_mapper_idx1)) ON amp.id_acc = tacc.id_payer and amp.nm_space = @strNamespace
        LEFT OUTER JOIN VW_AR_ACC_MAPPER ampar ON ampar.id_acc = tacc.id_payer
        WHERE (tacc.id_acc != tacc.id_payer)

        DROP TABLE #tmp_acc_amounts
        DROP TABLE #tmp_prev_balance
        DROP TABLE #tmp_adjustments
        DROP TABLE #tmp_all_accounts
        return 0
        