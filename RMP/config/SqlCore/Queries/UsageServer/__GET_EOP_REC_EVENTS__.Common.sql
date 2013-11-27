
/* ===========================================================
   Return rows from t_recevent which meet the following criteria
   1) Has a tx_type of 'EndOfPeriod' 
   2) Has an id_cycle_type in t_recevent_eop which is either NULL or matches
       the cycle type of the given interval
   =========================================================== */
SELECT r.tx_class_name ClassName, 
            r.id_event EventID,
            r.tx_name EventName,
            r.tx_extension_name ExtensionName,
            r.tx_config_file ConfigFileName
            
FROM t_recevent r
INNER JOIN t_recevent_eop rs 
  ON rs.id_event = r.id_event AND r.tx_type = 'EndOfPeriod'
WHERE 
%%OPTIONAL_WHERE_CLAUSE%%
(rs.id_cycle_type IN (SELECT DISTINCT(id_cycle_type) 
			        FROM t_usage_cycle uc
			        INNER JOIN t_usage_interval ui ON ui.id_usage_cycle = uc.id_usage_cycle
			        WHERE ui.id_interval = %%ID_INTERVAL%%) 
OR rs.id_cycle_type IS NULL)
   