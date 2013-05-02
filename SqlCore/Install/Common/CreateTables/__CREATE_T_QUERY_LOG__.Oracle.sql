
			CREATE TABLE t_query_log (
				c_id number(10) NOT NULL ,
				c_groupid varchar2(50) NOT NULL ,
				c_id_view number(10) NULL ,
				c_old_schema varchar2(4000) NOT NULL ,
				c_query nvarchar2(2000) NOT NULL ,
				c_timestamp date DEFAULT sysdate  NOT NULL
			)
		