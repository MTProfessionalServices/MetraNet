
				CREATE TABLE t_mview_catalog
						(id_mv number(10) NOT NULL,
						name nvarchar2 (200) NOT NULL,
						table_name nvarchar2 (200) NOT NULL,
						description nvarchar2 (2000),
						update_mode varchar2 (1) NOT NULL,
						query_path nvarchar2 (2000) NOT NULL,
						create_query_tag nvarchar2 (200) NOT NULL,
						drop_query_tag nvarchar2 (200),
						init_query_tag nvarchar2 (200),
						full_query_tag nvarchar2 (200) NOT NULL,
						progid nvarchar2 (200) NOT NULL,
						id_revision number(10) NOT NULL,
						tx_checksum varchar2 (100) NOT NULL,
						constraint pk_t_mview_catalog PRIMARY KEY
						(
							id_mv
						));

				CREATE TABLE t_mview_event
					(	id_event number(10) NOT NULL,
					id_mv number(10) NOT NULL,
					description nvarchar2 (2000),
					constraint pk_t_mview_event PRIMARY KEY
					(
						id_event
					),
					constraint fk_t_mview_event FOREIGN KEY
					(
						id_mv
					) REFERENCES t_mview_catalog (
						id_mv
					));

				CREATE TABLE t_mview_queries (
					id_event number(10) NOT NULL,
					operation_type varchar2 (1),
					update_query_tag nvarchar2 (200),
					constraint fk_t_mview_queries FOREIGN KEY
					(
						id_event
					) REFERENCES t_mview_event (
						id_event
					));

				CREATE TABLE t_mview_base_tables (
					id_event number(10) NOT NULL,
					base_table_name nvarchar2 (200),
					constraint fk_t_mview_base_tables FOREIGN KEY
					(
						id_event
					) REFERENCES t_mview_event (
						id_event
					));

				CREATE TABLE t_mview_map (
					base_table_name nvarchar2 (200) NOT NULL,
					mv_name nvarchar2(200) NOT NULL,
					global_index number(10) NOT NULL);

