delete consumer from t_notification_event_consumers consumer
inner join t_notification_events event on (consumer.id_notification_event = event.id_notification_event)
where event.dt_crt < @cleanupdate