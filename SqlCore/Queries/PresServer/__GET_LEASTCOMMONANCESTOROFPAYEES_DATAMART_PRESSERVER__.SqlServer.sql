
		-- DATAMART enabled
		declare @ancestor int
		select @ancestor = id_dm_acc from t_dm_account where id_acc=1
		--where acc.vt_start <= %%END_DATE%% and acc.vt_end > %%BEGIN_DATE%%
		EXEC sp_executesql N'select id_acc id_ancestor from t_dm_account
		where id_dm_acc = 
		(
		select top 1 derived.id_dm_ancestor as id_dm_acc
		from
		(
		select aa.id_dm_ancestor, count(*) as cnt
		from
		t_dm_account_ancestor aa
		inner join t_dm_account a2 on a2.id_dm_acc=aa.id_dm_descendent
		where exists
		(
			select 1 from t_mv_payee_session au
			where a2.id_dm_acc=au.id_dm_acc and au.id_acc=%%ID_ACC%% and
 			%%TIME_PREDICATE%%
 			and au.dt_session between a2.vt_start and a2.vt_end 
		)
		group by aa.id_dm_ancestor
		) derived
		inner join t_dm_account_ancestor aa2 on aa2.id_dm_descendent=derived.id_dm_ancestor 
		and aa2.id_dm_ancestor=@ancestor1
		order by derived.cnt desc, aa2.num_generations desc
		)',
		N'@ancestor1 int',
		@ancestor1=@ancestor
		