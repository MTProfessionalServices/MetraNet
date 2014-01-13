
		create procedure sp_DeleteRateSchedule 
			@a_rsID int
		as
		begin
			declare @id_effdate int
			declare @id_paramtbl int
			declare @nm_paramtbl NVARCHAR(255)
			declare @SQLString NVARCHAR(255)

			-- Find the information we need to delete rates
			set @id_effdate = (select id_eff_date from t_rsched where id_sched = @a_rsID)
			set @id_paramtbl = (select id_pt from t_rsched where id_sched = @a_rsID)			
			set @nm_paramtbl = (select nm_instance_tablename from t_rulesetdefinition where id_paramtable = @id_paramtbl)

			-- Create the delete statement for the particular rule table and execute it
			set @SQLString = N'delete from ' + @nm_paramtbl + ' where id_sched = ' + CAST(@a_rsID AS NVARCHAR(10))
			execute sp_executesql @SQLString

			-- Delete the remaining rate schedule info
			delete from t_rsched where id_sched = @a_rsID
			delete from t_effectivedate where id_eff_date = @id_effdate
			execute DeleteBaseProps @a_rsID
		end
		