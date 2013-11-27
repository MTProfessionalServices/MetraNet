
				CREATE OR REPLACE PROCEDURE GENERATEADJUSTMENTTABLES
				as
				count pls_integer;
				ddlstr  varchar2(4000);
				tableExists int := 0;
				begin

					for table_cur in (
									select distinct(pv.nm_table_name) as c_pvname,
									't_aj_' || substr(pv.nm_table_name,6) as c_adjname,
									t_pi.id_pi as c_idpi
									from
									t_pi
									INNER JOIN t_prod_view pv on upper(pv.nm_name) = Upper(t_pi.nm_productview)
									LEFT OUTER JOIN t_charge on t_charge.id_pi = t_pi.id_pi
									)
					loop
						begin
							/* drop the table if it exists */
							SELECT COUNT('X') INTO tableExists from user_tables where upper(table_name) = upper(table_cur.c_adjname);
							if tableExists <> 0 then /* table exists, drop the table */
								 EXECUTE IMMEDIATE 'DROP TABLE ' || table_cur.c_adjname;
							end if;
							/* create the table */
							ddlstr := 'create table ' || table_cur.c_adjname || ' (id_adjustment int';
							for column_cur in (		
									select prop.nm_column_name,prop.nm_data_type from t_charge
										INNER JOIN t_prod_view_prop prop on prop.id_prod_view_prop = t_charge.id_amt_prop
										where id_pi = table_cur.c_idpi
									)
							loop
							  begin
									ddlstr := ddlstr || ', c_aj_' || substr(column_cur.nm_column_name,3) || ' ' || column_cur.nm_data_type;
						   end;
							end loop;
						ddlstr := ddlstr || ')';
						EXECUTE IMMEDIATE ddlstr;
						end;
					end loop;
				end;
		