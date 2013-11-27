DECLARE
BEGIN	
INSERT ALL
INTO T_EXPORT_SCHEDULE
           (id_rep_instance_id
           ,id_schedule
           ,c_sch_type
           ,dt_crt)
    VALUES
           ((SELECT id_rep_instance_id 
				FROM t_export_report_instance ir
				JOIN t_export_reports r
				ON (ir.id_rep = r.id_rep)
				WHERE r.c_report_title = 'Report1-DiscSchedNoParCSV' and ROWNUM = 1) 
           ,1 -- id_schedule_dayli = 1 in t_sch_daily table
           ,'Daily'
           ,'18-Sep-12')
           
	INTO T_EXPORT_SCHEDULE
           (id_rep_instance_id
           ,id_schedule
           ,c_sch_type
           ,dt_crt)
    VALUES
           ((SELECT id_rep_instance_id 
				FROM t_export_report_instance ir
				JOIN t_export_reports r
				ON (ir.id_rep = r.id_rep)
				WHERE r.c_report_title = 'Report2-DiscSchedNoParXML' and ROWNUM = 1) 
           ,3 -- id_schedule_dayli = 2 in t_sch_daily table
           ,'Daily'
           ,'18-Sep-12')
SELECT * FROM dual;
COMMIT;         
END;
 /