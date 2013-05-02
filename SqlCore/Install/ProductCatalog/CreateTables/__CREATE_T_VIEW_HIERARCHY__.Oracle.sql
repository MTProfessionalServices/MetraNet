
create table t_view_hierarchy(id_view number(10) NOT NULL, 
                              id_view_parent number(10),
					                    CONSTRAINT PK_t_view_hierarchy PRIMARY KEY (id_view, id_view_parent))
		