SELECT
rejected_files.c__Name as Name,
reverse(left(reverse(rejected_state.nm_enum_data), charindex('/', reverse(rejected_state.nm_enum_data)) -1)) as State,
reverse(left(reverse(reject_reason.nm_enum_data), charindex('/', reverse(reject_reason.nm_enum_data)) -1)) as RejectReason,
c_CreationDate as CreationDate
FROM t_be_cor_fil_filebe rejected_files
INNER JOIN t_enum_data rejected_state ON id_enum_data = rejected_files.c__State AND rejected_state.nm_enum_data = 'metratech.com/FileLandingService/eFileState/REJECTED'
INNER JOIN t_enum_data reject_reason ON reject_reason.id_enum_data = rejected_files.c__RejectReason
WHERE rejected_files.c_CreationDate > @LAST_RUN_DATE