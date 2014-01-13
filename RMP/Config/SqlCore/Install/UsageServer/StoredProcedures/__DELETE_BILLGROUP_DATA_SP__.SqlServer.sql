
/* ===========================================================
Delete billing group data
=========================================================== */
CREATE PROCEDURE DeleteBillGroupData
(
  @tableName VARCHAR(20)
)
AS
BEGIN
   BEGIN TRAN
   
   DECLARE @sql NVARCHAR(4000)
 
   /* Hold the specified billing group id's in  @billgroups */
   /* Insert the billgroup id's in the table specified by @tableName into @billgroups such
        that pull lists come first */
   SET @sql = N'DECLARE @billgroups TABLE '+
                        '( ' + 
                        '  id_billgroup INT NOT NULL, '+
                        '  id_usage_interval INT NOT NULL ' +
                        ') ' +
                        'INSERT INTO  @billgroups ' + 
                        'SELECT t.id_billgroup, bg.id_usage_interval ' +
                        'FROM ' +
                        @tableName + ' t ' +
                        'INNER JOIN t_billgroup bg ' +
                        'ON bg.id_billgroup = t.id_billgroup ' +
                        'ORDER BY bg.id_parent_billgroup DESC ' +

                         -- delete from t_billgroup_member
                        'DELETE bgm ' +
                        'FROM t_billgroup_member bgm ' +
                        'INNER JOIN t_billgroup bg ' +
                        'ON bg.id_billgroup = bgm.id_billgroup ' +
                        'INNER JOIN @billgroups bgt ' +
                        'ON bgt.id_billgroup = bgm.id_billgroup AND ' +
                        'bgt.id_usage_interval = bg.id_usage_interval ' +

                        -- delete from t_billgroup_member_history
		 'DELETE bgmh ' +
		 'FROM t_billgroup_member_history bgmh ' +
		 'INNER JOIN t_billgroup bg ' +
		 '  ON bg.id_billgroup = bgmh.id_billgroup ' +
		 'INNER JOIN @billgroups bgt ' +
		 '  ON bgt.id_billgroup = bgmh.id_billgroup AND ' +
		 '        bgt.id_usage_interval = bg.id_usage_interval ' +

		-- delete from t_billgroup
		'DELETE bg ' +
		'FROM t_billgroup bg ' +
		'INNER JOIN @billgroups bgt ' +
		'  ON bgt.id_billgroup = bg.id_billgroup AND ' +
		'        bgt.id_usage_interval = bg.id_usage_interval ' +
		 
   		-- delete from t_recevent_run_details
		 'DELETE rrd ' +
		 'FROM t_recevent_run_details rrd ' +
                         'INNER JOIN t_recevent_run rr ' +
                         ' ON rr.id_run = rrd.id_run ' +
		 'INNER JOIN t_recevent_inst ri ' +
                         ' ON ri.id_instance = rr.id_instance ' +
                         'INNER JOIN @billgroups bgt ' +
                         ' ON bgt.id_billgroup = ri.id_arg_billgroup AND ' +
                         '       bgt.id_usage_interval = ri.id_arg_interval ' +

                         -- delete from t_recevent_run_batch
		 'DELETE rrb ' +
		 'FROM t_recevent_run_batch rrb ' +
                         'INNER JOIN t_recevent_run rr ' +
                         ' ON rr.id_run = rrb.id_run ' +
                         'INNER JOIN t_recevent_inst ri ' +
                         ' ON ri.id_instance = rr.id_instance ' +
                         'INNER JOIN @billgroups bgt ' +
                         ' ON bgt.id_billgroup = ri.id_arg_billgroup AND ' +
                         '       bgt.id_usage_interval = ri.id_arg_interval ' +

                         -- delete from t_recevent_run_failure_acc
		 'DELETE rrf ' +
		 'FROM t_recevent_run_failure_acc rrf ' +
                         'INNER JOIN t_recevent_run rr ' +
                         ' ON rr.id_run = rrf.id_run ' +
		 'INNER JOIN t_recevent_inst ri ' +
                         ' ON ri.id_instance = rr.id_instance ' +
                         'INNER JOIN @billgroups bgt ' +
                         ' ON bgt.id_billgroup = ri.id_arg_billgroup AND ' +
                         '       bgt.id_usage_interval = ri.id_arg_interval ' +

                         -- delete from t_recevent_run
		 'DELETE rr ' +
		 'FROM t_recevent_run rr ' +
                         'INNER JOIN t_recevent_inst ri ' +
                         ' ON ri.id_instance = rr.id_instance ' +
                         'INNER JOIN @billgroups bgt ' +
                         ' ON bgt.id_billgroup = ri.id_arg_billgroup AND ' +
                         '       bgt.id_usage_interval = ri.id_arg_interval ' +
   
                         -- delete from t_recevent_inst_audit
		 'DELETE ria ' +
		 'FROM t_recevent_inst_audit ria ' +
                         'INNER JOIN t_recevent_inst ri ' +
                         ' ON ri.id_instance = ria.id_instance ' +
                         'INNER JOIN @billgroups bgt ' +
                         ' ON bgt.id_billgroup = ri.id_arg_billgroup AND ' +
                         '       bgt.id_usage_interval = ri.id_arg_interval ' +
  
 	             -- delete from t_recevent_inst
		 'DELETE ri ' +
		 'FROM t_recevent_inst ri ' +
                         'INNER JOIN @billgroups bgt ' +
                         ' ON bgt.id_billgroup = ri.id_arg_billgroup AND ' +
                         '       bgt.id_usage_interval = ri.id_arg_interval ' 

   PRINT @sql
   EXEC sp_executesql @sql 

   COMMIT TRAN
END
