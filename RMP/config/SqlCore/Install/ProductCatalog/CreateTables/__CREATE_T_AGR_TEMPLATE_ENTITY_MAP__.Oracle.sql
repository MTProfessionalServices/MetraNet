
CREATE TABLE t_agr_template_entity_map
  (
    id_agr_template NUMBER(10) NOT NULL,
    id_entity       NUMBER(10) NOT NULL,
    entity_type     NUMBER(10) NOT NULL,
    constraint fk_id_agr_template FOREIGN KEY (id_agr_template) REFERENCES t_agr_template(id_agr_template)
  )
  
			