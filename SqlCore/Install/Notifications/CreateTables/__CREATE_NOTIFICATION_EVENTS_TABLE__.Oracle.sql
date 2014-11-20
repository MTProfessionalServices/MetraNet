CREATE TABLE t_notification_events
(
	id_notification_event number(20) NOT NULL,
	id_notification_event_type number(10) NOT NULL,
	notification_event_prop_values nvarchar2(2000) NOT NULL,
	id_partition number(10) NULL,
	dt_crt date NOT NULL,
  CONSTRAINT PK_t_Notification_Events PRIMARY KEY (id_notification_event),
  CONSTRAINT FK_t_Notification_Events FOREIGN KEY (id_notification_event_type) REFERENCES t_Notification_Event_Types(id_notification_event_type)
)