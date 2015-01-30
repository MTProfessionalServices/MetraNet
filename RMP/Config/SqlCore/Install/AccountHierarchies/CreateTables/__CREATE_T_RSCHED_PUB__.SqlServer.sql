
CREATE TABLE t_rsched_pub
(
    id_sched                       int NOT NULL,
    id_pt                          int NOT NULL,
    id_eff_date                    int NOT NULL,
    id_pricelist                   int NOT NULL,
    dt_mod                         datetime,
    id_pi_template                 int NOT NULL,
    CONSTRAINT t_rsched_pub_pk PRIMARY KEY (id_sched)
)

