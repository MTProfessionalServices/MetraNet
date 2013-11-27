
			create or replace
procedure InsertPaymentPendingTrans (
			p_acct_id IN int,
			p_payment_instr_id IN nvarchar2,
			p_description IN nvarchar2,
			p_currency IN nvarchar2,
			p_amount  IN number,
			p_trydunning IN char,
			p_dt_create IN date,
			p_dt_execute IN date,
			p_id_pending_payment OUT int)
			as
			   
      begin
         p_id_pending_payment := seq_t_pending_payment.nextval;
         
			INSERT INTO t_pending_payment_trans
				(
          id_pending_payment,
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
					p_id_pending_payment, null, p_acct_id, p_payment_instr_id, p_description, p_currency, p_amount, 0, p_trydunning, 1, p_dt_create, p_dt_execute
				);
        
      
      
			
      
      end;
	