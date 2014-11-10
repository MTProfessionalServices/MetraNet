
          create index ancestor_idx1 on t_account_ancestor(num_generations);
          create index ancestor_idx2 on t_account_ancestor(id_ancestor,num_generations);
          create index ancestor_idx3 on t_account_ancestor(id_descendent,num_generations);
          create index ancestor_idx4 on t_account_ancestor(id_ancestor,id_descendent);

