
        update t_effectivedate set
          n_begintype = %%BEGIN_TYPE%%,
          dt_start = %%START_DATE%%,
          n_beginoffset = %%BEGIN_OFFSET%%,
          n_endtype = %%END_TYPE%%,
          dt_end = %%END_DATE%%,
          n_endoffset = %%END_OFFSET%%
        where id_eff_date = %%ID_EFF_DATE%%
      