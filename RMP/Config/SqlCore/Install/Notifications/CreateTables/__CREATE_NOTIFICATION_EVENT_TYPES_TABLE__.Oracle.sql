CREATE TABLE t_notification_event_types
(
	id_notification_event_type number(10) NOT NULL,
	notification_event_name nvarchar2(255) NOT NULL,
  CONSTRAINT PK_t_Notification_Event_Types PRIMARY KEY (id_notification_event_type))
