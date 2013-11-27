
/* ===========================================================

============================================================== */
SELECT COUNT(*) AS CONFCOUNT
FROM t_svc_audioconffeature
WHERE c_ConferenceId = %%CONFERENCE_ID%%
 