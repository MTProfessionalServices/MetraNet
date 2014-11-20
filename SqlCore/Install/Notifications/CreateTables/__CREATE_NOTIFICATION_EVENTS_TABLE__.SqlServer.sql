CREATE TABLE t_notification_events
(
	id_notification_event bigint NOT NULL,
	id_notification_event_type int NOT NULL,
	notification_event_prop_values nvarchar(4000) NOT NULL,
	id_partition int NULL,
	dt_crt datetime NOT NULL,
  CONSTRAINT PK_t_Notification_Events PRIMARY KEY CLUSTERED(id_notification_event ASC),
  CONSTRAINT FK_t_Notification_Events FOREIGN KEY (id_notification_event_type) REFERENCES t_Notification_Event_Types(id_notification_event_type)
)