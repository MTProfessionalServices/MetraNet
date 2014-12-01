select  notification_event_name,  d1.tx_desc As notification_event_template, d2.tx_desc  as default_template from 
t_enum_data  join t_notification_event_types on Lower(nm_enum_data) = Lower('Notification/Template/'+notification_event_name) 
left outer join t_description d1 on id_enum_data = d1.id_desc left outer join t_description d2 on id_enum_data = d2.id_desc 
where d1.id_lang_code = @ID_LANG_CODE and d2.id_lang_code = 840