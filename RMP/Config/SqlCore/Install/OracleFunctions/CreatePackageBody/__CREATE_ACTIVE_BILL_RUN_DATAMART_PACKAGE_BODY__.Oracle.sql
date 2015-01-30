create or replace
package body active_bill_run_pkg as
FUNCTION GetActvCurAverage(v_id_interval int)
  return ActiveBillRunWidgetTable PIPELINED IS
  p_returnTable ActiveBillRunWidgetTblType := ActiveBillRunWidgetTblType(null, null, null, null);
  
  p_result sys_refcursor;
  l_tbl_count NUMBER;  
  l_interval_id int;
  
  v_sql VARCHAR2(4000);
  
  v_1 int;
  v_2 nvarchar2(200);
  v_3 int;
  v_4 int;
   pragma autonomous_transaction;
BEGIN
  l_interval_id :=v_id_interval; 
  SELECT COUNT(1)
  INTO l_tbl_count
  FROM user_tables
  WHERE  table_name  = UPPER('NM_DASHBOARD__INTERVAL_DATA');
  
  /*pragma autonomous_transaction;*/
  begin
	  IF (l_tbl_count > 0) THEN
		EXECUTE IMMEDIATE 'DROP TABLE NM_Dashboard__Interval_Data';
	   /* EXECUTE IMMEDIATE 'commit';*/
	   /*commit;*/
	  END IF;
	  
	  EXECUTE IMMEDIATE 'CREATE TABLE NM_Dashboard__Interval_Data AS ' ||
						'    SELECT 
							  rei.id_arg_interval, 
							  re.tx_display_name, 
							  rer.dt_start dt_start, 
							  ROUND((rer.dt_end - rer.dt_start) * 86400,0) duration, 
							  0.0 as three_month_avg
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
													  and ui.id_usage_cycle = (select id_usage_cycle from t_usage_interval where id_interval = ' || l_interval_id || '))
							and rer.tx_type = ''Execute''
              and rer.dt_start = (select max(dt_start) from t_recevent_run where id_instance = rer.id_instance)
							and (rer.tx_detail not like ''Manually changed status%'' or rer.tx_detail is null)
							group by rei.id_arg_interval, tx_display_name, rer.dt_start, rer.dt_end
							order by   rer.dt_start';
  end;
                  
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
    commit;  
    LOOP
      FETCH p_result INTO v_1, v_2, v_3, v_4;
      EXIT WHEN p_result%NOTFOUND;
      p_returnTable.RowNumber := v_1;
      p_returnTable.Adapter := v_2;
      p_returnTable.Duration := v_3;
      p_returnTable.Average := v_4;
      PIPE ROW (p_returnTable);
    END LOOP      
    return;     
END GetActvCurAverage;
end active_bill_run_pkg;
