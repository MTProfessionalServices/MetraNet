
               update t_pl_map set
                        id_pricelist = %%ID_PL%%,
                        b_canICB = '%%CAN_ICB%%'
                      where id_pi_instance = %%ID_PI%% and id_paramtable = %%ID_PTD%% and id_po = %%ID_PO%%
			