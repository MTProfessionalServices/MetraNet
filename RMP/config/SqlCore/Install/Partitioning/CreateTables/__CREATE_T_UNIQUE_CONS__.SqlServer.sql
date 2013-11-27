
				create table [dbo].[t_unique_cons] (
					[id_unique_cons] [int] identity (1, 1) not null ,
					[id_prod_view] [int] not null ,
					[constraint_name] [nvarchar] (400) not null ,
					[nm_table_name] [nvarchar] (400) not null ,
					constraint [pk_t_unique_cons] primary key  clustered 
					(
						[id_unique_cons]
					) ,
					constraint [uk1_t_unique_cons] unique  nonclustered 
					(
						[constraint_name]
					)
				)
			