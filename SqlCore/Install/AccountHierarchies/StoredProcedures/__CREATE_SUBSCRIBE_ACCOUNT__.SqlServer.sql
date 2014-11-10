
CREATE PROCEDURE subscribe_account(
   @id_acc              int,
   @id_po               int,
   @id_group            int,
   @sub_start           datetime,
   @sub_end             datetime,
   @systemdate          datetime
)
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @v_guid      uniqueidentifier
	DECLARE @curr_id_sub int
	DECLARE @maxdate     datetime

	SET @maxdate = dbo.MTMaxDate()

	IF @id_group IS NOT NULL
	BEGIN
		INSERT INTO #tmp_gsubmember (id_group, id_acc, vt_start, vt_end)
			VALUES (@id_group, @id_acc, @sub_start, @sub_end)
	END
	ELSE
	BEGIN
		EXEC GetCurrentID 'id_subscription', @curr_id_sub OUT
		SELECT @v_guid = NEWID()
		INSERT INTO #tmp_sub (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end)
			VALUES (@curr_id_sub, @v_guid, @id_acc, NULL, @id_po, @systemdate, @sub_start, @sub_end)
	END

END