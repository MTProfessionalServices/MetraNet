
              CREATE TABLE t_export_queue_report_queries
              (
                id_query VARCHAR2(100)  ,
                descr VARCHAR2(500)  ,
                query_string VARCHAR2(4000)  ,
                CONSTRAINT IX_t_export_queue_report_queri UNIQUE( id_query )
              )
		 