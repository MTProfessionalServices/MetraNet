DECLARE
  count_fg_from_partition INT;
  count_fg_from_filegroups INT;
BEGIN
  SELECT COUNT(ID_PARTITION) INTO count_fg_from_partition FROM t_partition tp; 
  
  SELECT COUNT(DISTINCT TABLESPACE_NAME) INTO count_fg_from_filegroups FROM dba_tab_partitions
   WHERE table_owner = USER AND TABLESPACE_NAME <> USER;
  
  IF count_fg_from_partition <> count_fg_from_filegroups THEN
  OPEN :rc FOR
		SELECT 'N' AS check_usage_filegroups FROM DUAL;
	ELSE
  OPEN :rc FOR
		SELECT 'Y' AS check_usage_filegroups FROM DUAL;
  END IF;
END;