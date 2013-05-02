create proc DisplayLocks
as
begin
print 'Resource(s) which a blockee process waits on:'
print ''
select 	convert (smallint, req_spid) As blockerspid,
convert (smallint, waiters.waiterspid) As blockeespid,

grantersyslockinfo.rsc_objid As ObjId,
granterw.name as objname,
grantersyslockinfo.rsc_dbid As dbid,

waiters.Type As BlockeeLockType,
waiters.Resource As BlockeeResource,
waiters.Mode As BlockeeMode,
waiters.Status As BlockeeStatus


from 	
master.dbo.syslockinfo grantersyslockinfo
inner join master.dbo.spt_values granterv ON grantersyslockinfo.rsc_type = granterv.number and granterv.type = 'LR'
inner join master.dbo.spt_values granterx ON grantersyslockinfo.req_status = granterx.number and granterx.type = 'LS'
AND substring (granterx.name, 1, 5) = 'GRANT'
inner join master.dbo.spt_values granteru ON grantersyslockinfo.req_mode + 1 = granteru.number and granteru.type = 'L'
inner join netmeter.dbo.sysobjects granterw ON rsc_objid = granterw.ID

INNER JOIN 
(
select 	convert (smallint, req_spid) As waiterspid,
waitersyslockinfo.rsc_objid As ObjId,
waiterw.name as objname,
		waitersyslockinfo.rsc_dbid,
		substring (waiterv.name, 1, 4) As Type,
		substring (rsc_text, 1, 16) as Resource,
		substring (waiteru.name, 1, 8) As Mode,
		substring (waiterx.name, 1, 5) As Status

from 	
master.dbo.syslockinfo waitersyslockinfo
inner join master.dbo.spt_values waiterv ON waitersyslockinfo.rsc_type = waiterv.number and waiterv.type = 'LR'
inner join master.dbo.spt_values waiterx ON waitersyslockinfo.req_status = waiterx.number and waiterx.type = 'LS'
AND substring (waiterx.name, 1, 5) = 'WAIT'
inner join master.dbo.spt_values waiteru ON waitersyslockinfo.req_mode + 1 = waiteru.number and waiteru.type = 'L'
inner join sysobjects waiterw ON rsc_objid = waiterw.ID

) waiters 
ON grantersyslockinfo.rsc_objid = ObjId
WHERE waiters.Resource = substring (grantersyslockinfo.rsc_text, 1, 16)


print 'Locks which a blocker process holds on these resources:'
print ''
select 	convert (smallint, req_spid) As blockerspid,
grantersyslockinfo.rsc_objid As ObjId,
granterw.name as objname,
grantersyslockinfo.rsc_dbid As dbid,

		substring (granterv.name, 1, 4) As BlockerLockType,
		substring (grantersyslockinfo.rsc_text, 1, 16) as BlockerResource,
		substring (granteru.name, 1, 8) As BlockerMode,
		substring (granterx.name, 1, 5) As BlockerStatus

from 	
master.dbo.syslockinfo grantersyslockinfo
inner join master.dbo.spt_values granterv ON grantersyslockinfo.rsc_type = granterv.number and granterv.type = 'LR'
inner join master.dbo.spt_values granterx ON grantersyslockinfo.req_status = granterx.number and granterx.type = 'LS'
AND substring (granterx.name, 1, 5) = 'GRANT'
inner join master.dbo.spt_values granteru ON grantersyslockinfo.req_mode + 1 = granteru.number and granteru.type = 'L'
inner join sysobjects granterw ON rsc_objid = granterw.ID

INNER JOIN 
(
select 	convert (smallint, req_spid) As waiterspid,
waitersyslockinfo.rsc_objid As ObjId,
waiterw.name as objname,
		waitersyslockinfo.rsc_dbid,
		substring (waiterv.name, 1, 4) As Type,
		substring (rsc_text, 1, 16) as Resource,
		substring (waiteru.name, 1, 8) As Mode,
		substring (waiterx.name, 1, 5) As Status

from 	
master.dbo.syslockinfo waitersyslockinfo
inner join master.dbo.spt_values waiterv ON waitersyslockinfo.rsc_type = waiterv.number and waiterv.type = 'LR'
inner join master.dbo.spt_values waiterx ON waitersyslockinfo.req_status = waiterx.number and waiterx.type = 'LS'
AND substring (waiterx.name, 1, 5) = 'WAIT'
inner join master.dbo.spt_values waiteru ON waitersyslockinfo.req_mode + 1 = waiteru.number and waiteru.type = 'L'
inner join netmeter.dbo.sysobjects waiterw ON rsc_objid = waiterw.ID

) waiters 
ON grantersyslockinfo.rsc_objid = ObjId
end

