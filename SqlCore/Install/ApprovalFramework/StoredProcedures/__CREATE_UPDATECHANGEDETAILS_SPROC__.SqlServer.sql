

      CREATE PROCEDURE UpdateChangeDetails
      @id_approval INT,
      @ChangeDetails varbinary(max),
      @ChangeModificationDate DATETIME,
      @Comment varchar(255) = '',
      @status INT OUTPUT
      
      AS
BEGIN	
	      SET NOCOUNT ON
              Declare @SQLError int

              UPDATE t_approvals 
              SET c_ChangeDetails = @ChangeDetails, 
                  c_ChangeLastModifiedDate = @ChangeModificationDate
	      /* ,c_Comment = @Comment */
	      WHERE id_approval = @id_approval
      
           SELECT @SQLError = @@ERROR
		

	   IF @SQLError <> 0 
	        BEGIN
			SELECT @Status = -1
                        RETURN -1
                END
       
            ELSE
		BEGIN
			SELECT @Status = 0
		END

END

	 