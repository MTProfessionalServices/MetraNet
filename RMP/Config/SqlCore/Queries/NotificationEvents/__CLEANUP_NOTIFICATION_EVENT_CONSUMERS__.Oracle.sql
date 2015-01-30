delete from t_notification_event_consumers consumer
where consumer.id_notification_event in (select event.id_notification_event from t_notification_events event where event.dt_crt < :cleanupdate )