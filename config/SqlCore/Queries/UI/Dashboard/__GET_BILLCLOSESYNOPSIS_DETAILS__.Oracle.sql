SELECT 
'Open' as Status, 
COUNT(*) as Count
FROM t_failed_transaction ft
JOIN t_acc_usage_cycle cycle ON cycle.id_acc = ft.id_PossiblePayeeID
WHERE ft.State = 'N'
AND cycle.id_usage_cycle = ( 
SELECT
      CASE EXTRACT(DAY FROM dt_end)
         WHEN 5 THEN 7
         WHEN 12 THEN 14
         WHEN 19 THEN 21
         WHEN 26 THEN 28
         ELSE 30
      END
FROM t_usage_interval ui
WHERE ui.id_interval = %%ID_USAGE_INTERVAL%%
)
AND ft.dt_FailureTime > getutcdate()-30

UNION

SELECT
'Under Investigation' as Status, 
COUNT(*) as Count 
FROM t_failed_transaction ft
JOIN t_acc_usage_cycle cycle ON cycle.id_acc = ft.id_PossiblePayeeID
WHERE ft.State = 'I'
AND cycle.id_usage_cycle = (
SELECT
      CASE EXTRACT(DAY FROM dt_end)
         WHEN 5 THEN 7
         WHEN 12 THEN 14
         WHEN 19 THEN 21
         WHEN 26 THEN 28
         ELSE 30
      END
FROM t_usage_interval ui
WHERE ui.id_interval = %%ID_USAGE_INTERVAL%%
)
AND ft.dt_FailureTime > getutcdate()-30

UNION

SELECT 'Fixed' AS Status,
COUNT(*) AS Count
FROM t_failed_transaction ft
JOIN t_acc_usage_cycle cycle ON cycle.id_acc = ft.id_PossiblePayeeID
WHERE ft.State = 'R'
AND cycle.id_usage_cycle = (
SELECT
      CASE EXTRACT(DAY FROM dt_end)
         WHEN 5 THEN 7
         WHEN 12 THEN 14
         WHEN 19 THEN 21
         WHEN 26 THEN 28
         ELSE 30
      END
FROM t_usage_interval ui
WHERE ui.id_interval = %%ID_USAGE_INTERVAL%%
)
AND ft.dt_FailureTime > getutcdate()-30

UNION

SELECT 'Unguided' AS Status, 
COUNT(*) AS Count
FROM t_failed_transaction ft
WHERE ft.State = 'N' 
AND ft.id_PossiblePayerID < 2
AND ft.dt_FailureTime > getutcdate()-30

