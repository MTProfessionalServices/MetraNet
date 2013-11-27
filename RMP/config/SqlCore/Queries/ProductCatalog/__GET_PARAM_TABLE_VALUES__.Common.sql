
           SELECT * 
           FROM %%TABLE_NAME%% 
           WHERE id_sched=%%SCHEDULE%% AND %%REFDATE%% >= tt_start AND (%%REFDATE%% <= tt_end OR tt_end is NULL)
           ORDER BY n_order
           