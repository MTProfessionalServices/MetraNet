
				-- Create matertialized view catalog table
				CREATE TABLE [t_mview_catalog]
						([id_mv] [int] IDENTITY (1, 1) NOT NULL,
						[name] [nvarchar] (200) NOT NULL,
						[table_name] [nvarchar] (200) NOT NULL,
						[description] [nvarchar] (4000),
						[update_mode] [varchar] (1) NOT NULL,
						[query_path] [nvarchar] (4000) NOT NULL,
						[create_query_tag] [nvarchar] (200) NOT NULL,
						[drop_query_tag] [nvarchar] (200),
						[init_query_tag] [nvarchar] (200),
						[full_query_tag] [nvarchar] (200) NOT NULL,
						[progid] [nvarchar] (200) NOT NULL,
						[id_revision] [int] NOT NULL,
						[tx_checksum] [varchar] (100) NOT NULL,
						PRIMARY KEY  CLUSTERED
						(
							[id_mv]
						) ON [PRIMARY] 	)

				-- Create matertialized view event table
				CREATE TABLE [t_mview_event]
					(	[id_event] [int] IDENTITY (1, 1) NOT NULL,
					[id_mv] [int] NOT NULL,
					[description] [nvarchar] (4000),
					PRIMARY KEY  CLUSTERED
					(
						[id_event]
					) ON [PRIMARY],
					FOREIGN KEY
					(
						[id_mv]
					) REFERENCES [t_mview_catalog] (
						[id_mv]
					)	)

				-- Create matertialized view queries table
				CREATE TABLE [t_mview_queries] (
					[id_event] [int] NOT NULL,
					[operation_type] [varchar] (1),
					[update_query_tag] [nvarchar] (200),
					FOREIGN KEY
					(
						[id_event]
					) REFERENCES [t_mview_event] (
						[id_event]
					)	)

				-- Create matertialized view "base tables" table
				CREATE TABLE [t_mview_base_tables] (
					[id_event] [int] NOT NULL,
					[base_table_name] [nvarchar] (200),
					FOREIGN KEY
					(
						[id_event]
					) REFERENCES [t_mview_event] (
						[id_event]
					)	)

				-- Create matertialized view map table
				CREATE TABLE [t_mview_map] (
					[base_table_name] [nvarchar] (200) NOT NULL,
					[mv_name] [nvarchar] (200) NOT NULL,
					[global_index] [int] NOT NULL	)
				