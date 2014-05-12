DECLARE 
  l_tbl_count NUMBER;  
  l_interval_id   t_usage_interval.id_interval%TYPE := 123;
  p_result sys_refcursor;
  v_sql VARCHAR2(4000);
BEGIN
  SELECT COUNT(1)
  INTO l_tbl_count
  FROM user_tables
  WHERE  table_name  = UPPER('NM_DASHBOARD__INTERVAL_DATA');
  
  IF (l_tbl_count > 0) THEN
    EXECUTE IMMEDIATE 'DROP TABLE NM_Dashboard__Interval_Data';
  END IF;
  
  EXECUTE IMMEDIATE 'CREATE TABLE NM_Dashboard__Interval_Data AS ' ||
                    '    SELECT 
                          rei.id_arg_interval, 
                          re.tx_display_name, 
                          min(rer.dt_start) dt_start, 
                          floor((max(rer.dt_end) - min(rer.dt_start)) * 24 * 60) duration, 
                          0 as three_month_avg
                          FROM t_recevent_inst rei
                          join t_recevent re on re.id_event = rei.id_event
                          left join t_recevent_run rer on rer.id_instance = rei.id_instance
                          --right join t_recevent_inst_audit rea on rea.id_instance = rei.id_instance
                        Where id_arg_interval in (select ' || l_interval_id || ' id_interval from dual 
                                                    union
                                                  select ui.id_interval id_interval
                                                  from t_usage_interval ui
                                                  where ui.tx_interval_status = ''H''
                                                  and ui.dt_end > add_months(getutcdate(), -3) 
                                                  and floor(dt_end - dt_start) > 7)
                        and rer.tx_type = ''Execute''
                        and tx_detail not like ''Manually changed status%''
                        group by rei.id_arg_interval, tx_display_name,  rer.dt_start
                        order by   rer.dt_start';
                  
 EXECUTE IMMEDIATE 'MERGE into NM_Dashboard__Interval_Data ca
  USING
  (
    SELECT tx_display_name, avg(duration) field2Sum
    FROM NM_Dashboard__Interval_Data sft
    WHERE id_arg_interval <> ' || l_interval_id ||'
    GROUP BY tx_display_name
  ) sft ON (ca.tx_display_name = sft.tx_display_name)
  WHEN MATCHED THEN UPDATE 
  SET ca.three_month_avg = field2Sum'; 
  
  v_sql := ' SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1 FROM dual)) RowNumber, tx_display_name Adapter, duration Duration, three_month_avg Average
    FROM NM_Dashboard__Interval_Data
    WHERE id_arg_interval = :1'; 
     
     OPEN p_result FOR v_sql USING l_interval_id;    
END;