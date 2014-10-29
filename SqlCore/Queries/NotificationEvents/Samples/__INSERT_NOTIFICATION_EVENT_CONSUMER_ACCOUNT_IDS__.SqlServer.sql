INSERT INTO t_notification_event_consumers
           (id_not_evnt_consumer
           ,id_notification_event
           ,id_acc
           ,dt_crt)
     VALUES
           (@NotificationEventConsumerID
           ,@NotificationEventID
           ,@AccountID
           ,@CreateDate)