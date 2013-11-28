/* In this file there are changes that relates to performance tunning only
Due to index recreation execution will take magority time for 702-710 DB Upgrade */

/* t_acc_usage INDEX modification*/
DROP INDEX idx_acc_ui_view_ind
/

CREATE INDEX idx_acc_ui_view_ind ON t_acc_usage(id_acc,id_view,id_usage_interval)
/


/* t_tax_details PK modification*/
ALTER TABLE t_tax_details DROP PRIMARY KEY DROP INDEX
/

ALTER TABLE t_tax_details ADD CONSTRAINT pk_t_tax_details PRIMARY KEY (id_usage_interval,id_tax_run,id_tax_detail,id_tax_charge) USING INDEX (CREATE INDEX pk_t_tax_details ON t_tax_details
(id_usage_interval,id_tax_run,id_tax_detail,id_tax_charge)  )
/


/* agg_decision_rollover PK modification*/
ALTER TABLE agg_decision_rollover DROP PRIMARY KEY DROP INDEX
/

ALTER TABLE agg_decision_rollover ADD CONSTRAINT agg_dec_rollover_pk PRIMARY KEY (id_acc,id_usage_interval,end_date,decision_unique_id,rollover_action)
/


/* t_tax_run INDEX modification*/
DROP INDEX idx_tax_run1
/

CREATE UNIQUE INDEX idx_tax_run1 ON t_tax_run(id_vendor,id_usage_interval,id_billgroup,dt_start,dt_end,is_audited)
/


/* tx_failureid_idx INDEX added */
CREATE INDEX tx_failureid_idx ON t_failed_transaction(tx_failureid)
/
