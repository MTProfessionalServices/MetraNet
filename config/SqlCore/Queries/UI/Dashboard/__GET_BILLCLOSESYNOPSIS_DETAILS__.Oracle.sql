SELECT 
'Open' as Status, 
COUNT(*) as Count
FROM t_failed_transaction ft
JOIN t_acc_usage_cycle cycle ON cycle.id_acc = ft.id_PossiblePayeeID
JOIN t_usage_interval ui ON cycle.id_usage_cycle = ui.id_usage_cycle
WHERE ft.State = 'N' AND  ui.id_interval = %%ID_USAGE_INTERVAL%%
AND (ft.dt_FailureTime >= ui.dt_start AND ft.dt_FailureTime <= ui.dt_end)

UNION

SELECT
'Under Investigation' as Status, 
COUNT(*) as Count 
FROM t_failed_transaction ft
LEFT OUTER JOIN t_acc_usage_cycle cycle ON cycle.id_acc = ft.id_PossiblePayeeID
LEFT OUTER JOIN t_usage_interval ui ON cycle.id_usage_cycle = ui.id_usage_cycle or ui.id_interval = %%ID_USAGE_INTERVAL%% 
WHERE ft.State = 'I' AND (cycle.id_usage_cycle is not null OR ft.id_PossiblePayerID = -1)
AND (ft.dt_FailureTime >= ui.dt_start AND ft.dt_FailureTime <= ui.dt_end)

UNION

SELECT 'Fixed' AS Status,
COUNT(*) AS Count
FROM t_failed_transaction ft
LEFT OUTER JOIN t_acc_usage_cycle cycle ON cycle.id_acc = ft.id_PossiblePayeeID
LEFT OUTER JOIN t_usage_interval ui ON cycle.id_usage_cycle = ui.id_usage_cycle or ui.id_interval = %%ID_USAGE_INTERVAL%% 
WHERE ft.State = 'R' AND  (cycle.id_usage_cycle is not null OR ft.id_PossiblePayerID = -1)
AND (ft.dt_FailureTime >= ui.dt_start AND ft.dt_FailureTime <= ui.dt_end)

UNION

SELECT 'Unguided' AS Status, 
COUNT(*) AS Count
FROM t_failed_transaction ft
WHERE ft.State = 'N'  
AND ft.id_PossiblePayerID < 2
AND (ft.dt_FailureTime >= (SELECT dt_start from t_usage_interval where id_interval = %%ID_USAGE_INTERVAL%%) AND ft.dt_FailureTime <= (SELECT dt_end from t_usage_interval where id_interval = %%ID_USAGE_INTERVAL%%))

