
CREATE TABLE t_agr_template_entity_map (
id_agr_template int not null,
id_entity int not null,
entity_type int not null,
constraint fk_id_agr_template FOREIGN KEY (id_agr_template) REFERENCES t_agr_template(id_agr_template)
)

