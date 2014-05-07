SELECT 0 as BATCHID, 
GETUTCDATE() AS "DATE",
to_char(GETUTCDATE(), 'dd/mm/yyyy hh24:mi:ss') AS "TIME",
0 as "TIME DIFF"
FROM DUAL