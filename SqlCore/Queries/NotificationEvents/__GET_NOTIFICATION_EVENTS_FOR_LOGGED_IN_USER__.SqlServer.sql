SELECT 
	eventTypes.notification_event_name,
	events.notification_event_prop_values,
	events.dt_crt,
  ISNULL(events.id_partition, 1) as id_partition,
	events.id_notification_event,
	ISNULL(eventnamedesc.tx_desc, eventTypes.notification_event_name)  as 'localized_event_name',
  tamap.nm_login partition_name 
FROM t_notification_event_consumers consumers
INNER JOIN t_Notification_Events events ON events.id_notification_event = consumers.id_notification_event
INNER JOIN t_notification_event_types eventTypes ON eventTypes.id_notification_event_type = events.id_notification_event_type
LEFT OUTER JOIN t_enum_data edata on LOWER(edata.nm_enum_data) = CONCAT('ui/notificationeventtype/', LOWER(eventTypes.notification_event_name))
LEFT OUTER JOIN t_description eventnamedesc on eventnamedesc.id_desc = edata.id_enum_data and eventnamedesc.id_lang_code = %%ID_LANG%%
LEFT OUTER JOIN t_account_mapper tamap ON tamap.id_acc = events.id_partition and tamap.nm_space = 'mt' and tamap.id_acc != 1
WHERE consumers.id_acc = %%ID_ACC%%