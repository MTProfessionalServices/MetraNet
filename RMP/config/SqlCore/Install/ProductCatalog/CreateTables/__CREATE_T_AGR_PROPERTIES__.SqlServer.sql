
    CREATE TABLE t_agr_properties (
     id_agr_template int not null,
     effective_start_date    DATETIME NULL,
     effective_end_date      DATETIME NULL,
     constraint fk_id_agr_properties FOREIGN KEY (id_agr_template) REFERENCES t_agr_template(id_agr_template)
    )

