
	   CREATE TABLE t_agr_properties
  (
     id_agr_template         number(10) NOT NULL,
     effective_start_date    DATE DEFAULT sysdate NULL,
     effective_end_date      DATE DEFAULT TO_DATE('2038-01-01', 'YYYY-MM-DD') NULL,
     constraint fk_id_agr_properties FOREIGN KEY (id_agr_template) REFERENCES t_agr_template(id_agr_template)
  )
  		