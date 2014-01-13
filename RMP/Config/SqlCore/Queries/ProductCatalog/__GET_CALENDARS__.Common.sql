
        SELECT t_calendar.id_calendar as id_prop, t_vw_base_props.nm_name, 
            t_vw_base_props.nm_desc, t_calendar.n_timezoneoffset, t_calendar.b_combinedweekend
        FROM t_vw_base_props JOIN
            t_calendar ON t_vw_base_props.id_prop = t_calendar.id_calendar and t_vw_base_props.id_lang_code = %%ID_LANG%%
      