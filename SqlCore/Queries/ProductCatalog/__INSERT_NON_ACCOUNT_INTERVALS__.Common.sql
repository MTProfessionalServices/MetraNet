
INSERT INTO t_usage_interval(id_interval,id_usage_cycle,dt_start,
dt_end,tx_interval_status)
SELECT 
        pci.id_interval,
        pci.id_cycle,
        pci.dt_start,
        pci.dt_end,
        'N' 
FROM 
(
      /* gets the discount and group sub cycles which are not already */
      /* being used by accounts */
      SELECT group_cycle.id_cycle
      FROM 
      (
             SELECT id_usage_cycle id_cycle FROM t_discount
             UNION
             SELECT id_usage_cycle id_cycle FROM t_group_sub
      ) group_cycle
      WHERE NOT EXISTS
             (SELECT 1 FROM t_acc_usage_cycle uc WHERE uc.id_usage_cycle = group_cycle.id_cycle)
) missing_cycle
INNER JOIN t_pc_interval pci ON pci.id_cycle = missing_cycle.id_cycle
WHERE ((%%UTCDATE%% BETWEEN pci.dt_start AND pci.dt_end) OR
      /* allows for a one day safety margin of not running USM  */
       (%%UTCDATE%% + 1 BETWEEN pci.dt_start AND pci.dt_end)) AND
      /* only add the interval if it doesn't exist */
      NOT EXISTS (SELECT 1 FROM t_usage_interval ui WHERE ui.id_interval = pci.id_interval)   
