
CREATE OR REPLACE
PROCEDURE UpdateApproval(
    idApproval INT,
    ApproverId  INT,
    ChangeModificationDate DATE,
    ItemDisplayName VARCHAR2 DEFAULT '',
    COMMENT         VARCHAR2 DEFAULT '',
    Status OUT INT )
AS
  SQLError INT;
BEGIN
  UPDATE t_approvals
    SET c_ApproverId = ApproverId, c_ChangeLastModifiedDate = ChangeModificationDate, c_ItemDisplayName = ItemDisplayName
  WHERE t_approvals.id_approval = idApproval;
	
  SQLError := SQLCODE;
  IF (SQLError <> 0) THEN
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
	 