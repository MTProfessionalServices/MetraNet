
/* ===========================================================

============================================================== */
SELECT COUNT(*) AS CONFCOUNT
FROM t_svc_audioconfcall
WHERE c_ConferenceId = %%CONFERENCE_ID%%
 