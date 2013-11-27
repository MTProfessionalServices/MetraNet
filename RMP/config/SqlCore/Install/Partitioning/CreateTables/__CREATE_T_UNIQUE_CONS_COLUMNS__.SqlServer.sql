
			create table [dbo].[t_unique_cons_columns] (
				[id_unique_cons] [int] not null ,
				[id_prod_view_prop] [int] not null ,
				[position] [int] not null ,
				constraint [pk_t_unique_cons_col] primary key  clustered 
				(
					[id_unique_cons],
					[id_prod_view_prop]
				)  ,
				constraint [uk1_t_unique_cons_col] unique  nonclustered 
				(
					[id_unique_cons],
					[position]
				)  
			)
			