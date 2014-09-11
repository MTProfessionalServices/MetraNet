
			select top 1 aa3.id_descendent id_ancestor, aa3.tx_path hierarchy_path
			from
			t_account_ancestor aa1
			inner join t_account_ancestor aa2 on aa1.id_descendent=aa2.id_descendent and aa1.vt_start <= aa2.vt_end and aa2.vt_start <= aa1.vt_end
			inner join t_account_ancestor aa3 on aa3.id_descendent=aa2.id_ancestor and aa1.vt_start <= aa3.vt_end and aa3.vt_start <= aa1.vt_end and aa3.vt_start <= aa2.vt_end and aa2.vt_start <= aa3.vt_end
			where exists
			(
						select 1 from t_acc_usage au
						where aa1.id_descendent=au.id_payee and au.id_acc = @idAcc
						and au.dt_session between aa1.vt_start and aa1.vt_end 
            and %%TIME_PREDICATE%%
			)
			and
			aa1.id_ancestor=1
			and
			aa3.id_ancestor=1
			group by aa3.id_descendent, aa3.tx_path, aa3.vt_start, aa3.vt_end, aa3.num_generations
			order by  count(*) desc, aa3.num_generations desc
			option (force order)  
      