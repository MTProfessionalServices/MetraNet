
SELECT   arg.id_request, results.id_interval,  arg.id_acc 
FROM %%TABLE_NAME%% arg
LEFT OUTER JOIN 
(
  SELECT 
    arg2.id_request,
    ui.id_interval 
  FROM %%TABLE_NAME%% arg2 
	INNER JOIN t_acc_usage_interval aui ON aui.id_acc = arg2.id_acc
  INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval
  WHERE
    (aui.tx_status = 'O' OR (aui.tx_status = 'C' AND arg2.b_override = 1)) AND
    /* normalizes the start date of the interval to the effectivity of the mapping if one exists */
	  arg2.dt_session BETWEEN NVL(dbo.AddSecond(aui.dt_effective), ui.dt_start) AND ui.dt_end
) results ON arg.id_request = results.id_request
