
      CREATE or replace PROCEDURE ApprovePayments
			(p_id_interval int,
			p_id_acc int,
			p_status out int)
			AS
			p_id_enum int;
			BEGIN
			  p_status := -1;

				SELECT id_enum_data into p_id_enum 
				FROM
				  t_enum_data
				WHERE
				  upper(nm_enum_data) = upper('metratech.com/paymentserver/PaymentStatus/Pending');

				UPDATE t_pv_ps_paymentscheduler
				SET 
				  c_currentstatus = p_id_enum
				where
					c_originalaccountid = p_id_acc And c_originalintervalid = p_id_interval;

  
				p_status := 0;

				exception
					when no_data_found then
   								p_status := -1;
					when others then
									p_status := -1;

			END;
      