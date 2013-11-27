set nocount on
go
INSERT INTO t_sys_upgrade
(target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
('5.1', getdate(), 'R')
go
ALTER TABLE dbo.t_archive_queue ALTER COLUMN id_svc nvarchar (100)  NULL
go
ALTER TABLE dbo.t_decimal_capability ALTER COLUMN param_value numeric (18, 6) NULL
go
ALTER TABLE dbo.t_mview_catalog ADD
drop_query_tag nvarchar (200)  NULL,
init_query_tag nvarchar (200)  NULL
GO
ALTER TABLE dbo.t_query_log ALTER COLUMN c_old_schema varchar (8000)  NOT NULL
GO
declare @name varchar(1000)
declare @stmt nvarchar(2000) 
select @name = a.name from sysobjects a, sysobjects b,sysconstraints c
where a.xtype='PK'
and b.xtype='U'
and b.name='t_session_state'
and a.id=c.constid
and b.id=c.id
select @stmt = N'alter table t_session_state drop constraint ' + @name
exec sp_executesql @stmt
go
ALTER TABLE t_session_state ADD CONSTRAINT pk_t_session_state PRIMARY KEY CLUSTERED  (id_sess, dt_end, tx_state)
GO
DROP STATISTICS t_vw_allrateschedules_pl.Statistic_id_pricelist
GO
CREATE STATISTICS Statistic_id_pricelist ON t_vw_allrateschedules_pl (id_pricelist)
GO
DROP STATISTICS t_vw_allrateschedules_po.Statistic_id_po
GO
DROP STATISTICS t_vw_allrateschedules_po.Statistic_id_sub
GO
CREATE STATISTICS Statistic_id_sub ON t_vw_allrateschedules_po (id_sub) 
go
CREATE STATISTICS Statistic_id_po ON t_vw_allrateschedules_po (id_po) 
go
DROP STATISTICS t_vw_allrateschedules_po_icb.Statistic_id_sub
DROP STATISTICS t_vw_allrateschedules_po_icb.Statistic_id_po
DROP STATISTICS t_vw_allrateschedules_po_noicb.Statistic_id_sub
DROP STATISTICS t_vw_allrateschedules_po_noicb.Statistic_id_po
go
CREATE STATISTICS Statistic_id_sub ON t_vw_allrateschedules_po_icb (id_sub)  
CREATE STATISTICS Statistic_id_po ON t_vw_allrateschedules_po_icb (id_po)  
CREATE STATISTICS Statistic_id_sub ON t_vw_allrateschedules_po_noicb (id_sub)  
CREATE STATISTICS Statistic_id_po ON t_vw_allrateschedules_po_noicb (id_po) 
go
declare @name varchar(1000)
declare @stmt nvarchar(2000) 
select @name = a.name from sysobjects a, sysobjects b,sysconstraints c
where a.xtype='PK'
and b.xtype='U'
and b.name='t_sub'
and a.id=c.constid
and b.id=c.id
select @stmt = N'alter table t_sub drop constraint ' + @name
exec sp_executesql @stmt
go
create clustered index idx_t_sub on t_sub(id_sub)
GO
declare @name varchar(1000)
declare @stmt nvarchar(2000) 
select @name = a.name from sysobjects a, sysobjects b,sysconstraints c
where a.xtype='PK'
and b.xtype='U'
and b.name='t_sub_history'
and a.id=c.constid
and b.id=c.id
select @stmt = N'alter table t_sub_history drop constraint ' + @name
exec sp_executesql @stmt
go
create clustered index idx_t_sub_history on t_sub_history(id_sub,tt_end)
GO
declare @len_nm_name int
declare @name_nm_name nvarchar(100)
declare @nm_name nvarchar(100)
declare @nm_table_name nvarchar(100)
declare c1 cursor for select nm_name,nm_table_name from t_prod_view
begin
open c1 
fetch c1 into @nm_name,@nm_table_name
while (@@fetch_status = 0)
begin 
select @name_nm_name = REVERSE(substring(REVERSE(nm_name),1,charindex('/',REVERSE(nm_name))-1))
from t_prod_view where nm_table_name = @nm_table_name
select @len_nm_name = len(REVERSE(substring(REVERSE(nm_name),1,charindex('/',REVERSE(nm_name))-1)))
from t_prod_view where nm_table_name = @nm_table_name
if (@len_nm_name > 19)
begin
if object_id(@nm_table_name) is not null
begin
exec('sp_rename ' + @nm_table_name + ', ''t_pv_' + @name_nm_name + '''')
update t_prod_view set nm_table_name = 't_pv_' + @name_nm_name where nm_table_name = @nm_table_name
end
end
fetch next from c1 into @nm_name,@nm_table_name
end
close c1
deallocate c1
end
go

declare @len_nm_name int
declare @name_nm_name nvarchar(100)
declare @nm_name nvarchar(100)
declare @nm_table_name nvarchar(100)
declare c1 cursor for SELECT nm_instance_tablename, nm_name
          FROM t_rulesetdefinition,t_base_props
          WHERE t_base_props.id_prop = t_rulesetdefinition.id_paramtable
          and t_base_props.n_kind = 140
begin
open c1 
fetch c1 into @nm_table_name,@nm_name
while (@@fetch_status = 0)
begin 
	select @name_nm_name = REVERSE(substring(REVERSE(nm_name),1,charindex('/',REVERSE(nm_name))-1))
	from t_base_props where nm_name = @nm_name
	select @len_nm_name = len(REVERSE(substring(REVERSE(nm_name),1,charindex('/',REVERSE(nm_name))-1)))
	from t_base_props where nm_name = @nm_name
	if (@len_nm_name > 19)
	begin
		if object_id(@nm_table_name) is not null
		begin
			exec('sp_rename ' + @nm_table_name + ', ''t_pt_' + @name_nm_name + '''')
			update t_rulesetdefinition set nm_instance_tablename = 't_pt_' + @name_nm_name where nm_instance_tablename = @nm_table_name
		end
	end
	fetch next from c1 into @nm_table_name,@nm_name
end
close c1
deallocate c1
end
go
declare c1 cursor for select nm_table_name from t_service_def_log
declare @nm_table_name nvarchar(4000)
declare @nm_column_name nvarchar(4000)
begin
open c1
fetch c1 into @nm_table_name
while (@@fetch_status = 0)
begin
	declare c2 cursor for select distinct name from sys.columns
	where object_id = object_id(@nm_table_name)
	and name in ('_IntervalID','_TransactionCookie','_Resubmit','_CollectionID')
	open c2
	fetch c2 into @nm_column_name
	while (@@fetch_status = 0)
	begin
		print('sp_rename ''' + @nm_table_name + '.' + @nm_column_name + ''', ''c_' + @nm_column_name + ''',''column''')
		exec('sp_rename ''' + @nm_table_name + '.' + @nm_column_name + ''', ''c_' + @nm_column_name + ''',''column''')
		fetch next from c2 into @nm_column_name
	end
	close c2
	deallocate c2
fetch next from c1 into @nm_table_name
end
close c1
deallocate c1
end
go
UPDATE t_sys_upgrade
SET db_upgrade_status = 'C',
dt_end_db_upgrade = getdate()
WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)	
go
DROP INDEX [idx_billgroup_constraint] ON [dbo].[t_billgroup_constraint]
GO
CREATE CLUSTERED INDEX [idx_billgroup_constraint] ON [dbo].[t_billgroup_constraint] ([id_group], [id_usage_interval])
GO
DROP INDEX [idx_billgroup_constraint_tmp] ON [dbo].[t_billgroup_constraint_tmp]
GO
CREATE CLUSTERED INDEX [idx_billgroup_constraint_tmp] ON [dbo].[t_billgroup_constraint_tmp] ([id_group], [id_usage_interval])
GO
DROP INDEX [idx_billgroup_source_acc] ON [dbo].[t_billgroup_source_acc]
GO
CREATE CLUSTERED INDEX [idx_billgroup_source_acc] ON [dbo].[t_billgroup_source_acc] ([id_materialization], [id_acc])
GO
ALTER TABLE [dbo].[t_sub_history] ALTER COLUMN [id_sub] [int] NULL
GO
CREATE NONCLUSTERED INDEX [idx1_t_billgroup_constraint_tmp] ON [dbo].[t_billgroup_constraint_tmp] ([id_acc], [id_usage_interval])
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateProductViewPropertyFromName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateProductViewPropertyFromName]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reverse_UpdateStateFromPFBToClosed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reverse_UpdateStateFromPFBToClosed]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reverse_UpdateStateFromClosedToPFB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reverse_UpdateStateFromClosedToPFB]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reverse_UpdStateFromClosedToArchived]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reverse_UpdStateFromClosedToArchived]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SequencedInsertAccountOwnership]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SequencedInsertAccountOwnership]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SequencedDeleteAccountOwnership]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SequencedDeleteAccountOwnership]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SequencedUpsertAccountOwnership]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SequencedUpsertAccountOwnership]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateCompositeAdjustmentDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateCompositeAdjustmentDetails]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RemoveCompositeAdjustmentDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RemoveCompositeAdjustmentDetails]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateTestRecurringEventInstance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateTestRecurringEventInstance]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateIntervalAsBlockedForNewAccounts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateIntervalAsBlockedForNewAccounts]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateIntervalStatusToHardClosed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateIntervalStatusToHardClosed]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateAndPopulateTempAccountsTable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateAndPopulateTempAccountsTable]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateExpiredIntervalsToBlocked]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateExpiredIntervalsToBlocked]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[HardCloseExpiredIntervalsWithNoPayingAccounts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[HardCloseExpiredIntervalsWithNoPayingAccounts]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateAndPopulateTmpBillGroupStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateAndPopulateTmpBillGroupStatus]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[WarnOnEBCRMemberStartDateChange]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[WarnOnEBCRMemberStartDateChange]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_NOTDELETED_ADJUSTMENT_DETAILS]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[VW_NOTDELETED_ADJUSTMENT_DETAILS]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vw_account_productoffering_restrictions]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[vw_account_productoffering_restrictions]
GO
