
/* ===========================================================

============================================================== */
SELECT c_MeteringStatus, c_MTErrorMesg
FROM mt_audioconfcall
WHERE c_conferenceId = %%CONFERENCE_ID%%
 