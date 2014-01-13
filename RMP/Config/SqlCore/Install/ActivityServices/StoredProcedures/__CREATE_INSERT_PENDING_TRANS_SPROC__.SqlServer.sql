
			create proc InsertPaymentPendingTrans
			@p_acct_id int,
			@p_payment_instr_id nvarchar(144),
			@p_description nvarchar(200),
			@p_currency nvarchar(20),
			@p_amount decimal(16,2),
			@p_trydunning char(1),
			@p_dt_create datetime,
			@p_dt_execute datetime,
			@p_id_pending_payment int OUTPUT
			as
			
			INSERT INTO t_pending_payment_trans
				(
					id_interval,
					id_acc,
					id_payment_instrument,
					nm_description,
					nm_currency,
					n_amount,
					b_captured,
					b_try_dunning,
					b_scheduled,
					dt_create,
					dt_execute
				)
				VALUES
				(
					null, @p_acct_id, @p_payment_instr_id, @p_description, @p_currency, @p_amount, 0, @p_trydunning, 1, @p_dt_create, @p_dt_execute
				)
			select @p_id_pending_payment = @@identity
	