

      CREATE   PROCEDURE Export_Status
      AS
      BEGIN
            SET NOCOUNT ON
      
            create table #Table (status_item varchar(255), status_msg varchar(255))
      
            insert into #Table
            
                  select 'Export System Status' as status_item,
                        case parm_value when 0 then 'System is currently running.'
                              ELSE 'System is currently paused.' end as status_msg
                  from t_export_system_parms
                  where parm_name = 'system_suspended'
                  union all
                  select 'Refresh Status' as status_item,
                        'Refresh currently in progress.' as status_msg
                  from t_export_system_parms
                  where parm_name = 'refresh_in_progress' and convert(INT, parm_value) > 0
 
            select * from #Table
            drop table #Table; 
 
            RETURN
      END
	 