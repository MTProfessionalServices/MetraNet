
        update t_pi set 
          id_parent = %%ID_PARENT%%,
          nm_servicedef = '%%SERVICEDEF%%',
          nm_productview = '%%PRODUCTVIEW%%',
          b_constrain_cycle = '%%CONSTRAIN_CYCLE%%'
        where id_pi = %%ID_PI%%
    