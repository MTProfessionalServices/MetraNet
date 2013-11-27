
       declare @j int
       declare @i int
       select @j = max(id) from %%RERUN_TABLE_NAME%% 
       set @i=1
       while (@i <= @j)
       begin
        update svc
          set svc.c__IntervalId = rr.id_interval
          from %%RERUN_TABLE_NAME%% rr 
          inner join %%SVC_TABLE_NAME%% svc %%%READCOMMITTED%%%
          on rr.id_source_sess = svc.id_source_sess
          inner join t_usage_interval ui
          on ui.id_interval = rr.id_interval
          inner join t_acc_usage_interval aui
          on aui.id_acc = rr.id_payer and
              aui.id_usage_interval = rr.id_interval
          where rr.id_interval is not null 
          and	aui.tx_status = 'C'
          and rr.id between @i and @i+999999
          
          set @i = @i + 1000000
       end
 
	  