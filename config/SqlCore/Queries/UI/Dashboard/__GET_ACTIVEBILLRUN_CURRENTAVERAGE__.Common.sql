DECLARE @Interval_ID int
set @Interval_ID = %%ID_USAGE_INTERVAL%%  --set interval here

IF EXISTS (SELECT * FROM information_schema.tables WHERE Table_Name = 'NM_Dashboard__Interval_Data' AND Table_Type = 'BASE TABLE')
BEGIN
DROP TABLE NM_Dashboard__Interval_Data
END

SELECT rei.id_arg_interval, re.tx_display_name, min(rer.dt_start) as dt_start, datediff(minute, min(rer.dt_start), max(rer.dt_end)) as [duration], 0 as three_month_avg
into  NM_Dashboard__Interval_Data
  FROM [dbo].[t_recevent_inst] rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
  --right join t_recevent_inst_audit rea on rea.id_instance = rei.id_instance
Where id_arg_interval in (
select @Interval_ID as id_interval
union
select ui.id_interval
from t_usage_interval ui
where ui.tx_interval_status = 'H'
and ui.dt_end > dateadd(month, -3, getdate())
and DATEDIFF(day, dt_start, dt_end) > 7)
and rer.tx_type = 'Execute'
and tx_detail not like 'Manually changed status%'
group by rei.id_arg_interval, tx_display_name,  rer.dt_start
order by   rer.dt_start

update ca
set ca.three_month_avg = field2Sum
from NM_Dashboard__Interval_Data ca
Inner Join (select tx_display_name, avg(duration) as field2Sum
   from NM_Dashboard__Interval_Data sft
   where id_arg_interval <> @Interval_ID
  group by tx_display_name) as sft
on ca.tx_display_name = sft.tx_display_name;


select ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as RowNumber, tx_display_name as Adapter, duration as Duration, three_month_avg as Average
from NM_Dashboard__Interval_Data
where id_arg_interval = @Interval_ID;
