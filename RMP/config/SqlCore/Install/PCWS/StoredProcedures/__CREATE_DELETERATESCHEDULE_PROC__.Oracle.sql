
				CREATE OR REPLACE PROCEDURE DELETERATESCHEDULE
			   (
					p_schedId int,
					p_status out int
				)
				as
					p_effDateId int;
					p_ptTableName varchar2(100);
					p_deleteStmt varchar2(200);
				BEGIN
					/* Get Effective date ID and Parameter table name*/
					select rs.id_eff_date, rsd.nm_instance_tablename into p_effDateId, p_ptTableName
                    from t_rsched rs
                    inner join
						t_rulesetdefinition rsd on rs.id_pt = rsd.id_paramtable
					where
						rs.id_sched = p_schedId;
					
					p_deleteStmt := 'Delete from ' || p_ptTableName || ' where id_sched = ' || CAST(p_schedId as varchar2);
					execute immediate p_deleteStmt;
					
					/* Delete rate schedule record */
					delete from t_rsched where id_sched = p_schedId;
					
					/* Delete effective date entry */
					delete from t_effectivedate where id_eff_date = p_effDateId;
					
					/* Delete rate schedule base props */
					DeleteBaseProps( p_schedId );
					
					p_status := 0;
				END;			   
				