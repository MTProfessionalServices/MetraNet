
create  PROCEDURE GetRecurringEventDepsByInst( 
  @dep_type varchar(30),
  @dt_now datetime,
  @id_instances varchar(4000),
  @status_filter varchar(4000)
)
AS
BEGIN
	declare @sql varchar(4000)
	declare @dt varchar(30)
    declare @functionname varchar(40)
	set @dt = convert(varchar, @dt_now, 21)

if @dep_type = 'Execution'
	begin
       set @functionname = 'ExecutionFunction' 
    end
else 
	begin
	   set @functionname = 'Reversal' 
	end 


	set @sql = 'SELECT 
  deps.id_orig_instance OriginalInstanceID,
	  deps.tx_orig_name OriginalEventName,
	  deps.tx_orig_billgroup_support OriginalBillGroupSupportType,
	  deps.tx_name EventName,
	  evt.tx_type EventType,
	  deps.id_instance InstanceID,
	  deps.id_arg_interval ArgIntervalID,
	  deps.dt_arg_start ArgStartDate,
	  deps.dt_arg_end ArgEndDate,
	  deps.tx_status Status,
	  deps.id_orig_billgroup OriginalBillingGroupID,
	  deps.id_billgroup BillingGroupID,
	  deps.b_critical_dependency IsCriticalDependency,
	  deps.tx_billgroup_support BillGroupSupportType
	FROM dbo.GetEvent' + @functionname + 'Deps('''+ @dt + ''', ''' + @id_instances + ''') deps 
	INNER JOIN t_recevent evt ON evt.id_event = deps.id_event
	WHERE 
	  /* excludes identity dependencies */
	  (deps.id_orig_instance <> deps.id_instance OR
	  /* allows missing instances in case of execution deps */
	  deps.id_instance IS NULL)
	  ' + @status_filter + '
	/* this ordering is expected by usm for display purposes */
	ORDER BY OriginalInstanceID ASC, ArgIntervalID DESC, 
		EventType ASC, EventName ASC, ArgStartDate DESC'

	exec(@sql)

end
    