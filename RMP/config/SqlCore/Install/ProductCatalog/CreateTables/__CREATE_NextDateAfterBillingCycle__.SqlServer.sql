
		create function NextDateAfterBillingCycle(@id_acc as int,@datecheck as datetime) returns datetime
		as
		begin
			return(
			select DATEADD(s, 1, tpc.dt_end)
	    from
        t_payment_redirection redir
	      inner join t_acc_usage_cycle auc
	      on auc.id_acc = redir.id_payer
	      inner join t_pc_interval tpc
	      on tpc.id_cycle = auc.id_usage_cycle
	      where redir.id_payee = @id_acc
	      AND
	      tpc.dt_start <= @datecheck AND @datecheck <= tpc.dt_end
	      AND
	      redir.vt_start <= @datecheck AND @datecheck <= redir.vt_end
		)
		end
	