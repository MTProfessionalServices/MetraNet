INSERT INTO t_notification_events
           (id_notification_event
           ,id_notification_event_type
           ,notification_event_prop_values
           ,id_partition
           ,dt_crt)
     VALUES
           (@NotificationEventID
           ,@NotificationEventTypeID
           ,@NotificationEventPropValues
           ,@PartitionID
           ,@CreateDate)