
      select * from t_calendar_day wday, t_calendar_holiday hday
        where wday.id_calendar = %%CALENDAR_ID%%
        and n_weekday is NULL
        and wday.id_day = hday.id_day
      