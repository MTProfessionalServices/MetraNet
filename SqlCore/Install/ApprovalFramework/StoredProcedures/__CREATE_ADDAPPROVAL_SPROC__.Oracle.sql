
CREATE OR REPLACE
PROCEDURE AddApproval(
    SubmittedDate DATE,
    SubmitterId NUMBER,
    ChangeType  VARCHAR2,
    ChangeDetails BLOB,
    ItemDisplayName             VARCHAR2 DEFAULT '',
    UniqueItemId                VARCHAR2,
    user_comment                VARCHAR2 DEFAULT '',
    CurrentState                VARCHAR,
    PartitionId                 NUMBER DEFAULT 1,
    AllowMultiplePendingChanges NUMBER,
    IdApproval OUT INT,
    Status OUT INT )
AS
  PendingChangeCount INT;
  SQLError           INT;
BEGIN
  IF (AllowMultiplePendingChanges <> 1) THEN
    BEGIN
      SELECT COUNT(*) INTO PendingChangeCount FROM t_approvals
      WHERE
        c_changetype                 = ChangeType
      AND c_UniqueItemId             = UniqueItemId
      AND c_CurrentState             = 'Pending';
      IF (NVL(PendingChangeCount,0) <> 0) THEN
        BEGIN
          IdApproval := 0 ;
          Status     := -1;
          /* Multiple pending changes are not allowed for this change type */
          RETURN;
        END ;
      END IF;
    END;
  END IF;
  INSERT INTO t_approvals (id_approval, c_SubmittedDate, c_SubmitterId, c_ChangeType, c_ChangeDetails, c_ApproverId, c_ChangeLastModifiedDate,
        c_ItemDisplayName, c_UniqueItemId, c_Comment, c_CurrentState, c_PartitionId)
      VALUES
      (SEQ_T_APPROVAL.NextVal, SubmittedDate, SubmitterId, ChangeType, ChangeDetails, NULL, NULL, ItemDisplayName,
        UniqueItemId, user_comment, CurrentState, PartitionId);
  SQLError    := SQLCODE;
  IF SQLError <> 0 THEN
    BEGIN
      Status := -1;
      RETURN;
    END;
  ELSE
    BEGIN
      Status := 0;
      SELECT SEQ_T_APPROVAL.CURRVAL INTO IdApproval FROM dual;
    END;
  END IF;
END;

	 