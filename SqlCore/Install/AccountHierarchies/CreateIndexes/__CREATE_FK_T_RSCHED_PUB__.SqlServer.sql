
ALTER TABLE t_rsched_pub
ADD CONSTRAINT fk5_t_rsched_pub FOREIGN KEY (id_pt)
REFERENCES t_rulesetdefinition (id_paramtable)

ALTER TABLE t_rsched_pub
ADD CONSTRAINT fk4_t_rsched_pub FOREIGN KEY (id_pricelist)
REFERENCES t_pricelist (id_pricelist)

ALTER TABLE t_rsched_pub
ADD CONSTRAINT fk2_t_rsched_pub FOREIGN KEY (id_eff_date)
REFERENCES t_effectivedate (id_eff_date)

ALTER TABLE t_rsched_pub
ADD CONSTRAINT fk1_t_rsched_pub FOREIGN KEY (id_sched)
REFERENCES t_base_props (id_prop)

