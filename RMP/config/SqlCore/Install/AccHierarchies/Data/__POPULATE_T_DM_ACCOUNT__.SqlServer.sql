
insert into t_dm_account (id_dm_acc, id_acc, vt_start, vt_end)
values (1000, 1, dbo.mtmindate(), dbo.mtmaxdate())

insert into t_dm_account (id_dm_acc, id_acc, vt_start, vt_end)
values (1001, -1, dbo.mtmindate(), dbo.mtmaxdate())

insert into t_dm_account_ancestor (id_dm_ancestor, id_dm_descendent, num_generations)
values (1000, 1000, 0)

insert into t_dm_account_ancestor (id_dm_ancestor, id_dm_descendent, num_generations)
values (1001, 1001, 0)

