
insert into t_account_ancestor
(id_ancestor, id_descendent, num_generations, b_children, vt_start, vt_end, tx_path)
values (1,1,0,'N',to_date('01/01/1753 00:00','dd/mm/yyyy hh24:mi'),to_date('01/01/2038 00:00','dd/mm/yyyy hh24:mi'),'/');

insert into t_account_ancestor
(id_ancestor, id_descendent, num_generations, b_children, vt_start, vt_end, tx_path)
values (-1,-1,0,'N',to_date('01/01/1753 00:00','dd/mm/yyyy hh24:mi'),to_date('01/01/2038 00:00','dd/mm/yyyy hh24:mi'),'/');

