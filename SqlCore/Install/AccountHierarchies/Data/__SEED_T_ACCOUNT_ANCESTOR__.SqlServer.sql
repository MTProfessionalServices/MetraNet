
insert into t_account_ancestor
(id_ancestor, id_descendent, num_generations, b_children, vt_start, vt_end, tx_path)
values (1,1,0,'N',dbo.MTMinDate(),dbo.MTMaxDate(),'/')

insert into t_account_ancestor
(id_ancestor, id_descendent, num_generations, b_children, vt_start, vt_end, tx_path)
values (-1,-1,0,'N',dbo.MTMinDate(),dbo.MTMaxDate(),'/')

