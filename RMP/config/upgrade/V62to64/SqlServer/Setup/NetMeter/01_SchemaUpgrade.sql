use %%NETMETER%%
go

set nocount on
go

INSERT INTO t_sys_upgrade
(target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
('6.4', getdate(), 'R')
go

/**************************************************************/
/***** Perform Schema Upgrades                            *****/
/**************************************************************/

/* BEGIN OF CORE-3774 */
/* Migrate these old 4.0 32-bit sequences if not already */
/* defined in t_current_long_id. */
insert into t_current_long_id (id_current, nm_current)
  select CAST(id_current as BIGINT), nm_current
  from t_current_id oldseq
  where oldseq.nm_current in ('id_dbqueue', 'id_sess')
  and not exists (
   select * from t_current_long_id newseq
   where newseq.nm_current = oldseq.nm_current
  )
go
/* Remove these old 4.0 32-bit sequences, */
/* if they exist, from t_current_id. */
delete from t_current_id
  where nm_current in ('id_dbqueue', 'id_sess')
go
/* Add the 5.0 32-bit sequence id_failed_txn */
/* if it does not exist. */
declare @l_max_id INT
select @l_max_id=COALESCE(MAX(id_failed_transaction),999) 
  from t_failed_transaction 
insert into t_current_id (id_current, nm_current, id_min_id)
  select @l_max_id + 1, 'id_failed_txn', @l_max_id + 1 
  where not exists
  (select * from t_current_id where nm_current = 'id_failed_txn')
go
/* Add the 5.0 32-bit sequence id_acc */
/* if it does not exist. */
declare @l_max_id INT
select @l_max_id=COALESCE(MAX(id_acc),122) 
  from t_account 
insert into t_current_id (id_current, nm_current, id_min_id)
  select @l_max_id + 1, 'id_acc', @l_max_id + 1
  where not exists
  (select * from t_current_id where nm_current = 'id_acc')
go
/* END OF CORE-3774 */

/**************************************************************/
/***** All Done                                           *****/
/**************************************************************/

UPDATE t_sys_upgrade
SET db_upgrade_status = 'C',
dt_end_db_upgrade = getdate()
WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)	
go
