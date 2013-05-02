
/* ===========================================================
Reset event start dates to the given date.
============================================================== */
/* update dt_activated in t_recevent */
UPDATE t_recevent
SET dt_activated = %%START_DATE%%
WHERE dt_deactivated IS NULL
 