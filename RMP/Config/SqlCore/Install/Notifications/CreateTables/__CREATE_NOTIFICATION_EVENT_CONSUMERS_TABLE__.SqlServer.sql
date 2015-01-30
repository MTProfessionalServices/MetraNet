CREATE TABLE t_notification_event_consumers
(
	id_not_evnt_consumer bigint NOT NULL,
	id_notification_event bigint NOT NULL,
	id_acc int NOT NULL,
	dt_crt datetime NOT NULL,
  CONSTRAINT PK_t_Notification_Event_Consumers PRIMARY KEY CLUSTERED(id_not_evnt_consumer ASC),
  CONSTRAINT FK_t_Notification_Event_Consumers FOREIGN KEY (id_notification_event) REFERENCES t_Notification_Events(id_notification_event)
)