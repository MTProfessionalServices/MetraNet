
			  create procedure DeleteRateSchedule
				(
					@schedId int,
					@status int output
				)
				as
				BEGIN
					declare @effDateId int, @ptTableName varchar(100)

					select @effDateId = id_eff_date, @ptTableName = rsd.nm_instance_tablename
					from 
						t_rsched rs with(updlock)
						inner join
						t_rulesetdefinition rsd on rs.id_pt = rsd.id_paramtable  
					where id_sched = @schedId
					
					/* Delete rate entries */
					declare @deleteStmt varchar(200)
					set @deleteStmt = 'Delete from ' + @ptTableName + ' where id_sched = ' + CAST(@schedId as varchar)
					Execute( @deleteStmt)
					
					/* Delete rate schedule record */
					delete from t_rsched where id_sched = @schedId
					
					/* Delete effective date entry */
					delete from t_effectivedate where id_eff_date = @effDateId
					
					/* Delete rate schedule base props */
					exec DeleteBaseProps @schedId
					
					set @status = 0
				END
				