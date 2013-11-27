
        update t_rsched set 
          id_pt = %%ID_PT%%,
          id_eff_date = %%ID_EFFDATE%%,
          id_pricelist = %%ID_PL%%,
          id_pi_template = %%ID_TMPL%%,
          dt_mod = %%%SYSTEMDATE%%%
        where id_sched = %%ID_SCHED%%
      