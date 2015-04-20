UPDATE [dbo].[t_sys_upgrade]
  SET db_upgrade_status = 'C', dt_end_db_upgrade = getdate()
  WHERE 
    upgrade_id = (SELECT MAX(upgrade_id) FROM [dbo].[t_sys_upgrade]) AND 
	db_upgrade_status = 'R'
