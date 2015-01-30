select  id_notification_event_type, tx_desc As notification_event_name, notification_event_name as default_name from 
t_enum_data join t_notification_event_types on Lower(nm_enum_data) LIKE Lower('Notification%/EventType/'||notification_event_name) 
left outer join t_description on id_enum_data = id_desc
where id_lang_code = :ID_LANG_CODE