

CREATE OR REPLACE
PROCEDURE DenyApproval(
    idApproval INT,
    COMMENT     VARCHAR2,
    status OUT INT)
AS
  SQLError INT;
BEGIN
  UPDATE t_approvals
  SET
    c_CurrentState = 'Dismissed',
    c_ChangeLastModifiedDate = sysdate
  WHERE
    id_approval = idApproval;
  SQLError     := SQLCODE;
  IF SQLError  <> 0 THEN
    BEGIN
      Status := -1;
      RETURN;
    END;
  ELSE
    BEGIN
      Status := 0;
    END;
  END IF;
END;
	 