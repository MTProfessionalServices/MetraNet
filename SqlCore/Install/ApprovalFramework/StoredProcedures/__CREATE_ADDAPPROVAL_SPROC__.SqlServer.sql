CREATE PROCEDURE AddApproval
  @SubmittedDate DATETIME,
  @SubmitterId INT,
  @ChangeType VARCHAR(100),
  @ChangeDetails VARBINARY(MAX),
  @ItemDisplayName VARCHAR(100) = '',
  @UniqueItemId VARCHAR(100),
  @Comment VARCHAR(255) = '',
  @CurrentState VARCHAR(50),
  @PartitionId INT = 1,
  @AllowMultiplePendingChangesForThisChangeType BIT,
  @IdApproval INT OUTPUT,
  @Status INT OUTPUT
AS

  SET NOCOUNT ON

  DECLARE @PendingChangeCount  INT,
          @SQLError            INT
  
  IF (@AllowMultiplePendingChangesForThisChangeType <> 1)
  BEGIN
      SELECT @PendingChangeCount = COUNT(*)
      FROM   t_approvals
      WHERE  c_changetype = @ChangeType
             AND c_UniqueItemId = @UniqueItemId
             AND c_CurrentState = 'Pending'
      
      IF (ISNULL(@PendingChangeCount, 0) <> 0)
      BEGIN
          SELECT @IdApproval = 0 
          SELECT @Status = -1 /* Multiple pending changes are not allowed for this change type */ 
          RETURN
      END
  END

  BEGIN
    INSERT INTO t_approvals
      (
        c_SubmittedDate,
        c_SubmitterId,
        c_ChangeType,
        c_ChangeDetails,
        c_ApproverId,
        c_ChangeLastModifiedDate,
        c_ItemDisplayName,
        c_UniqueItemId,
        c_Comment,
        c_CurrentState,
        c_PartitionId
      )
    SELECT @SubmittedDate,
           @SubmitterId,
           @ChangeType,
           @ChangeDetails,
           NULL,
           NULL,
           @ItemDisplayName,
           @UniqueItemId,
           @Comment,
           @CurrentState,
           @PartitionId
  END

  SELECT @SQLError = @@ERROR
  IF @SQLError <> 0
  BEGIN
      SELECT @Status = -1 
      RETURN -1
  END
  ELSE
  BEGIN
      SELECT @Status = 0
      SELECT @IdApproval = SCOPE_IDENTITY()
  END
