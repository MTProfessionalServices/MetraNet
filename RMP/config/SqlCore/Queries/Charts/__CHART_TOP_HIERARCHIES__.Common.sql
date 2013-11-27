
        select top %%NUMBER_OF_ACCOUNTS%% aa.id_ancestor as accountId, am.nm_login as category, count(*) as total
        from t_account_ancestor aa with(nolock)
        inner join t_account_mapper am on am.id_acc = aa.id_ancestor
        where aa.num_generations = 1
        group by aa.id_ancestor,
        am.nm_login
        order by total desc
      