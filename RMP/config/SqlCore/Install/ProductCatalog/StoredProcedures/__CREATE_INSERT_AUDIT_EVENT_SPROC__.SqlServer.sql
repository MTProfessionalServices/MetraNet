
  create proc InsertAuditEvent @id_userid int, @id_event int, @id_entity_type int, @id_entity int, @dt_timestamp datetime, @id_audit int, @tx_details nvarchar(4000), @tx_logged_in_as nvarchar(50) = NULL, @tx_application_name nvarchar(50) = NULL  as
  begin
	insert into t_audit (id_audit,
						id_Event,
						id_UserId,
						id_entitytype,
						id_entity,
						tx_logged_in_as,
						tx_application_name,
						dt_crt)
	values (@id_audit, 
			@id_event,
			@id_userid, 
			@id_entity_type, 
			@id_entity, 
			@tx_logged_in_as, 
			@tx_application_name, 
			@dt_timestamp)
  if (@tx_details is not null) and (@tx_details != '')
  begin
  insert into t_audit_details values(@id_audit,@tx_details)
  end
  end
		