use master
GO
if exists (select * from sysobjects where id = object_id('dbo.sp_blocker_pss80') and sysstat & 0xf = 4)
   drop procedure dbo.sp_blocker_pss80
GO
create proc sp_blocker_pss80 (@latch int = 0, @fast int = 1)
as 
--version 11
create table #pss
(ParentObject varchar(24),
 Object varchar(45),
 Field varchar(45),
 Value varchar(110))

set nocount on
declare @spid varchar(6)
declare @blocked varchar(6)
declare @time datetime
declare @time2 datetime

set @time = getdate()
declare @probclients table(spid smallint, ecid smallint, blocked smallint, waittype binary(2), dbid smallint, ignore_app tinyint, primary key (blocked, spid, ecid))
insert @probclients select spid, ecid, blocked, waittype, dbid, case when convert(varchar(128),hostname) = 'PSSDIAG' then 1 else 0 end from sysprocesses where blocked!=0 or waittype != 0x0000

if exists (select spid from @probclients where ignore_app != 1 or waittype != 0x020B)
begin
   set @time2 = getdate()
   print ''
   if (@fast = 0 or @@microsoftversion >= 134218488)
     print '8.1 Start time: ' + convert(varchar(26), @time, 121) + ' ' + convert(varchar(12), datediff(ms,@time,@time2))
   else
     print '8 Start time: ' + convert(varchar(26), @time, 121) + ' ' + convert(varchar(12), datediff(ms,@time,@time2))


   insert @probclients select distinct blocked, 0, 0, 0x0000, 0, 0 from @probclients
      where blocked not in (select spid from @probclients) and blocked != 0

   if (@fast = 1)
   begin
      print ''
      print 'SYSPROCESSES  ' + @@servername + ' ' + str(@@microsoftversion)

      if (@@microsoftversion < 134218488)
        select spid, status, blocked, open_tran, waitresource, waittype, 
           waittime, cmd, lastwaittype, cpu, physical_io,
           memusage,last_batch=convert(varchar(26), last_batch,121),
           login_time=convert(varchar(26), login_time,121), net_address,
           net_library,dbid, ecid, kpid, hostname,hostprocess,
           loginame,program_name, nt_domain, nt_username, uid, sid
        from master..sysprocesses
        where blocked!=0 or waittype != 0x0000
        or spid in (select blocked from @probclients where blocked != 0)
        or spid in (select spid from @probclients where waittype != 0x0000)

      else
        select spid, status, blocked, open_tran, waitresource, waittype, 
           waittime, cmd, lastwaittype, cpu, physical_io,
           memusage, net_address, net_library, dbid, ecid, kpid, hostname,
           hostprocess, loginame, program_name 
        from master..sysprocesses
        where blocked!=0 or waittype != 0x0000
        or spid in (select blocked from @probclients where blocked != 0)
        or spid in (select spid from @probclients where blocked != 0)

      print 'ESP ' + convert(varchar(12), datediff(ms,@time2,getdate())) 

      print ''
      print 'SYSPROC FIRST PASS'
      select spid, ecid, waittype from @probclients where waittype != 0x0000

      print 'SPIDs at the head of blocking chains'
      if exists(select blocked from @probclients where blocked != 0)
      begin
        select spid from @probclients
        where blocked = 0 and spid in (select blocked from @probclients where spid != 0)
         if @latch = 0
         begin
            print ''
            print 'SYSLOCKINFO'
            select @time2 = getdate()

            select spid = convert (smallint, req_spid),
               ecid = convert (smallint, req_ecid),
               rsc_dbid As dbid,
               rsc_objid As ObjId,
               rsc_indid As IndId,
               Type = case rsc_type when 1 then 'NUL'
                                    when 2 then 'DB'
                                    when 3 then 'FIL'
                                    when 4 then 'IDX'
                                    when 5 then 'TAB'
                                    when 6 then 'PAG'
                                    when 7 then 'KEY'
                                    when 8 then 'EXT'
                                    when 9 then 'RID'
                                    when 10 then 'APP' end,
               Resource = substring (rsc_text, 1, 16),
               Mode = case req_mode + 1 when 1 then NULL
                                        when 2 then 'Sch-S'
                                        when 3 then 'Sch-M'
                                        when 4 then 'S'
                                        when 5 then 'U'
                                        when 6 then 'X'
                                        when 7 then 'IS'
                                        when 8 then 'IU'
                                        when 9 then 'IX'
                                        when 10 then 'SIU'
                                        when 11 then 'SIX'
                                        when 12 then 'UIX'
                                        when 13 then 'BU'
                                        when 14 then 'RangeS-S'
                                        when 15 then 'RangeS-U'
                                        when 16 then 'RangeIn-Null'
                                        when 17 then 'RangeIn-S'
                                        when 18 then 'RangeIn-U'
                                        when 19 then 'RangeIn-X'
                                        when 20 then 'RangeX-S'
                                        when 21 then 'RangeX-U'
                                        when 22 then 'RangeX-X'end,
               Status = case req_status when 1 then 'GRANT'
                                        when 2 then 'CNVT'
                                        when 3 then 'WAIT' end,
               req_transactionID As TransID, req_transactionUOW As TransUOW
            from master.dbo.syslockinfo s,
               @probclients p
            where p.spid = s.req_spid

            print 'ESL ' + convert(varchar(12), datediff(ms,@time2,getdate())) 
         end -- latch not set
      end
      else
        print 'No blocking via locks at ' + convert(varchar(26), @time, 121)
      print ''
   end  -- fast set

   else  
   begin  -- Fast not set
      print ''
      print 'SYSPROCESSES'

      select spid, status, blocked, open_tran, waitresource, waittype, 
         waittime, cmd, lastwaittype, cpu, physical_io,
         memusage, net_address, net_library, dbid, ecid, kpid, hostname,
         hostprocess, loginame, program_name 
      from master..sysprocesses

      print 'ESP ' + convert(varchar(12), datediff(ms,@time2,getdate())) 

      print ''
      print 'SYSPROC FIRST PASS'
      select spid, ecid, waittype from @probclients where waittype != 0x0000

      print 'SPIDs at the head of blocking chains'
      if exists(select blocked from @probclients where blocked != 0)
      begin
         select spid from @probclients
         where blocked = 0 and spid in (select blocked from @probclients where spid != 0)
         print ''
         if @latch = 0
         begin
            print ''
            print 'SYSLOCKINFO'
            select @time2 = getdate()

            select spid = convert (smallint, req_spid),
               ecid = convert (smallint, req_ecid),
               rsc_dbid As dbid,
               rsc_objid As ObjId,
               rsc_indid As IndId,
               Type = case rsc_type when 1 then 'NUL'
                                    when 2 then 'DB'
                                    when 3 then 'FIL'
                                    when 4 then 'IDX'
                                    when 5 then 'TAB'
                                    when 6 then 'PAG'
                                    when 7 then 'KEY'
                                    when 8 then 'EXT'
                                    when 9 then 'RID'
                                    when 10 then 'APP' end,
               Resource = substring (rsc_text, 1, 16),
               Mode = case req_mode + 1 when 1 then NULL
                                        when 2 then 'Sch-S'
                                        when 3 then 'Sch-M'
                                        when 4 then 'S'
                                        when 5 then 'U'
                                        when 6 then 'X'
                                        when 7 then 'IS'
                                        when 8 then 'IU'
                                        when 9 then 'IX'
                                        when 10 then 'SIU'
                                        when 11 then 'SIX'
                                        when 12 then 'UIX'
                                        when 13 then 'BU'
                                        when 14 then 'RangeS-S'
                                        when 15 then 'RangeS-U'
                                        when 16 then 'RangeIn-Null'
                                        when 17 then 'RangeIn-S'
                                        when 18 then 'RangeIn-U'
                                        when 19 then 'RangeIn-X'
                                        when 20 then 'RangeX-S'
                                        when 21 then 'RangeX-U'
                                        when 22 then 'RangeX-X'end,
               Status = case req_status when 1 then 'GRANT'
                                        when 2 then 'CNVT'
                                        when 3 then 'WAIT' end,
               req_transactionID As TransID, req_transactionUOW As TransUOW
            from master.dbo.syslockinfo

            print 'ESL ' + convert(varchar(12), datediff(ms,@time2,getdate())) 
         end -- latch not set
      end
      else
        print 'No blocking via locks at ' + convert(varchar(26), @time, 121)
      print ''
   end -- Fast not set

   print ''
   print 'DBCC SQLPERF(WAITSTATS)'
   dbcc sqlperf(waitstats)
   print ''

   Print ''
   Print '*********************************************************************'
   Print 'Print out DBCC Input buffer for all blocked or blocking spids.'
   Print 'Print out DBCC PSS info only for SPIDs at the head of blocking chains'
   Print '*********************************************************************'

   declare ibuffer cursor fast_forward for
   select cast (spid as varchar(6)) as spid, cast (blocked as varchar(6)) as blocked
   from @probclients
   where (spid <> @@spid) and 
      ((blocked!=0 or (waittype != 0x0000 and ignore_app = 0))
      or spid in (select blocked from @probclients where blocked != 0))
   open ibuffer
   fetch next from ibuffer into @spid, @blocked
   while (@@fetch_status != -1)
   begin
      print ''
      print 'DBCC INPUTBUFFER FOR SPID ' + @spid
      exec ('dbcc inputbuffer (' + @spid + ')')

      if (@fast = 0 or @@microsoftversion >= 134218488)
      begin
        if (@blocked = '0' or (@fast = 0 and @@microsoftversion >= 134218488))
          begin
          print ''
          set @time2 = getdate()
          insert #pss exec ('dbcc pss (0, ' + @spid +') with tableresults') 

          print 'DBCC PSS FOR SPID ' + @spid
          select 'PSS'=field + ' = ' + value from #pss where object like 'PSS%'
          select 'Sid'=value from #pss where object like 'pbSid'

          if (@blocked = '0')
          begin
             select 'ECs'=field + ' = ' + value from #pss where object like 'ExecutionContext Summary%'
             select 'Output Buffer'=value from #pss where object like 'psrvproc->srvio.outbuff'
          end
          else
            select 'ECs'=field + ' = ' + value from #pss where object like 'ExecutionContext Summary%' and field in ('ec_umsContext->m_pSched->m_id (SchedulerId)','ecid','ec_lasterror','ec_preverror','ec_reswait','ec_waittype')

          truncate table #pss

          print 'DBCC execution completed. If DBCC printed error messages, contact your system administrator. ' + convert(varchar(12), datediff(ms,@time2,getdate()))
          print ''
        end
      end

      fetch next from ibuffer into @spid, @blocked
   end
   deallocate ibuffer

   if (@@microsoftversion < 134218488)
   begin
      Print ''
      Print '*******************************************************************************'
      Print 'Print out DBCC OPENTRAN for active databases for all blocked or blocking spids.'
      Print '*******************************************************************************'
      declare ibuffer cursor fast_forward for
      select distinct cast (dbid as varchar(6)) from @probclients
      where dbid != 0
      open ibuffer
      fetch next from ibuffer into @spid
      while (@@fetch_status != -1)
      begin
         print ''
         print 'DBCC OPENTRAN FOR DBID ' + @spid
         exec ('dbcc opentran (' + @spid + ')')
         print ''
         if @spid = '2' select @blocked = 'Y'
         fetch next from ibuffer into @spid
      end
      deallocate ibuffer
      if @blocked != 'Y' 
      begin
         print ''
         print 'DBCC OPENTRAN FOR tempdb database'
         exec ('dbcc opentran (tempdb)')
      end
   end

   print 'End time: ' + convert(varchar(26), getdate(), 121)
end -- All
else
  print '8 No Waittypes: ' + convert(varchar(26), @time, 121) + ' ' + convert(varchar(12), datediff(ms,@time,getdate()))
GO