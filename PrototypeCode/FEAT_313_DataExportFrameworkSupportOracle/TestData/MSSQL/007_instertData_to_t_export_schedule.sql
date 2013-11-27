INSERT INTO T_EXPORT_SCHEDULE
           (id_rep_instance_id
           ,id_schedule
           ,c_sch_type
           ,dt_crt)
    VALUES
           ((SELECT TOP(1) id_rep_instance_id 
				FROM t_export_report_instance ir
				JOIN t_export_reports r
				ON (ir.id_rep = r.id_rep)
				WHERE r.c_report_title = 'Report1-DiscSchedNoParCSV') 
           ,1 -- id_schedule_dayli = 1 in t_sch_daily table
           ,'Daily'
           ,'18-Sep-12')
           
INSERT INTO T_EXPORT_SCHEDULE
           (id_rep_instance_id
           ,id_schedule
           ,c_sch_type
           ,dt_crt)
    VALUES
           ((SELECT TOP(1) id_rep_instance_id 
				FROM t_export_report_instance ir
				JOIN t_export_reports r
				ON (ir.id_rep = r.id_rep)
				WHERE r.c_report_title = 'Report2-DiscSchedNoParXML') 
           ,2 -- id_schedule_dayli = 2 in t_sch_daily table
           ,'Daily'
           ,'18-Sep-12')