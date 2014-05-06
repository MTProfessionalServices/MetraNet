DECLARE @currentBatch DateTime
DECLARE @currentBatchID Int
DECLARE @previousBatch DateTime
set @currentBatchID = (SELECT top 1 id_batch from t_batch where n_expected > 0 order by dt_crt desc)
set @currentBatch = (SELECT top 1 dt_crt from t_batch where id_batch=@currentBatchID)
set @previousBatch = (SELECT top 1 dt_crt from t_batch where dt_crt < @currentBatch and n_expected > 0 order by dt_crt desc)
SELECT @currentBatchID as BATCHID, DATENAME(MM, @currentBatch) + ' ' + CAST(DAY(@currentBatch) AS VARCHAR(2)) AS [DATE],
Replace(Replace(RIGHT(CONVERT(VARCHAR, @currentBatch),7), 'AM', ' AM'), 'PM', ' PM') AS [TIME],
DATEDIFF(MINUTE, @previousBatch, @currentBatch) as [TIME DIFF]
