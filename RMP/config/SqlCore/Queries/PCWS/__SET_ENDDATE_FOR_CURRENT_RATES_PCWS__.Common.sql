
        UPDATE %%TABLE_NAME%% SET tt_end=dbo.SubtractSecond(%%TT_START%%) WHERE (tt_end>%%TT_START%% OR tt_end is null) AND id_sched=%%ID_SCHED%%
      