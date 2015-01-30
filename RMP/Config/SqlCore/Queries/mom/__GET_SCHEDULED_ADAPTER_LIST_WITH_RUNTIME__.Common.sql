
SELECT evt.id_event,
       COALESCE(loc.tx_name, evt.tx_display_name) tx_display_name,
       evt.tx_name,
       COALESCE(loc.tx_desc,  evt.tx_desc) tx_desc,
       MAX(evi.dt_arg_end) InstanceLastArgEndDate
FROM   t_recevent evt
       LEFT JOIN t_recevent_inst evi ON  evt.id_event = evi.id_event
       LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = %%ID_LANG_CODE%% AND evt.id_event=loc.id_item)
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
       evt.tx_desc,
       loc.tx_name,
       loc.tx_desc
