
/* ===========================================================

============================================================== */
SELECT COUNT(*) AS CONFCOUNT
FROM t_svc_audioconfconnection
WHERE c_ConferenceId = %%CONFERENCE_ID%%
 