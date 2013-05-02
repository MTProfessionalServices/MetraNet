
CREATE TABLE t_acctype_descendenttype_map
(
 id_type number(10) not null,
 id_descendent_type number(10) not null,
 CONSTRAINT pk_acctype_destype_map PRIMARY KEY (id_type, id_descendent_type) 
)
			