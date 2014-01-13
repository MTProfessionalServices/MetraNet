       
			CREATE TABLE [t_partition] (
				[id_partition] [int] IDENTITY (1, 1) NOT NULL ,
				[partition_name] [nvarchar] (30) NOT NULL ,
				[dt_start] [datetime] NOT NULL ,
				[dt_end] [datetime] NOT NULL ,
				[id_interval_start] [int] NOT NULL ,
				[id_interval_end] [int] NOT NULL ,
				[b_default] [char] (1) NOT NULL ,
				[b_active] [char] (1) NOT NULL ,
				CONSTRAINT [pk_t_partition] PRIMARY KEY  CLUSTERED 
				(
					[id_partition]
				)  ,
				CONSTRAINT [uk1_t_partition] UNIQUE  NONCLUSTERED 
				(
					[partition_name]
				)  
			) 
			