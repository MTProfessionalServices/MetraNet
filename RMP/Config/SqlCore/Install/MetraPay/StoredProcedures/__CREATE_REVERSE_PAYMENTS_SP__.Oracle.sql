
			CREATE or replace PROCEDURE ReversePayments
						(p_id_interval int,
						p_id_acc int,
						p_id_enum int,
						p_status OUT int)
			AS
			BEGIN
				p_status := -1;
	
									
				DELETE FROM t_acc_usage au 
				WHERE exists (SELECT 1 FROM t_pv_ps_paymentscheduler pv
				where
				au.id_sess = pv.id_sess and au.id_usage_interval = pv.id_usage_interval
				AND pv.c_originalintervalid = p_id_interval
				AND pv.c_currentstatus = p_id_enum)
				AND (au.id_acc = p_id_acc OR p_id_acc = -1);
				
				DELETE FROM t_pv_ps_paymentscheduler pv
				WHERE exists (SELECT 1 FROM t_acc_usage au
				where au.id_sess = pv.id_sess and au.id_usage_interval = pv.id_usage_interval
				AND (au.id_acc = p_id_acc OR p_id_acc = -1))
				AND pv.c_originalintervalid = p_id_interval
				AND pv.c_currentstatus = p_id_enum;
				
				p_status := 0;
			
				exception
					when others then
					p_status := -1;
				END;
      	