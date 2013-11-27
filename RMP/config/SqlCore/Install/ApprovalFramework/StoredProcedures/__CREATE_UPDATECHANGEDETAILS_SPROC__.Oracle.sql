
CREATE OR REPLACE
PROCEDURE UpdateChangeDetails(
    idApproval INT,
    ChangeDetails BLOB,
    ChangeModificationDate DATE,
    user_Comment VARCHAR DEFAULT '',
    status OUT INT)
AS
  SQLError INT;

BEGIN
  UPDATE t_approvals  SET
    c_ChangeDetails          = ChangeDetails,
    c_ChangeLastModifiedDate = ChangeModificationDate
  WHERE id_approval = idApproval;
  
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

	 