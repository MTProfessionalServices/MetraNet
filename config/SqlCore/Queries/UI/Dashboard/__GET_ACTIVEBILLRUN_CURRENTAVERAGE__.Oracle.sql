DECLARE 
  obj_Count NUMBER; 
  p_result sys_refcursor;
BEGIN
  SELECT COUNT(1)
  INTO obj_Count
  FROM user_objects
  WHERE  object_name = 'NM_DASHBOARD__INTERVAL_DATA'  AND object_type = 'TABLE';
  
  IF (obj_Count > 0) THEN
    EXECUTE IMMEDIATE 'DROP TABLE NM_Dashboard__Interval_Data';
  END IF;
  
  EXECUTE IMMEDIATE 'CREATE TABLE NM_Dashboard__Interval_Data AS
                        SELECT 
                          rei.id_arg_interval, 
                          re.tx_display_name, 
                          min(rer.dt_start) dt_start, 
                          (floor(min(rer.dt_start) - max(rer.dt_end))) * 24 * 60 duration, 
                          0 as three_month_avg
                          FROM t_recevent_inst rei
                          join t_recevent re on re.id_event = rei.id_event
                          left join t_recevent_run rer on rer.id_instance = rei.id_instance
                          --right join t_recevent_inst_audit rea on rea.id_instance = rei.id_instance
                        Where id_arg_interval in (select ' || %%ID_USAGE_INTERVAL%% || ' id_interval from dual 
                                                    union
                                                  select ui.id_interval id_interval
                                                  from t_usage_interval ui
                                                  where ui.tx_interval_status = ''H''
                                                  and ui.dt_end > add_months(getutcdate(), -3) 
                                                  and floor(dt_start - dt_end) > 7)
                        and rer.tx_type = ''Execute''
                        and tx_detail not like ''Manually changed status%''
                        group by rei.id_arg_interval, tx_display_name,  rer.dt_start
                        order by   rer.dt_start';
                  
  MERGE into NM_Dashboard__Interval_Data ca
  USING
  (
    SELECT tx_display_name, avg(duration) field2Sum
    FROM NM_Dashboard__Interval_Data sft
    WHERE id_arg_interval <>  %%ID_USAGE_INTERVAL%%
    GROUP BY tx_display_name
  ) sft ON (ca.tx_display_name = sft.tx_display_name)
  WHEN MATCHED THEN UPDATE 
  SET ca.three_month_avg = field2Sum;                        

  OPEN p_result FOR
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1 FROM dual)) RowNumber, tx_display_name Adapter, duration Duration, three_month_avg Average
    FROM NM_Dashboard__Interval_Data
    WHERE id_arg_interval =  %%ID_USAGE_INTERVAL%%;
    
END;

