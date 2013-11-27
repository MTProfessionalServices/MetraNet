
CREATE PROC InsertAuditEvent2
	@id_userid int,
	@id_event int,
	@id_entity_type int,
	@id_entity int,
	@dt_timestamp datetime,
	@tx_details nvarchar(4000),
	@id_audit int = NULL,
	@tx_logged_in_as nvarchar(50) = NULL,
	@tx_application_name nvarchar(50) = NULL,
	@id_audit_out int out
AS
BEGIN
	DECLARE @new_id int
	IF @id_audit IS NULL OR @id_audit = 0
		EXEC GetCurrentId 'id_audit', @new_id out
	ELSE
		SET @id_audit_out = @id_audit

	EXEC InsertAuditEvent
		@id_userid           = @id_userid,
		@id_event            = @id_event,
		@id_entity_type      = @id_entity_type,
		@id_entity           = @id_entity,
		@dt_timestamp        = @dt_timestamp,
		@id_audit            = @new_id,
		@tx_details          = @tx_details,
		@tx_logged_in_as     = @tx_logged_in_as,
		@tx_application_name = @tx_application_name

	SET @id_audit_out = @new_id
END