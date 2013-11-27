
		create table t_view_hierarchy
		(id_view INTEGER NOT NULL,
		id_view_parent INTEGER,
		CONSTRAINT PK_t_view_hierarchy PRIMARY KEY CLUSTERED (id_view, id_view_parent))
		