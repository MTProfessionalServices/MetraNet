CREATE TABLE t_notification_event_types
(
	id_notification_event_type int NOT NULL,
	notification_event_name nvarchar(255) NOT NULL,
  CONSTRAINT PK_t_Notification_Event_Types PRIMARY KEY CLUSTERED(id_notification_event_type ASC))
