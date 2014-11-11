
SELECT evt.id_event,
       evt.tx_display_name,
       evt.tx_name,
       evt.tx_desc,
       MAX(evi.dt_arg_end) InstanceLastArgEndDate
FROM   t_recevent evt
       LEFT JOIN t_recevent_inst evi
            ON  evt.id_event = evi.id_event
WHERE  %%%UPPER%%%(evt.tx_type) = 'SCHEDULED'
       AND evt.dt_activated <= %%%SYSTEMDATE%%%
       AND (
               evt.dt_deactivated IS NULL
               OR %%%SYSTEMDATE%%% < evt.dt_deactivated
           )
GROUP BY
       evt.id_event,
       evt.tx_display_name,
       evt.tx_name,
       evt.tx_desc
