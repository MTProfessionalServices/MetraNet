
        update t_pl_map set
          id_pricelist = %%ID_PL%%
        where id_pi_instance = %%ID_PI%% and id_paramtable = %%ID_PTD%% AND id_sub is NULL
      