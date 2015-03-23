WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE
sequence_exists integer;
BEGIN
  BEGIN
    select count(*) into sequence_exists  from user_sequences where sequence_name = 'SEQ_T_MT_ID';
  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END;
  IF sequence_exists = 0
  THEN
  BEGIN
    execute immediate
    '    CREATE SEQUENCE seq_t_mt_id increment by 1 start with 1 minvalue 1 order nocache nocycle';
  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END;
end if;
end;  
/