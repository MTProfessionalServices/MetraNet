CREATE GLOBAL TEMPORARY TABLE TMP_REDIR
(
  Payee NUMBER(10,0),
  NewPayer NUMBER(10,0),
  OldPayer NUMBER(10,0),
  BillRangeStart DATE,
  BillRangeEnd DATE,
  NewStart DATE,
  NewEnd DATE,
  OldStart DATE,
  OldEnd DATE,
  NewRangeInsideOld CHAR(1 BYTE)
) ON COMMIT PRESERVE ROWS
