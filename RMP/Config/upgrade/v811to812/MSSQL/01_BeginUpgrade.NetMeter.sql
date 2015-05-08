DECLARE @version varchar(50)
SET @version='8.1.2'

IF NOT EXISTS ( SELECT 1 FROM [dbo].[t_sys_upgrade] WHERE target_db_version = @version )
  INSERT INTO [dbo].[t_sys_upgrade]
    ( target_db_version, dt_start_db_upgrade, db_upgrade_status)
  VALUES
    ( @version, GETDATE(), 'R');