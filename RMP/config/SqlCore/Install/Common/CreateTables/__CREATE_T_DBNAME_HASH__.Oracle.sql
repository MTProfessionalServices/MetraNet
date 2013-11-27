
    create table t_dbname_hash (
	    name_hash nvarchar2(30) not null,
	    name nvarchar2(128) not null,
	    primary key (name),
	    unique (name_hash)
	    )
				