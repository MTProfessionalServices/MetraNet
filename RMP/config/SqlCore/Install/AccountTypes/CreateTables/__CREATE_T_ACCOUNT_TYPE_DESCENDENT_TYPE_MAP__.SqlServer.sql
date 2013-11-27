
CREATE TABLE t_acctype_descendenttype_map
(
 id_type int not null,
 id_descendent_type int not null,
 CONSTRAINT pk_t_acctype_descendenttype_map PRIMARY KEY CLUSTERED (id_type, id_descendent_type) 
)
			