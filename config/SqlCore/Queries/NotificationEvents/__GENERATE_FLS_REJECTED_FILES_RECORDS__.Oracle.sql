SELECT rejected_files.c__Name Name, 
SUBSTR(rejected_state.nm_enum_data, INSTR(rejected_state.nm_enum_data,'/',-1)+1) State, 
SUBSTR(reject_reason.nm_enum_data, INSTR(reject_reason.nm_enum_data,'/',-1)+1) RejectReason, 
rejected_files.c_CreationDate CreationDate 
FROM t_be_cor_fil_filebe rejected_files 
INNER JOIN t_enum_data rejected_state ON id_enum_data = rejected_files.c__State AND rejected_state.nm_enum_data = 'metratech.com/FileLandingService/eFileState/REJECTED' 
INNER JOIN t_enum_data reject_reason ON reject_reason.id_enum_data = rejected_files.c__RejectReason 
WHERE rejected_files.c_CreationDate > :LAST_RUN_DATE