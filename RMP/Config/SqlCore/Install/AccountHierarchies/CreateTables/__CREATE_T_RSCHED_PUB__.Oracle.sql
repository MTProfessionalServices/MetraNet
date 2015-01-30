
CREATE TABLE t_rsched_pub
(
    id_sched                       NUMBER(10,0) NOT NULL,
    id_pt                          NUMBER(10,0) NOT NULL,
    id_eff_date                    NUMBER(10,0) NOT NULL,
    id_pricelist                   NUMBER(10,0) NOT NULL,
    dt_mod                         DATE,
    id_pi_template                 NUMBER(10,0) NOT NULL,
    CONSTRAINT t_rsched_pub_pk PRIMARY KEY (id_sched)
)

