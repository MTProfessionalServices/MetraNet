
create or replace
procedure AddArchiveQueueProcessStatus(p_statusData varchar2)
authid current_user 
as  
pragma autonomous_transaction; 
begin   
  EXECUTE IMMEDIATE 'INSERT INTO T_ARCHIVE_QUEUE_PROC_AUDIT values (current_timestamp(3), ''' || p_statusData || ''')';
  COMMIT;
end;
    