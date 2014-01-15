
 begin
    UPDATE %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch tmp SET status = 
     /* 
      check possible Foreign Key constraint violations early,
      and also some business rule violations
      -515899365 = KIOSK_ERR_ACCOUNT_NOT_FOUND
      -2147483607 = E_FAIL
      MT_OWNED_ACCOUNT_NOT_SUBSCRIBER  -486604718
     */
    (select CASE WHEN 
    (owner.id_acc IS NULL OR owned.id_acc IS NULL) THEN -515899365 ELSE
    CASE WHEN (atype.name = 'SYSTEMACCOUNT') THEN -486604718 ELSE /* Except for system accounts, any account can be owned by any other account. */
    CASE WHEN ed.id_enum_data IS NULL THEN -2147483607 ELSE 0
    END
    END
    END
    FROM %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch ar
    LEFT OUTER JOIN t_account owner ON owner.id_acc = ar.id_owner
    LEFT OUTER JOIN t_account owned ON owned.id_acc = ar.id_owned
    LEFT OUTER JOIN t_account_type atype ON owned.id_type = atype.id_type
    LEFT OUTER JOIN t_enum_data ed ON ed.id_enum_data = ar.id_relation_type
    WHERE ar.status = 0
    and tmp.id_owner = ar.id_owner
    and tmp.id_owned = ar.id_owned
    );
 
    /* Plug here business rule violation checks. */
      UPDATE %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch ar SET status = 
     /* 
      MT_OWNERSHIP_START_DATE_AFTER_END_DATE = 0xE2FF0050; (-486604720)
      MT_OWNERSHIP_PERCENT_OUT_OF_RANGE = 0xE2FF0051; (-486604719)
      MT_CAN_NOT_OWN_SELF = 0xE2FF0053; (-486604717)
      MT_OWNERSHIP_START_DATE_NOT_SET = 0xE2FF0054; (-486604716)
      MT_OWNERSHIP_END_DATE_NOT_SET = 0xE2FF0055; (-486604715)
     */
    CASE WHEN (ar.vt_start >= ar.vt_end)  THEN -486604720 ELSE
    CASE WHEN  ((ar.n_percent < 0) OR (ar.n_percent > 100)) THEN -486604719 ELSE
    CASE WHEN  (ar.id_owner = ar.id_owned) THEN -486604717 ELSE
    CASE WHEN  (ar.vt_start IS NULL) THEN -486604716 ELSE
    CASE WHEN  (ar.vt_end IS NULL) THEN -486604715
    ELSE 0
    END END END END END
    WHERE status = 0;
      
 
INSERT INTO t_acc_ownership(id_owner, id_owned, id_relation_type, n_percent,  vt_start, vt_end, tt_start, tt_end) 
SELECT 
ar.id_owner, ar.id_owned,     ar.id_relation_type, ar.n_percent, 
(ar.vt_end + INTERVAL '1' SECOND) AS     vt_start,   own.vt_end, 
ar.tt_start as tt_start, 
MTMaxDate()   AS tt_end
FROM t_acc_ownership own
INNER JOIN %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch   ar
ON own.id_owner   =     ar.id_owner AND   own.id_owned = ar.id_owned
AND   own.vt_start < ar.vt_start AND own.vt_end >     ar.vt_end   and   own.tt_end = MTMaxDate()
WHERE
ar.status=0;
 
 
/*  Valid time update becomes bi-temporal insert and update */
INSERT INTO t_acc_ownership(id_owner, id_owned, id_relation_type, n_percent,  vt_start, vt_end, tt_start, tt_end) 
SELECT own.id_owner, own.id_owned, own.id_relation_type, own.n_percent, 
own.vt_start, (ar.vt_start - INTERVAL '1' SECOND) AS vt_end, ar.tt_start AS tt_start, MTMaxDate() AS tt_end 
FROM t_acc_ownership own
INNER JOIN %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch ar
ON own.id_owner = ar.id_owner AND own.id_owned = ar.id_owned
AND own.vt_start < ar.vt_start AND own.vt_end >= ar.vt_start AND own.tt_end = MTMaxDate()
WHERE
ar.status=0;
 
 
UPDATE t_acc_ownership own SET tt_end = (select ar.tt_start 
FROM %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch ar
where own.id_owner = ar.id_owner AND own.id_owned = ar.id_owned
AND own.vt_start < ar.vt_start AND own.vt_end >= ar.vt_start AND own.tt_end = MTMaxDate()
and ar.status=0)
where exists
(select 1 from %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch ar
where own.id_owner = ar.id_owner AND own.id_owned = ar.id_owned
AND own.vt_start < ar.vt_start AND own.vt_end >= ar.vt_start AND own.tt_end = MTMaxDate()
and ar.status=0); 
 
/*  Valid time update becomes bi-temporal insert (of the modified existing history into the past history) and update (of the modified existing history) */
INSERT INTO t_acc_ownership(id_owner, id_owned, id_relation_type, n_percent,  vt_start, vt_end, tt_start, tt_end)
SELECT  own.id_owner, own.id_owned, own.id_relation_type, own.n_percent, (ar.vt_end + INTERVAL '1' SECOND) AS vt_start, own.vt_end, ar.tt_start AS tt_start, MTMaxDate() AS tt_end 
FROM t_acc_ownership own
INNER JOIN %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch ar
ON own.id_owner = ar.id_owner AND own.id_owned = ar.id_owned
AND own.vt_start <= ar.vt_end AND own.vt_end > ar.vt_end AND own.tt_end = MTMaxDate()
WHERE
ar.status=0;
 
UPDATE t_acc_ownership own SET tt_end = (select ar.tt_start 
FROM %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch ar
where own.id_owner = ar.id_owner AND own.id_owned = ar.id_owned
AND own.vt_start <= ar.vt_end AND own.vt_end > ar.vt_end AND own.tt_end = MTMaxDate()
and
ar.status=0)
where exists (
select 1 
FROM %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch ar
where own.id_owner = ar.id_owner AND own.id_owned = ar.id_owned
AND own.vt_start <= ar.vt_end AND own.vt_end > ar.vt_end AND own.tt_end = MTMaxDate()
and
ar.status=0); 
 
/*  Now we delete any interval contained entirely in the interval we are deleting. */
/*  Transaction table delete is really an update of the tt_end */
/*    [----------------]                 (interval that is being modified) */
/*  [------------------------]           (interval we are deleting) */
 
UPDATE t_acc_ownership own SET tt_end = (select ar.tt_start
FROM %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch ar
where own.id_owner = ar.id_owner AND own.id_owned = ar.id_owned
AND own.vt_start >= ar.vt_start AND own.vt_end <= ar.vt_end AND own.tt_end = MTMaxDate()
and
ar.status=0)
where exists
(
select 1
FROM %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch ar
where own.id_owner = ar.id_owner AND own.id_owned = ar.id_owned
AND own.vt_start >= ar.vt_start AND own.vt_end <= ar.vt_end AND own.tt_end = MTMaxDate()
and
ar.status=0);
end;
        