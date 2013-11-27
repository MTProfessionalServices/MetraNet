
        UPDATE t_calendar
            SET n_timezoneoffset = %%TZOFFSET%%, b_combinedweekend = '%%BCOMBWEEKEND%%'
        WHERE id_calendar = %%ID_CAL%%
      