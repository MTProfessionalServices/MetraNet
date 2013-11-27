
      select n_begintype,dt_start,n_beginoffset,n_endtype,dt_end,n_endoffset
      from t_effectivedate
      where id_eff_date = %%ID_EFFDATE%%
    