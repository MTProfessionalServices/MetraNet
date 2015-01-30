SELECT
failed.c__ControlNumber as ControlId,
reverse(left(reverse(failed_state.nm_enum_data), charindex('/', reverse(failed_state.nm_enum_data)) -1)) as State,
failed.c__ErrorCode as ErrorCode,
failed.c_CreationDate as CreationDate,
failed.c__BatchId as BatchId,
ISNULL(failed.c__TrackingId,'') as TrackingId
FROM t_be_cor_fil_invocationreco failed
INNER JOIN t_enum_data failed_state ON id_enum_data = failed.c__State AND failed_state.nm_enum_data = 'metratech.com/FileLandingService/EInvocationState/FAILED'
WHERE failed.c_CreationDate > @LAST_RUN_DATE