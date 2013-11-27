
 CREATE OR REPLACE
PROCEDURE IsApprovalPending(
    ChangeType   VARCHAR2,
    UniqueItemId VARCHAR2,
    Status OUT INT)
AS
  PendingApprovalCount INT;
BEGIN
  Status := 0;
  SELECT NVL(COUNT(*),0) INTO PendingApprovalCount
    FROM t_approvals
  WHERE
    c_changetype = ChangeType AND c_UniqueItemId = UniqueItemId AND c_CurrentState = 'Pending';
  IF PendingApprovalCount > 0 THEN Status := 1 ;
  END IF;
END;
	 