
      create table [t_partition_storage] (
      	[id_path] [int] not null ,
      	[b_next] [char] (1) ,
      	[path] [varchar] (500) 
      	constraint [pk_t_partition_storage] primary key  clustered 
      	(
      		[id_path]
      	) 
      ) 
 	