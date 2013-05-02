
				CREATE or replace PROCEDURE DeleteProductViewRecords(
				nm_productview varchar2,
				id_pi_template int,
				id_interval int,
				id_view int)
				AS
 				pv_delete_stmt varchar2(1000);
 				usage_delete_stmt varchar2(1000);
 				strInterval varchar2(255);
 				strPITemplate varchar2(255);
				strViewID varchar2(255);
 			  WhereClause varchar2(255);
				/* convert int to strings */
				begin
					strInterval := to_char(id_interval);
					strPITemplate := to_char(id_pi_template);
					strViewID := to_char(id_view);
					WhereClause := 'WHERE id_usage_interval='||' '||strInterval||' '||
												 'AND id_pi_template='||' '||strPITemplate||' '||
												 'AND id_view='||' '||strViewID;
					pv_delete_stmt := 'DELETE FROM ' || nm_productview ||  ' WHERE 
					exists (select 1 from t_acc_usage au '
					 || WhereClause ||
					' and au.id_sess = ' 
					|| nm_productview || '.id_sess and au.id_usage_interval = '
					|| nm_productview || '.id_usage_interval)';

					usage_delete_stmt := 'DELETE FROM t_acc_usage '||'  '||WhereClause;
					
					EXECUTE immediate pv_delete_stmt;
					EXECUTE immediate usage_delete_stmt;
				end;
				