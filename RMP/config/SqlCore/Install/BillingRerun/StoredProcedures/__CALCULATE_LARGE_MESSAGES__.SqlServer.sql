
create procedure CalculateLargeMessages(@rerunID int,
      @num_large_messages int OUTPUT,
      @num_large_session_sets int OUTPUT)
as
begin
   declare @sql nvarchar(4000);
   declare @temp_table_name nvarchar(50);
   declare @args nvarchar(100);
   
   
   select @num_large_messages = count(*) from #aggregate_large;

   set @sql = N'insert into #child_session_sets (id_parent_sess, id_svc, cnt)
                select prnt.id_sess, rr.id_svc, count(*)
                from  t_rerun_session_' + CAST(@rerunID AS NVARCHAR(10)) + N' rr
                inner join #aggregate_large prnt
                on prnt.id_parent_source_sess=rr.id_parent_source_sess
				group by prnt.id_sess, rr.id_svc ';

   EXEC sp_executesql @sql

   select @num_large_session_sets = isnull(max(id_sess), 0) + @num_large_messages from #child_session_sets;
 
end;
    