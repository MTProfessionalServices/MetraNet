SELECT
failed.c__ControlNumber ControlId,
SUBSTR(failed_state.nm_enum_data,INSTR(failed_state.nm_enum_data,'/',-1)+1) State,
failed.c__ErrorCode ErrorCode,
failed.c_CreationDate CreationDate,
failed.c__BatchId BatchId,
NVL(failed.c__TrackingId,' ') TrackingId
FROM t_be_cor_fil_invocationreco failed
INNER JOIN t_enum_data failed_state ON id_enum_data = failed.c__State AND failed_state.nm_enum_data = 'metratech.com/FileLandingService/EInvocationState/FAILED'
WHERE failed.c_CreationDate > :LAST_RUN_DATE