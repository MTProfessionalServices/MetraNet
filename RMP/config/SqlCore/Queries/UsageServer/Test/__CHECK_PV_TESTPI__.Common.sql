
/* ===========================================================
============================================================== */
SELECT *  
FROM t_pv_testpi
WHERE c_timezoneID = %%TIME_ZONE_ID%% AND
      c_calendarCode = %%CALENDAR_CODE_ID%%
 