
		select id_acc id_ancestor from t_dm_account
			where id_dm_acc = 
			(
			select derived.id_dm_ancestor as id_dm_acc
			from
			(
			select distinct aa.id_dm_ancestor
			from
			t_dm_account_ancestor aa
			inner join t_dm_account a2 on a2.id_dm_acc=aa.id_dm_descendent
			where exists
				(
				select 1 from t_mv_payee_session au
				where a2.id_dm_acc=au.id_dm_acc and au.id_acc = %%ID_ACC%%
				and au.dt_session between a2.vt_start and a2.vt_end 
				)
			) derived
			inner join t_dm_account_ancestor aa2 on aa2.id_dm_descendent = derived.id_dm_ancestor 
			inner join t_account acc on acc.id_acc = %%ID_ACC%%
			inner join t_account_type actype on acc.id_type = actype.id_type     
			inner join t_dm_account tda on tda.id_acc = (CASE WHEN actype.name = 'IndependentAccount' THEN acc.id_acc ELSE 1 END)
			and aa2.id_dm_ancestor = tda.id_dm_acc
			and ROWNUM = 1
			)		  
		