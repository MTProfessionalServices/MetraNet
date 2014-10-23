INSERT INTO [t_Notification_Event_Consumers]
           ([id_not_evnt_consumer]
           ,[id_notification_event]
           ,[id_acc]
           ,[dt_crt])
     VALUES
           (:NotificationEventConsumerID
           ,:NotificationEventID
           ,:AccountID,
           ,:CreateDate)