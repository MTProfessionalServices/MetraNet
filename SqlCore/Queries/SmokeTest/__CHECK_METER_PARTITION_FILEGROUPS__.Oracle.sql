select DISTINCT TABLESPACE_NAME from dba_tab_partitions
where table_owner = USER and TABLESPACE_NAME = prtn_GetMeterPartFileGroupName()