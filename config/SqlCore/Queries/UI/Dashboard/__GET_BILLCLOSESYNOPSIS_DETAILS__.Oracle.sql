SELECT 
'Open' as Status, 
COUNT(*) as Count
FROM t_failed_transaction ft
JOIN t_acc_usage_cycle cycle ON cycle.id_acc = ft.id_PossiblePayeeID
JOIN t_usage_interval ui ON cycle.id_usage_cycle = ui.id_usage_cycle
WHERE ft.State = 'N'
AND  ui.id_interval = %%ID_USAGE_INTERVAL%%
AND ft.dt_FailureTime > getutcdate()-30

UNION

SELECT
'Under Investigation' as Status, 
COUNT(*) as Count 
FROM t_failed_transaction ft
JOIN t_acc_usage_cycle cycle ON cycle.id_acc = ft.id_PossiblePayeeID
JOIN t_usage_interval ui ON cycle.id_usage_cycle = ui.id_usage_cycle
WHERE ft.State = 'I'
AND ui.id_interval = %%ID_USAGE_INTERVAL%%
AND ft.dt_FailureTime > getutcdate()-30

UNION

SELECT 'Fixed' AS Status,
COUNT(*) AS Count
FROM t_failed_transaction ft
JOIN t_acc_usage_cycle cycle ON cycle.id_acc = ft.id_PossiblePayeeID
JOIN t_usage_interval ui ON cycle.id_usage_cycle = ui.id_usage_cycle
WHERE ft.State = 'R'
AND  ui.id_interval = %%ID_USAGE_INTERVAL%%
AND ft.dt_FailureTime > getutcdate()-30

UNION

SELECT 'Unguided' AS Status, 
COUNT(*) AS Count
FROM t_failed_transaction ft
WHERE ft.State = 'N' 
AND ft.id_PossiblePayerID < 2
AND ft.dt_FailureTime > getutcdate()-30

