SELECT 
	consumers.id_not_evnt_consumer as 'id',
	eventTypes.notification_event_name,
	events.notification_event_prop_values,
	events.dt_crt 
FROM t_notification_event_consumers consumers
INNER JOIN t_Notification_Events events ON events.id_notification_event = consumers.id_notification_event
INNER JOIN t_notification_event_types eventTypes ON eventTypes.id_notification_event_type = events.id_notification_event_type
WHERE consumers.id_acc = %%ID_ACC%%