CREATE TABLE t_notification_event_consumers
(
	id_not_evnt_consumer number(20) NOT NULL,
	id_notification_event number(20) NOT NULL,
	id_acc number(10) NOT NULL,
	dt_crt date NOT NULL,
  CONSTRAINT PK_t_Notification_Evnt_Consmrs PRIMARY KEY (id_not_evnt_consumer),
  CONSTRAINT FK_t_Notification_Evnt_Consmrs FOREIGN KEY (id_notification_event) REFERENCES t_Notification_Events(id_notification_event)
)