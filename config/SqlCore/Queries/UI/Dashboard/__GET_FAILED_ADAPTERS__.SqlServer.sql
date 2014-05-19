SELECT rer.id_instance,
       rei.id_arg_billgroup id_billgroup,
       rei.id_arg_interval id_interval,
       re.tx_display_name AS name,
       rer.dt_end AS EndDate,
       rer.tx_detail AS message
FROM   t_recevent_run rer
       JOIN t_recevent_inst rei
            ON  rei.id_instance = rer.id_instance
       JOIN t_recevent re
            ON  re.id_event = rei.id_event
WHERE  rei.tx_status = 'Failed'
       AND rer.tx_status = 'Failed'
       AND rer.dt_start > DATEADD(MONTH, -1, GETUTCDATE())
ORDER BY
       EndDate DESC