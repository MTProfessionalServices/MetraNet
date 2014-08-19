/*
  Upgrade Oracle NetMeter database to 8.0
*/
SET DEFINE OFF

ALTER TABLE t_acc_usage DROP CONSTRAINT fk2_t_acc_usage;

ALTER TABLE t_acc_usage DROP CONSTRAINT fk3_t_acc_usage;

COMMENT ON TABLE t_acc_usage IS '';

COMMENT ON COLUMN t_acc_usage.id_sess IS '';

COMMENT ON COLUMN t_acc_usage.tx_uid IS '';

COMMENT ON COLUMN t_acc_usage.id_acc IS '';

COMMENT ON COLUMN t_acc_usage.id_payee IS '';

COMMENT ON COLUMN t_acc_usage.id_view IS '';

COMMENT ON COLUMN t_acc_usage.id_usage_interval IS '';

COMMENT ON COLUMN t_acc_usage.id_parent_sess IS '';

COMMENT ON COLUMN t_acc_usage.id_prod IS '';

COMMENT ON COLUMN t_acc_usage.id_svc IS '';

COMMENT ON COLUMN t_acc_usage.dt_session IS '';

COMMENT ON COLUMN t_acc_usage.amount IS '';

COMMENT ON COLUMN t_acc_usage.am_currency IS '';

COMMENT ON COLUMN t_acc_usage.dt_crt IS '';

COMMENT ON COLUMN t_acc_usage.tx_batch IS '';

COMMENT ON COLUMN t_acc_usage.tax_federal IS '';

COMMENT ON COLUMN t_acc_usage.tax_state IS '';

COMMENT ON COLUMN t_acc_usage.tax_county IS '';

COMMENT ON COLUMN t_acc_usage.tax_local IS '';

COMMENT ON COLUMN t_acc_usage.tax_other IS '';

COMMENT ON COLUMN t_acc_usage.id_pi_instance IS '';

COMMENT ON COLUMN t_acc_usage.id_pi_template IS '';

COMMENT ON COLUMN t_acc_usage.id_se IS '';

COMMENT ON COLUMN t_acc_usage.div_currency IS '';

COMMENT ON COLUMN t_acc_usage.div_amount IS '';

COMMENT ON COLUMN t_acc_usage.tax_calculated IS '';

COMMENT ON COLUMN t_acc_usage.tax_informational IS '';

ALTER TABLE t_acc_usage DROP PRIMARY KEY DROP INDEX;

ALTER TABLE t_acc_usage ADD CONSTRAINT pk_t_acc_usage PRIMARY KEY (id_sess,id_usage_interval) USING INDEX (CREATE INDEX pk_t_acc_usage ON t_acc_usage(id_sess,id_usage_interval)  );

COMMENT ON TABLE t_message IS '';

COMMENT ON COLUMN t_message.id_message IS '';

COMMENT ON COLUMN t_message.id_route IS '';

COMMENT ON COLUMN t_message.dt_crt IS '';

COMMENT ON COLUMN t_message.dt_metered IS '';

COMMENT ON COLUMN t_message.dt_assigned IS '';

COMMENT ON COLUMN t_message.id_listener IS '';

COMMENT ON COLUMN t_message.id_pipeline IS '';

COMMENT ON COLUMN t_message.dt_completed IS '';

COMMENT ON COLUMN t_message.id_feedback IS '';

COMMENT ON COLUMN t_message.tx_transactionid IS '';

COMMENT ON COLUMN t_message.tx_sc_username IS '';

COMMENT ON COLUMN t_message.tx_sc_password IS '';

COMMENT ON COLUMN t_message.tx_sc_namespace IS '';

COMMENT ON COLUMN t_message.tx_sc_serialized IS '';

COMMENT ON COLUMN t_message.tx_ip_address IS '';

COMMENT ON COLUMN t_message.id_partition IS '';

ALTER TABLE t_message DROP PRIMARY KEY DROP INDEX;

ALTER TABLE t_message ADD CONSTRAINT pk_t_message PRIMARY KEY (id_message,id_partition) USING INDEX (CREATE INDEX pk_t_message ON t_message(id_message,id_partition)  );

COMMENT ON TABLE t_session IS '';

COMMENT ON COLUMN t_session.id_ss IS '';

COMMENT ON COLUMN t_session.id_source_sess IS '';

ALTER TABLE t_session DROP PRIMARY KEY DROP INDEX;

ALTER TABLE t_session ADD CONSTRAINT pk_t_session PRIMARY KEY (id_ss,id_source_sess,id_partition) USING INDEX (CREATE INDEX pk_t_session ON t_session(id_ss,id_source_sess,id_partition)  );

COMMENT ON TABLE t_session_set IS '';

COMMENT ON COLUMN t_session_set.id_message IS '';

COMMENT ON COLUMN t_session_set.id_ss IS '';

COMMENT ON COLUMN t_session_set.id_svc IS '';

COMMENT ON COLUMN t_session_set.b_root IS '';

COMMENT ON COLUMN t_session_set.session_count IS '';

ALTER TABLE t_session_set DROP PRIMARY KEY DROP INDEX;

ALTER TABLE t_session_set ADD CONSTRAINT pk_t_session_set PRIMARY KEY (id_ss,id_partition) USING INDEX (CREATE INDEX pk_t_session_set ON t_session_set(id_ss,id_partition)  );

COMMENT ON TABLE t_session_state IS '';

COMMENT ON COLUMN t_session_state.id_sess IS '';

COMMENT ON COLUMN t_session_state.dt_start IS '';

COMMENT ON COLUMN t_session_state.dt_end IS '';

COMMENT ON COLUMN t_session_state.tx_state IS '';

ALTER TABLE t_session_state DROP PRIMARY KEY DROP INDEX;

ALTER TABLE t_session_state ADD CONSTRAINT pk_t_session_state PRIMARY KEY (id_sess,dt_end,tx_state,id_partition) USING INDEX (CREATE INDEX pk_t_session_state ON t_session_state(id_sess,dt_end,tx_state,id_partition)  );

COMMENT ON TABLE t_tax_details IS '';

ALTER TABLE t_tax_details MODIFY (is_implied DEFAULT NULL);

COMMENT ON COLUMN t_tax_details.id_tax_detail IS '';

COMMENT ON COLUMN t_tax_details.id_tax_charge IS '';

COMMENT ON COLUMN t_tax_details.id_acc IS '';

COMMENT ON COLUMN t_tax_details.id_usage_interval IS '';

COMMENT ON COLUMN t_tax_details.id_tax_run IS '';

COMMENT ON COLUMN t_tax_details.tax_amount IS '';

COMMENT ON COLUMN t_tax_details.rate IS '';

COMMENT ON COLUMN t_tax_details.tax_jur_level IS '';

COMMENT ON COLUMN t_tax_details.tax_jur_name IS '';

COMMENT ON COLUMN t_tax_details.tax_type IS '';

COMMENT ON COLUMN t_tax_details.tax_type_name IS '';

COMMENT ON COLUMN t_tax_details.is_implied IS '';

COMMENT ON COLUMN t_tax_details.notes IS '';

ALTER TABLE t_tax_details DROP PRIMARY KEY DROP INDEX;

ALTER TABLE t_tax_details ADD CONSTRAINT pk_t_tax_details PRIMARY KEY (id_usage_interval,id_tax_charge,id_tax_detail,id_tax_run) USING INDEX (CREATE INDEX pk_t_tax_details ON t_tax_details(id_usage_interval,id_tax_charge,id_tax_detail,id_tax_run)  );

ALTER TABLE agg_decision_audit_trail ADD (tt_end DATE);

CREATE TABLE t_aj_translationprodview (
  id_adjustment NUMBER(10)
);

COMMENT ON TABLE t_aj_translationprodview IS 'Autogenerated adjustment table. Contains adjustments for charges in product view table "t_pv_TranslationProdView"';

CREATE GLOBAL TEMPORARY TABLE tt_tmpreconcilemessagetable (
  id_message NUMBER(10) NOT NULL,
  dt_completed DATE,
  dt_assigned DATE,
  b_root CHAR,
  id_ss NUMBER(10) NOT NULL,
  id_svc NUMBER(10),
  id_partition NUMBER(10),
  id_source_sess RAW(16) NOT NULL,
  dt_metered DATE,
  tx_ip_address VARCHAR2(15 BYTE),
  PRIMARY KEY (id_message,id_ss,id_source_sess)
)
ON COMMIT DELETE ROWS;

CREATE TABLE mvm_scheduled_tasks (
  mvm_logical_cluster VARCHAR2(100 BYTE) NOT NULL,
  mvm_scheduled_dt DATE DEFAULT sysdate NOT NULL,
  mvm_status VARCHAR2(9 BYTE) DEFAULT 'scheduled' NOT NULL,
  mvm_status_dt DATE DEFAULT sysdate NOT NULL,
  is_scheduled VARCHAR2(10 BYTE),
  mvm_proc VARCHAR2(100 BYTE) NOT NULL,
  mvm_task_guid VARCHAR2(100 BYTE) DEFAULT sys_guid() NOT NULL,
  mvm_poll_guid VARCHAR2(100 BYTE) DEFAULT '0',
  mvm_scheduler_physical_node_id VARCHAR2(100 BYTE),
  mvm_delta_object VARCHAR2(4000 BYTE),
  workproc VARCHAR2(1000 BYTE),
  id_acc NUMBER,
  target_id_acc NUMBER,
  decision_unique_id VARCHAR2(1000 BYTE),
  target_decision_unique_id VARCHAR2(1000 BYTE),
  id_usage_interval NUMBER,
  rollover_dt DATE,
  precalculated_units NUMBER,
  mvm_error_msg VARCHAR2(256 BYTE),
  CONSTRAINT pk_mvm_scheduled_tasks PRIMARY KEY (mvm_task_guid)
);

CREATE TABLE t_rec_win_bcp_for_reverse (
  c_billedthroughdate DATE,
  c__priceableiteminstanceid NUMBER(10),
  c__priceableitemtemplateid NUMBER(10),
  c__productofferingid NUMBER(10),
  c__subscriptionid NUMBER(10) NOT NULL
);

COMMENT ON TABLE t_rec_win_bcp_for_reverse IS 'Table for storing c_BilledThroughDate values, that t_recur_window had before reverse';

COMMENT ON COLUMN t_rec_win_bcp_for_reverse.c_billedthroughdate IS 'The last time the RC adapter was run (not currently used)';

COMMENT ON COLUMN t_rec_win_bcp_for_reverse.c__priceableiteminstanceid IS 'Priceable item instance for this subscription';

COMMENT ON COLUMN t_rec_win_bcp_for_reverse.c__priceableitemtemplateid IS 'Priceable item template for this subscription';

COMMENT ON COLUMN t_rec_win_bcp_for_reverse.c__productofferingid IS 'Product offering for this subscription';

COMMENT ON COLUMN t_rec_win_bcp_for_reverse.c__subscriptionid IS 'Subscription ID';

ALTER TABLE t_active_tickets ADD (id_lang_code NUMBER(10) DEFAULT 840);

ALTER INDEX pk_t_active_tickets RENAME TO sys_c00590294;

ALTER TABLE t_active_tickets RENAME CONSTRAINT pk_t_active_tickets TO sys_c00590294;

CREATE GLOBAL TEMPORARY TABLE tt_tmpreconcilemessagetable_2 (
  id_message NUMBER(10) NOT NULL,
  dt_completed DATE,
  dt_assigned DATE,
  b_root CHAR,
  id_ss NUMBER(10) NOT NULL,
  id_svc NUMBER(10),
  id_partition NUMBER(10),
  id_source_sess RAW(16) NOT NULL,
  dt_metered DATE,
  tx_ip_address VARCHAR2(15 BYTE),
  b_resubmit CHAR,
  PRIMARY KEY (id_message,id_ss,id_source_sess)
)
ON COMMIT DELETE ROWS;

CREATE GLOBAL TEMPORARY TABLE all_rcs (
  x CLOB
)
ON COMMIT DELETE ROWS;

CREATE TABLE subscriptionunits (
  instanceid NVARCHAR2(64),
  subscriptionid NUMBER(*,0) NOT NULL,
  startdate DATE NOT NULL,
  enddate DATE NOT NULL,
  udrcid NUMBER(*,0) NOT NULL,
  udrcname NVARCHAR2(255) NOT NULL,
  unitname NVARCHAR2(255) NOT NULL,
  units NUMBER(22,10) NOT NULL
);

COMMENT ON TABLE subscriptionunits IS 'The SubscriptionUnits table tracks the initial units any changes to the bundled (i.e., included) number of units during the term of subscription';

COMMENT ON COLUMN subscriptionunits.instanceid IS 'Indicates what MetraNet instance generated the data';

COMMENT ON COLUMN subscriptionunits.subscriptionid IS 'Uniquely identifies the subscription.';

COMMENT ON COLUMN subscriptionunits.startdate IS 'Subscription Start date';

COMMENT ON COLUMN subscriptionunits.enddate IS 'Subscription End date';

COMMENT ON COLUMN subscriptionunits.udrcid IS 'Uniquely identifies the UDRC';

COMMENT ON COLUMN subscriptionunits.udrcname IS 'UDRC name';

COMMENT ON COLUMN subscriptionunits.unitname IS 'Unit name of UDRC';

COMMENT ON COLUMN subscriptionunits.units IS 'Unit of measure';

ALTER TABLE t_pricelist ADD (c_plpartitionid NUMBER(*,0) DEFAULT 1 NOT NULL);

COMMENT ON COLUMN t_pricelist.c_plpartitionid IS 'Partition identifier of the pricelist';

DROP TABLE tmp_acc_ownership_batch;

CREATE GLOBAL TEMPORARY TABLE tmp_acc_ownership_batch (
  id_owner NUMBER(10) NOT NULL,
  id_owned NUMBER(10) NOT NULL,
  id_relation_type NUMBER(10) NOT NULL,
  n_percent NUMBER(10) NOT NULL,
  vt_start DATE,
  vt_end DATE,
  tt_start TIMESTAMP NOT NULL,
  id_audit NUMBER(10) NOT NULL,
  id_event NUMBER(10) NOT NULL,
  id_userid NUMBER(10) NOT NULL,
  id_entitytype NUMBER(10) NOT NULL,
  status NUMBER(10)
)
ON COMMIT DELETE ROWS;

CREATE UNIQUE INDEX idx_id_acc_ownership ON tmp_acc_ownership_batch(id_owner,id_owned);

CREATE GLOBAL TEMPORARY TABLE tt_messageidtable (
  id_message NUMBER(10) NOT NULL,
  new_id_message NUMBER(10),
  PRIMARY KEY (id_message)
)
ON COMMIT DELETE ROWS;

CREATE GLOBAL TEMPORARY TABLE tmp_changed_units (
  id_prop NUMBER(10),
  id_sub NUMBER(10),
  n_value NUMBER(22,10),
  vt_start DATE,
  vt_end DATE NOT NULL,
  tt_start DATE NOT NULL,
  tt_end DATE NOT NULL
)
ON COMMIT PRESERVE ROWS;

CREATE TABLE subscriptionsummary (
  instanceid NVARCHAR2(64),
  productofferingid NUMBER(*,0) NOT NULL,
  "YEAR" NUMBER(*,0) NOT NULL,
  "MONTH" NUMBER(*,0) NOT NULL,
  totalparticipants NUMBER(*,0) NOT NULL,
  distincthierarchies NUMBER(*,0) NOT NULL,
  newparticipants NUMBER(*,0) NOT NULL,
  mrrprimarycurrency NUMBER(22,10) NOT NULL,
  mrrnewprimarycurrency NUMBER(22,10) NOT NULL,
  mrrbaseprimarycurrency NUMBER(22,10) NOT NULL,
  mrrrenewalprimarycurrency NUMBER(22,10) NOT NULL,
  mrrpricechangeprimarycurrency NUMBER(22,10) NOT NULL,
  mrrchurnprimarycurrency NUMBER(22,10) NOT NULL,
  mrrcancelationprimarycurrency NUMBER(22,10) NOT NULL,
  subscriptionrevprimarycurrency NUMBER(22,10) NOT NULL,
  daysinmonth NUMBER(*,0) NOT NULL
);

COMMENT ON TABLE subscriptionsummary IS 'This SubscriptionSummary aggregates the SubscriptionsByMonth Table by POCode. Note that MRR and all fields thereafter are a simple sum.';

COMMENT ON COLUMN subscriptionsummary.instanceid IS 'The MetraNet instance from which the data originated.';

COMMENT ON COLUMN subscriptionsummary.productofferingid IS 'Product Offering Identifier.  Can join to ProductOffering DataMart table to get display name and details.';

COMMENT ON COLUMN subscriptionsummary."YEAR" IS 'The calendar year in which the fee was or will be incurred.';

COMMENT ON COLUMN subscriptionsummary."MONTH" IS 'The calendar month in which the fee was or will be incurred (1-12)';

COMMENT ON COLUMN subscriptionsummary.totalparticipants IS 'The number of subscriptions.';

COMMENT ON COLUMN subscriptionsummary.distincthierarchies IS 'The number of unique customers. For example, a company may have 200 users with the subscription, that would be ONE here and 200 in Subscriptions above.';

COMMENT ON COLUMN subscriptionsummary.newparticipants IS 'The number of new customers in the month who have the subscription in the month (i.e., it likely attracted them).';

COMMENT ON COLUMN subscriptionsummary.mrrprimarycurrency IS 'The Monthly Recurring Revenue (MRR) in the primary currency. This is the sum of MRRBase, MRRRenewal, MRRPriceChange, MRRChurn, MRRNew and MRRCancellation.';

COMMENT ON COLUMN subscriptionsummary.mrrnewprimarycurrency IS 'MRRNew converted to the Primary Currency.';

COMMENT ON COLUMN subscriptionsummary.mrrbaseprimarycurrency IS 'The base MRR, in the primary currency (i.e., what we are expecting from the prior month). In the first month this will be zero and in the last month it will have a value. No report option.';

COMMENT ON COLUMN subscriptionsummary.mrrrenewalprimarycurrency IS 'The MRR increase due to a renewal, in the primary currency. This will only have a non-zero value in the month the renewal occurred. Defaults to zero. Report option "MRR Renewals"';

COMMENT ON COLUMN subscriptionsummary.mrrpricechangeprimarycurrency IS 'The change in MRR due to a price increase or decrease, in the primary currency. This may be positive or negative. Defaults to zero. Report option "MRR Price Changes"';

COMMENT ON COLUMN subscriptionsummary.mrrchurnprimarycurrency IS 'The MRR loss due to churn, in the primary currency. Must be zero or negative MRRBase. At the moment we can''t distinguish between Churn and early termination as we don''t have the contract terms. "MRR Churn"';

COMMENT ON COLUMN subscriptionsummary.mrrcancelationprimarycurrency IS 'The MRR loss due to a cancelation, in the primary currency. Must be zero or negative MRRBase. Report option "MRR Cancelations". ';

COMMENT ON COLUMN subscriptionsummary.subscriptionrevprimarycurrency IS 'The monetary amount of revenue for the month, in the primary currency.';

COMMENT ON COLUMN subscriptionsummary.daysinmonth IS 'The number of days in the month.';

CREATE GLOBAL TEMPORARY TABLE my_unrooted (
  x CLOB
)
ON COMMIT DELETE ROWS;

DROP TABLE tmp_udrc CASCADE CONSTRAINTS;

CREATE GLOBAL TEMPORARY TABLE TMP_UDRC (
  C_RCINTERVALSTART DATE, 
	C_RCINTERVALEND DATE, 
	C_BILLINGINTERVALSTART DATE, 
	C_BILLINGINTERVALEND DATE, 
	C_RCINTERVALSUBSCRIPTIONSTART DATE, 
	C_RCINTERVALSUBSCRIPTIONEND DATE, 
	C_SUBSCRIPTIONSTART DATE, 
	C_SUBSCRIPTIONEND DATE, 
	C_ADVANCE CHAR(1 BYTE), 
	C_PRORATEONSUBSCRIPTION CHAR(1 BYTE), 
	C_UNITVALUESTART DATE, 
	C_UNITVALUEEND DATE, 
	C_UNITVALUEADVANCECORRECTION NUMBER(22,10), 
	C_UNITVALUEDEBITCORRECTION NUMBER(22,10), 
	C_RATINGTYPE NUMBER(10,0), 
	C_PRORATEONUNSUBSCRIPTION CHAR(1 BYTE), 
	C_PRORATIONCYCLELENGTH NUMBER(10,0), 
	C__ACCOUNTID NUMBER(10,0), 
	C__PAYINGACCOUNT NUMBER(10,0), 
	C__PRICEABLEITEMINSTANCEID NUMBER(10,0), 
	C__PRICEABLEITEMTEMPLATEID NUMBER(10,0), 
	C__PRODUCTOFFERINGID NUMBER(10,0), 
	C_BILLEDRATEDATE DATE, 
	C__SUBSCRIPTIONID NUMBER(10,0), 
	C__INTERVALID NUMBER(10,0)
) ON COMMIT PRESERVE ROWS ;

CREATE GLOBAL TEMPORARY TABLE all_rcs_linked (
  x CLOB
)
ON COMMIT DELETE ROWS;

CREATE TABLE currencyexchangemonthly (
  instanceid NVARCHAR2(64),
  startdate DATE NOT NULL,
  enddate DATE NOT NULL,
  sourcecurrency NVARCHAR2(100) NOT NULL,
  targetcurrency NVARCHAR2(100) NOT NULL,
  exchangerate NUMBER(22,10) NOT NULL
);

COMMENT ON TABLE currencyexchangemonthly IS 'The CurrencyExchangeMonthly table contains the monthly currency exchange rate';

COMMENT ON COLUMN currencyexchangemonthly.instanceid IS 'The MetraNet instance from which the data originated';

COMMENT ON COLUMN currencyexchangemonthly.startdate IS 'Start date for this exchange rate';

COMMENT ON COLUMN currencyexchangemonthly.enddate IS 'End date for this exchange rate';

COMMENT ON COLUMN currencyexchangemonthly.sourcecurrency IS 'The currency to convert from (string name from t_enum_data)';

COMMENT ON COLUMN currencyexchangemonthly.targetcurrency IS 'The currency to convert to (string name from t_enum_data)';

COMMENT ON COLUMN currencyexchangemonthly.exchangerate IS 'The exchange rate between SourceCurrency and TargetCurrency';

CREATE GLOBAL TEMPORARY TABLE tmp_corps (
  x CLOB
)
ON COMMIT DELETE ROWS;

CREATE GLOBAL TEMPORARY TABLE tmp_accs (
  x CLOB
)
ON COMMIT DELETE ROWS;

CREATE TABLE productoffering (
  instanceid NVARCHAR2(64),
  productofferingid NUMBER(*,0) NOT NULL,
  productofferingname NVARCHAR2(255),
  isusersubscribable CHAR NOT NULL,
  isuserunsubscribable CHAR NOT NULL,
  ishidden CHAR NOT NULL,
  effectivestartdate DATE NOT NULL,
  effectiveenddate DATE NOT NULL,
  availablestartdate DATE NOT NULL,
  availableenddate DATE NOT NULL
);

COMMENT ON TABLE productoffering IS 'This ProductOffering table stores descriptions for product offerings.';

COMMENT ON COLUMN productoffering.instanceid IS 'The MetraNet instance from which the data originated.';

COMMENT ON COLUMN productoffering.productofferingid IS 'Product Offering Identifier.';

COMMENT ON COLUMN productoffering.productofferingname IS 'Name of the product offering (should be unique by InstanceId).';

COMMENT ON COLUMN productoffering.isusersubscribable IS 'Whether the user can self-subscribe to this offering.';

COMMENT ON COLUMN productoffering.isuserunsubscribable IS 'Whether the user can self-unsubscribe to this offering.';

COMMENT ON COLUMN productoffering.ishidden IS 'Whether this product offering is hidden from the list of available offerings.';

COMMENT ON COLUMN productoffering.effectivestartdate IS 'Earliest date when a subscription to this product offering is allowed to begin.';

COMMENT ON COLUMN productoffering.effectiveenddate IS 'Latest date when a subscription to this product offering is allowed to end.';

COMMENT ON COLUMN productoffering.availablestartdate IS 'When this product offering becomes available for subscriptions.';

COMMENT ON COLUMN productoffering.availableenddate IS 'When this product offering stops being available for subscriptions.';

ALTER TABLE t_char_values_history MODIFY (nm_value NVARCHAR2(255));

ALTER TABLE t_be_cor_bil_billmessage_h ADD (c_language NUMBER(10));

ALTER TABLE t_be_cor_bil_billmessage ADD (c_language NUMBER(10));

COMMENT ON COLUMN t_be_cor_bil_billmessage.c_language IS 'Language of Bill Messages';

CREATE TABLE customer (
  instanceid NVARCHAR2(64) NOT NULL,
  metranetid NUMBER(*,0) NOT NULL,
  accounttype NVARCHAR2(200) NOT NULL,
  externalid NVARCHAR2(255) NOT NULL,
  externalidspace NVARCHAR2(40),
  firstname NVARCHAR2(40),
  middlename NVARCHAR2(40),
  lastname NVARCHAR2(1),
  company NVARCHAR2(255),
  currency NVARCHAR2(10),
  city NVARCHAR2(40),
  state NVARCHAR2(40),
  zipcode NVARCHAR2(40),
  email NVARCHAR2(100),
  country NVARCHAR2(100),
  phone NVARCHAR2(40),
  hierarchymetranetid NUMBER(*,0) NOT NULL,
  hierarchyaccounttype NVARCHAR2(200),
  hierarchyexternalid NVARCHAR2(255) NOT NULL,
  hierarchyexternalidspace NVARCHAR2(40),
  hierarchyfirstname NVARCHAR2(40),
  hierarchymiddlename NVARCHAR2(1),
  hierarchylastname NVARCHAR2(40),
  hierarchycompany NVARCHAR2(255),
  hierarchycurrency NVARCHAR2(10),
  hierarchycity NVARCHAR2(40),
  hierarchystate NVARCHAR2(40),
  hierarchyzipcode NVARCHAR2(40),
  hierarchycountry NVARCHAR2(100),
  hierarchyemail NVARCHAR2(100),
  hierarchyphone NVARCHAR2(40),
  CONSTRAINT pk_customer PRIMARY KEY (instanceid,metranetid)
);

COMMENT ON TABLE customer IS 'Contains summary customer information';

COMMENT ON COLUMN customer.instanceid IS 'The MetraNet instance from which the data originated';

COMMENT ON COLUMN customer.metranetid IS 'The internal MetraNet account identifier';

COMMENT ON COLUMN customer.accounttype IS 'The account type';

COMMENT ON COLUMN customer.externalid IS 'The external account identifier (from t_account_mapper)';

COMMENT ON COLUMN customer.externalidspace IS 'The namespace for the ExternalId.';

COMMENT ON COLUMN customer.firstname IS 'The first name of the billing contact';

COMMENT ON COLUMN customer.middlename IS 'The middle initial of the billing contact.';

COMMENT ON COLUMN customer.lastname IS 'The last name of the billing contact';

COMMENT ON COLUMN customer.company IS 'The company name for the billing contact';

COMMENT ON COLUMN customer.currency IS 'The currency name for the billing contact';

COMMENT ON COLUMN customer.city IS 'The city the customer is located in for the billing contact';

COMMENT ON COLUMN customer.state IS 'The state the customer is located in for the billing contact';

COMMENT ON COLUMN customer.zipcode IS 'The zip code that the customer is located in for the billing contact';

COMMENT ON COLUMN customer.email IS 'The email address for the billing contact';

COMMENT ON COLUMN customer.country IS 'The country that the customer is located in for the billing contact';

COMMENT ON COLUMN customer.phone IS 'The phone number for the billing contact';

COMMENT ON COLUMN customer.hierarchymetranetid IS 'The internal MetraNet account identifier for the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchyaccounttype IS 'The account type of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchyexternalid IS 'The external account identifier (from t_account_mapper) of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchyexternalidspace IS 'The namespace for the ExternalId of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchyfirstname IS 'The first name of the billing contact of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchymiddlename IS 'The middle initial of the billing contact of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchylastname IS 'The last name of the billing contact of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchycompany IS 'The company name for the billing contact of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchycurrency IS 'The currency the customer is located in for the billing contact of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchycity IS 'The city the customer is located in for the billing contact of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchystate IS 'The state the customer is located in for the billing contact of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchyzipcode IS 'The zip code that the customer is located in for the billing contact of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchycountry IS 'The country that the customer is located in for the billing contact of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchyemail IS 'The email address for the billing contact of the top-level hierarchy account';

COMMENT ON COLUMN customer.hierarchyphone IS 'The phone number for the billing contact of the top-level hierarchy account';

CREATE GLOBAL TEMPORARY TABLE tt_sessionsetmap (
  id_ss NUMBER(10) NOT NULL,
  new_id_ss NUMBER(10),
  sess_cnt NUMBER(10),
  PRIMARY KEY (id_ss)
)
ON COMMIT DELETE ROWS;

ALTER TABLE t_po ADD (c_popartitionid NUMBER(*,0) DEFAULT 1 NOT NULL);

COMMENT ON COLUMN t_po.c_popartitionid IS 'Partition identifier of this product offering';

ALTER TABLE t_char_values MODIFY (nm_value NVARCHAR2(255));

CREATE TABLE rg_temp_1453148871_30 (
  id_owner NUMBER(10) NOT NULL,
  id_owned NUMBER(10) NOT NULL,
  id_relation_type NUMBER(10) NOT NULL,
  n_percent NUMBER(10) NOT NULL CONSTRAINT RG_TEMP_1453148871_31 CHECK (n_percent <= 100 AND n_percent >= 0),
  vt_start DATE NOT NULL,
  vt_end DATE NOT NULL,
  tt_start TIMESTAMP NOT NULL,
  tt_end TIMESTAMP NOT NULL,
  CONSTRAINT RG_TEMP_1453148871_32 CHECK (id_owner <> id_owned),
  CONSTRAINT RG_TEMP_1453148871_33 CHECK (vt_start <= vt_end),
  CONSTRAINT RG_TEMP_1453148871_34 CHECK (tt_start <= tt_end),
  CONSTRAINT RG_TEMP_1453148871_35 PRIMARY KEY (id_owner,id_owned,id_relation_type,n_percent,vt_start,vt_end,tt_start,tt_end) USING INDEX (CREATE UNIQUE INDEX rg_temp_1453148871_36 ON rg_temp_1453148871_30(id_owner,id_owned,id_relation_type,n_percent,vt_start,vt_end,tt_start,tt_end)    ),
  CONSTRAINT RG_TEMP_1453148871_37 FOREIGN KEY (id_owner) REFERENCES t_account (id_acc),
  CONSTRAINT RG_TEMP_1453148871_38 FOREIGN KEY (id_owned) REFERENCES t_account (id_acc),
  CONSTRAINT RG_TEMP_1453148871_39 FOREIGN KEY (id_relation_type) REFERENCES t_enum_data (id_enum_data)
);

INSERT INTO rg_temp_1453148871_30(id_owner,id_owned,id_relation_type,n_percent,vt_start,vt_end,tt_start,tt_end) SELECT id_owner,id_owned,id_relation_type,n_percent,vt_start,vt_end,NULL,NULL FROM t_acc_ownership;

DROP TABLE t_acc_ownership;

ALTER TABLE rg_temp_1453148871_30 RENAME TO t_acc_ownership;

ALTER TABLE t_acc_ownership RENAME CONSTRAINT RG_TEMP_1453148871_31 TO t_acc_ownership_check2;

ALTER TABLE t_acc_ownership RENAME CONSTRAINT RG_TEMP_1453148871_32 TO t_acc_ownership_check1;

ALTER TABLE t_acc_ownership RENAME CONSTRAINT RG_TEMP_1453148871_33 TO t_acc_ownership_check3;

ALTER TABLE t_acc_ownership RENAME CONSTRAINT RG_TEMP_1453148871_34 TO t_acc_ownership_check4;

ALTER TABLE t_acc_ownership RENAME CONSTRAINT RG_TEMP_1453148871_35 TO t_acc_ownership_pk;

ALTER INDEX rg_temp_1453148871_36 RENAME TO T_ACC_OWNERSHIP_PK;

ALTER TABLE t_acc_ownership RENAME CONSTRAINT RG_TEMP_1453148871_37 TO t_acc_ownership_fk1;

ALTER TABLE t_acc_ownership RENAME CONSTRAINT RG_TEMP_1453148871_38 TO t_acc_ownership_fk2;

ALTER TABLE t_acc_ownership RENAME CONSTRAINT RG_TEMP_1453148871_39 TO t_acc_ownership_fk3;

COMMENT ON TABLE t_acc_ownership IS 'This table contains information about account ownership relatioship that is used in MetraCare. (Package:Pipeline)';

COMMENT ON COLUMN t_acc_ownership.id_owner IS 'Accountid of the Owner';

COMMENT ON COLUMN t_acc_ownership.id_owned IS 'Accountid of the owned account';

COMMENT ON COLUMN t_acc_ownership.id_relation_type IS 'MetraNet generated surrogate key. This is foreign key to t_mt_id table.';

COMMENT ON COLUMN t_acc_ownership.n_percent IS 'Relative percent value of ownership';

COMMENT ON COLUMN t_acc_ownership.vt_start IS 'Valid start Timestamp';

COMMENT ON COLUMN t_acc_ownership.vt_end IS 'Valid EndTimestamp';

COMMENT ON COLUMN t_acc_ownership.tt_start IS 'Transaction start Timestamp';

COMMENT ON COLUMN t_acc_ownership.tt_end IS 'Transaction end Timestamp';

CREATE TABLE t_pt_translationrates (
  id_sched NUMBER(10) NOT NULL,
  n_order NUMBER(10) NOT NULL,
  tt_start DATE NOT NULL,
  tt_end DATE NOT NULL,
  id_audit NUMBER(10) NOT NULL,
  c_language_op NVARCHAR2(5) NOT NULL,
  c_language NUMBER(10) NOT NULL,
  c_rate NUMBER(22,10) NOT NULL,
  CONSTRAINT pk_t_pt_translationrates PRIMARY KEY (id_sched,n_order,id_audit)
);

COMMENT ON TABLE t_pt_translationrates IS 'Rating rules used for translation; set the rate based on the language translated';

COMMENT ON COLUMN t_pt_translationrates.c_language IS 'From the service definition; this is the language that the conference was translated to';

COMMENT ON COLUMN t_pt_translationrates.c_rate IS 'The per-minute rate applied to a translation event';

CREATE GLOBAL TEMPORARY TABLE tt_servicemap (
  id_svc NUMBER(10) NOT NULL,
  table_name VARCHAR2(255 BYTE) NOT NULL,
  PRIMARY KEY (id_svc)
)
ON COMMIT DELETE ROWS;

CREATE TABLE t_acc_usage_quoting (
  quote_id NUMBER(20) NOT NULL,
  id_sess NUMBER(20) NOT NULL,
  tx_uid RAW(16) NOT NULL,
  id_acc NUMBER(10) NOT NULL,
  id_payee NUMBER(10) NOT NULL,
  id_view NUMBER(10) NOT NULL,
  id_usage_interval NUMBER(10) NOT NULL,
  id_parent_sess NUMBER(20),
  id_prod NUMBER(10),
  id_svc NUMBER(10) NOT NULL,
  dt_session DATE NOT NULL,
  amount NUMBER(22,10) NOT NULL,
  am_currency NVARCHAR2(3) NOT NULL,
  dt_crt DATE NOT NULL,
  tx_batch RAW(16),
  tax_federal NUMBER(22,10),
  tax_state NUMBER(22,10),
  tax_county NUMBER(22,10),
  tax_local NUMBER(22,10),
  tax_other NUMBER(22,10),
  id_pi_instance NUMBER(10),
  id_pi_template NUMBER(10),
  id_se NUMBER(10) NOT NULL,
  div_currency NVARCHAR2(3),
  div_amount NUMBER(22,10),
  is_implied_tax CHAR NOT NULL,
  tax_calculated CHAR,
  tax_informational CHAR NOT NULL,
  CONSTRAINT pk_t_acc_usage_quoting PRIMARY KEY (quote_id,id_sess,id_usage_interval)
);

COMMENT ON TABLE t_acc_usage_quoting IS 'Stores information about the rated usage data which is common to all product views';

COMMENT ON COLUMN t_acc_usage_quoting.quote_id IS 'Quote unique identifier';

COMMENT ON COLUMN t_acc_usage_quoting.id_sess IS 'MetraNet generated surrogate key for session';

COMMENT ON COLUMN t_acc_usage_quoting.tx_uid IS 'The unique external session identifier';

COMMENT ON COLUMN t_acc_usage_quoting.id_acc IS 'The payer identifier';

COMMENT ON COLUMN t_acc_usage_quoting.id_payee IS 'The account identifier';

COMMENT ON COLUMN t_acc_usage_quoting.id_view IS 'The product view identifier';

COMMENT ON COLUMN t_acc_usage_quoting.id_usage_interval IS 'The billing period identifier';

COMMENT ON COLUMN t_acc_usage_quoting.id_parent_sess IS 'The parent session identifier';

COMMENT ON COLUMN t_acc_usage_quoting.id_prod IS 'The Product Offering identifier';

COMMENT ON COLUMN t_acc_usage_quoting.id_svc IS 'The service identifier';

COMMENT ON COLUMN t_acc_usage_quoting.dt_session IS 'The date and time the usage occurred';

COMMENT ON COLUMN t_acc_usage_quoting.amount IS 'The monetary amount calculated for the session';

COMMENT ON COLUMN t_acc_usage_quoting.am_currency IS 'The currency code of the monetary amounts calculated for the session';

COMMENT ON COLUMN t_acc_usage_quoting.dt_crt IS 'The date and time the session was added to the database';

COMMENT ON COLUMN t_acc_usage_quoting.tx_batch IS 'The batch session identifier';

COMMENT ON COLUMN t_acc_usage_quoting.tax_federal IS 'The monetary amount of federal tax calculated for the session';

COMMENT ON COLUMN t_acc_usage_quoting.tax_state IS 'The monetary amount of state tax calculated for the session';

COMMENT ON COLUMN t_acc_usage_quoting.tax_county IS 'The monetary amount of country tax calculated for the session';

COMMENT ON COLUMN t_acc_usage_quoting.tax_local IS 'The monetary amount of local tax calculated for the session';

COMMENT ON COLUMN t_acc_usage_quoting.tax_other IS 'The monetary amount of other tax calculated for the session';

COMMENT ON COLUMN t_acc_usage_quoting.id_pi_instance IS 'The database ID for the priceable item instance associated with the usage';

COMMENT ON COLUMN t_acc_usage_quoting.id_pi_template IS 'The database ID for the priceable item template associated with the usage';

COMMENT ON COLUMN t_acc_usage_quoting.id_se IS 'The database identifier for associated service endpoint';

COMMENT ON COLUMN t_acc_usage_quoting.div_currency IS 'Division currency ';

COMMENT ON COLUMN t_acc_usage_quoting.div_amount IS 'Division amount';

COMMENT ON COLUMN t_acc_usage_quoting.is_implied_tax IS 'If set to "Y" tax is assumed to be already part of the given amount.  More information here implied tax';

COMMENT ON COLUMN t_acc_usage_quoting.tax_calculated IS 'Has the tax already been calculated';

COMMENT ON COLUMN t_acc_usage_quoting.tax_informational IS 'Is this tax informational-only';

CREATE GLOBAL TEMPORARY TABLE sum_rcs_by_month (
  x CLOB
)
ON COMMIT DELETE ROWS;

CREATE TABLE salesrep (
  instanceid VARCHAR2(64 BYTE),
  metranetid NUMBER(*,0) NOT NULL,
  externalid NVARCHAR2(255) NOT NULL,
  customerid NUMBER(*,0) NOT NULL,
  percentage NUMBER(*,0) NOT NULL,
  relationshiptype NVARCHAR2(100)
);

COMMENT ON TABLE salesrep IS 'Contains the sales representatives and their territories';

COMMENT ON COLUMN salesrep.instanceid IS 'The MetraNet instance from which the data originated';

COMMENT ON COLUMN salesrep.metranetid IS 'The MetraNet account ID of the sales person';

COMMENT ON COLUMN salesrep.externalid IS 'An identifier for an external system';

COMMENT ON COLUMN salesrep.customerid IS 'The MetraNet account ID of the account being represented';

COMMENT ON COLUMN salesrep.percentage IS 'For relationships that are shared, this represents the corresponding ownership percentage.  Usually used for commissions, etc.  (100-based)';

COMMENT ON COLUMN salesrep.relationshiptype IS 'The type of the relationship (string value from t_enum_data, using metratech.com/SaleForceRelationship namespace).';

CREATE TABLE subscriptionsbymonth (
  instanceid VARCHAR2(64 BYTE),
  subscriptionid NUMBER(*,0) NOT NULL,
  "YEAR" NUMBER(*,0) NOT NULL,
  "MONTH" NUMBER(*,0) NOT NULL,
  currency NVARCHAR2(3) NOT NULL,
  mrr NUMBER(22,10) NOT NULL,
  mrrprimarycurrency NUMBER(22,10) NOT NULL,
  mrrnew NUMBER(22,10) NOT NULL,
  mrrnewprimarycurrency NUMBER(22,10) NOT NULL,
  mrrbase NUMBER(22,10) NOT NULL,
  mrrbaseprimarycurrency NUMBER(22,10) NOT NULL,
  mrrrenewal NUMBER(*,0) NOT NULL,
  mrrrenewalprimarycurrency NUMBER(22,10) NOT NULL,
  mrrpricechange NUMBER(22,10) NOT NULL,
  mrrpricechangeprimarycurrency NUMBER(22,10) NOT NULL,
  mrrchurn NUMBER(*,0) NOT NULL,
  mrrchurnprimarycurrency NUMBER(22,10) NOT NULL,
  mrrcancelation NUMBER(*,0) NOT NULL,
  mrrcancelationprimarycurrency NUMBER(22,10) NOT NULL,
  subscriptionrevenue NUMBER(*,0) NOT NULL,
  subscriptionrevprimarycurrency NUMBER(22,10) NOT NULL,
  daysinmonth NUMBER(*,0) NOT NULL,
  daysactiveinmonth NUMBER(*,0) NOT NULL
);

COMMENT ON TABLE subscriptionsbymonth IS 'This SubscriptionByMonth table apportions the entire term of a subscription into calendar-month buckets. In other words, each row contains monthly data for the past, present and future for every subscription with a recurring charge. Given that MRR and other calculations are somewhat complex and exception-based, the impact to MRR is stored in separate fields to facilitate reporting.';

COMMENT ON COLUMN subscriptionsbymonth.instanceid IS 'The MetraNet instance from which the data originated';

COMMENT ON COLUMN subscriptionsbymonth.subscriptionid IS 'Uniquely identifies the subscription';

COMMENT ON COLUMN subscriptionsbymonth."YEAR" IS 'The calendar year in which the fee was or will be incurred';

COMMENT ON COLUMN subscriptionsbymonth."MONTH" IS 'The calendar month in which the fee was or will be incurred.';

COMMENT ON COLUMN subscriptionsbymonth.currency IS 'The currency the subscription fees are in';

COMMENT ON COLUMN subscriptionsbymonth.mrr IS 'The Monthly Recurring Revenue (MRR). This is the sum of MRRBase, MRRRenewal, MRRPriceChange, MRRChurn, MRRNew and MRRCancellation';

COMMENT ON COLUMN subscriptionsbymonth.mrrprimarycurrency IS 'MRR converted to the Primary Currency';

COMMENT ON COLUMN subscriptionsbymonth.mrrnew IS 'MRR increase due to new sales. This is only non-zero if  in the month that the subscription was created. Report "MRR from new sales"';

COMMENT ON COLUMN subscriptionsbymonth.mrrnewprimarycurrency IS 'MRRNew converted to the Primary Currency';

COMMENT ON COLUMN subscriptionsbymonth.mrrbase IS 'The base MRR (i.e., what we are expecting from the prior month). In the first month this will be zero and in the last month it will have a value. No report option';

COMMENT ON COLUMN subscriptionsbymonth.mrrbaseprimarycurrency IS 'MRRBase converted to the Primary Currency';

COMMENT ON COLUMN subscriptionsbymonth.mrrrenewal IS 'The MRR increase due to a renewal. This will only have a non-zero value in the month the renewal occurred. Defaults to zero. Report option "MRR Renewals"';

COMMENT ON COLUMN subscriptionsbymonth.mrrrenewalprimarycurrency IS 'MRRRenewal converted to the Primary Currency';

COMMENT ON COLUMN subscriptionsbymonth.mrrpricechange IS 'The change in MRR due to a price increase or decrease. This may be positive or negative. Defaults to zero. Report option "MRR Price Changes"';

COMMENT ON COLUMN subscriptionsbymonth.mrrpricechangeprimarycurrency IS 'MRRPriceChange converted to the Primary Currency';

COMMENT ON COLUMN subscriptionsbymonth.mrrchurn IS 'The MRR loss due to churn. Must be zero or negative MRRBase. At the moment we can''t distinguish between Churn and early termination as we don''t have the contract terms. "MRR Churn"';

COMMENT ON COLUMN subscriptionsbymonth.mrrchurnprimarycurrency IS 'MRRChurn converted to the Primary Currency';

COMMENT ON COLUMN subscriptionsbymonth.mrrcancelation IS 'The MRR loss due to a cancelation. Must be zero or negative MRRBase. Report option "MRR Cancelations"';

COMMENT ON COLUMN subscriptionsbymonth.mrrcancelationprimarycurrency IS 'MRRCancellation converted to the Primary Currency';

COMMENT ON COLUMN subscriptionsbymonth.subscriptionrevenue IS 'The monetary amount of revenue for the month';

COMMENT ON COLUMN subscriptionsbymonth.subscriptionrevprimarycurrency IS 'SubscriptionRevenue converted to the Primary Currency.';

COMMENT ON COLUMN subscriptionsbymonth.daysinmonth IS 'The number of days in the month';

COMMENT ON COLUMN subscriptionsbymonth.daysactiveinmonth IS 'The number of days in the month that the subscription is deemed active';

CREATE GLOBAL TEMPORARY TABLE all_rcs_by_month (
  x CLOB
)
ON COMMIT DELETE ROWS;

CREATE GLOBAL TEMPORARY TABLE tmp_fx (
  x CLOB
)
ON COMMIT DELETE ROWS;

CREATE GLOBAL TEMPORARY TABLE tmp_unrooted (
  x CLOB
)
ON COMMIT DELETE ROWS;

CREATE GLOBAL TEMPORARY TABLE tmp_all_customers (
  x CLOB
)
ON COMMIT DELETE ROWS;

DROP TABLE agg_charge_definition;

DROP TABLE t_be_cor_qu_quotecontent;

ALTER TYPE tab_id_instance COMPILE ;

ALTER TYPE retcompatibleevent COMPILE ;

ALTER TYPE retcompatibleevent_table COMPILE ;

ALTER TYPE retdescendents COMPILE ;

ALTER TYPE retdescendents_table COMPILE ;

ALTER TYPE str_tab COMPILE ;

ALTER TYPE billgroupdesc_results_rec COMPILE ;

ALTER TYPE billgroupdesc_results_tab COMPILE ;

ALTER TYPE id_rec COMPILE ;

ALTER TYPE id_table COMPILE ;

CREATE OR REPLACE PACKAGE dbo
AS

    function maxpartitionbound return NUMBER;

    function csvtoint (p_id_instances varchar2) return tab_id_instance;
    function String2Table(p_str in clob, p_delim in varchar2 default '.') return  str_tab;
    function csvtostrtab (csv varchar2) return str_tab;
    function strtabtocsv(tab str_tab) return varchar2;
    
    FUNCTION GetEventExecutionDeps(p_dt_now DATE, p_id_instances VARCHAR2)
    RETURN int;

    FUNCTION GetEventReversalDeps(p_dt_now DATE, p_id_instances VARCHAR2)
    RETURN int;

    FUNCTION GetCompatibleConcurrentEvents
    RETURN retCompatibleEvent_table;

   FUNCTION mtmaxdate
      RETURN DATE;

   FUNCTION mtmindate
      RETURN DATE;

   FUNCTION getutcdate
      RETURN DATE;

FUNCTION to_base( p_dec in number, p_base in number )
RETURN VARCHAR2;

FUNCTION twos_complement( in_bin_string varchar2)
RETURN VARCHAR2;

FUNCTION to_dec( p_str in varchar2, p_from_base in number default 16 )
RETURN NUMBER;

   FUNCTION addsecond (refdate DATE)
      RETURN DATE;

   FUNCTION subtractsecond (refdate DATE)
      RETURN DATE;

   FUNCTION addday (dt DATE)
      RETURN DATE;

   FUNCTION subtractday (dt DATE)
      RETURN DATE;

   function diffhour (dt_start date, dt_end date)
      return number;

   FUNCTION isaccountbillable (p_id_acc IN INTEGER)
      RETURN varchar2;

   FUNCTION IsAccountFolder (p_id_acc IN INTEGER)
      RETURN VARCHAR2;

   FUNCTION encloseddaterange (
      temp_dt_start        DATE,
      temp_dt_end          DATE,
      temp_dt_checkstart   DATE,
      temp_dt_checkend     DATE
   )
      RETURN INTEGER;

   FUNCTION overlappingdaterange (
      temp_dt_start        DATE,
      temp_dt_end          DATE,
      temp_dt_checkstart   DATE,
      temp_dt_checkend     DATE
   )
      RETURN INTEGER;

   FUNCTION mtcomputeeffectivebegindate (
      TYPE                  INT,
      offset                INT,
      base                  DATE,
      sub_begin             DATE,
      temp_id_usage_cycle   INT
   )
      RETURN DATE;

   FUNCTION mtrateschedulescore (TYPE INT, begindate DATE)
      RETURN INT;

   FUNCTION mtdateinrange (startdate DATE, enddate DATE, comparedate DATE)
      RETURN INTEGER;

   FUNCTION mtminoftwodates (chargeintervalleft DATE, subintervalleft DATE)
      RETURN DATE;

   FUNCTION mtmaxoftwodates (chargeintervalleft DATE, subintervalleft DATE)
      RETURN DATE;

   FUNCTION nextdateafterbillingcycle (temp_id_acc INT, temp_datecheck DATE)
      RETURN DATE;

   FUNCTION checksubscriptionconflicts (
      temp_id_acc            INT,
      temp_id_po             INT,
      temp_real_begin_date   DATE,
      temp_real_end_date     DATE,
      temp_id_sub            INT,
      p_allow_acc_po_curr_mismatch  INT,
      p_allow_multiple_pi_sub_rcnrc INT
   )
      RETURN INT;

		FUNCTION mtendofday (indate DATE) RETURN DATE;
		FUNCTION mtstartofday (indate DATE) return DATE;
		FUNCTION POContainsDiscount(p_id_po INTEGER) return INTEGER;
  
  FUNCTION IsCorporateAccount(p_id_acc IN integer,RefDate IN Date) return INTEGER;

	FUNCTION IsActive(state varchar2) return integer;
	FUNCTION IsSuspended(state varchar2) return integer;
	FUNCTION IsPendingFinalBill(state varchar2) return integer;
	FUNCTION IsClosed(state varchar2) return integer;
	FUNCTION IsArchived(state varchar2) return integer;
	FUNCTION IsInVisableState(state varchar2) return integer;
  FUNCTION mtconcat(str1 nvarchar2,str2 nvarchar2) return nvarchar2;

  FUNCTION poConstrainedCycleType(offeringID integer) return integer;
  function IsInSameCorporateAccount(acc1 IN integer,acc2 IN integer,refdate date) return integer;

  FUNCTION POContainsOnlyAbsoluteRates(p_id_po IN integer) return integer;

    FUNCTION CheckEBCRCycleTypeCompatible
      (p_EBCRCycleType INT, p_OtherCycleType INT)
    RETURN INT;

    FUNCTION CHECKGROUPMEMBERSHIPCYCLECONST(
    dt_now 	IN DATE  DEFAULT NULL,
    id_group 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION CheckGroupMembershipEBCRConstr
    (
      p_dt_now DATE, /* system date */
      p_id_group INT     /* group ID to check */
    )
    RETURN INT;

    FUNCTION CHECKGROUPRECEIVEREBCRCONS
    (
      p_dt_now DATE, /* system date */
      p_id_group INT     /* group ID to check */
    )
    RETURN INT;

    FUNCTION DERIVEEBCRCYCLE(
    usageCycle 	IN NUMBER  DEFAULT NULL,
    subStart 	IN DATE  DEFAULT NULL,
    ebcrCycleType 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION DOESACCOUNTHAVEPAYEES(
    id_acc 	IN NUMBER  DEFAULT NULL,
    dt_ref 	IN DATE  DEFAULT NULL)
    RETURN VARCHAR2;

    FUNCTION GETCURRENTINTERVALID(
	aDTNow 	IN DATE  DEFAULT NULL,
    aDTSession 	IN DATE  DEFAULT NULL,
    aAccountID 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION ISACCOUNTANDPOSAMECURRENCY(
    id_acc 	IN NUMBER  DEFAULT NULL,
    id_po 	IN NUMBER  DEFAULT NULL)
    RETURN VARCHAR2;

    FUNCTION ISACCOUNTPAYINGFOROTHERS(
    id_acc 	IN NUMBER  DEFAULT NULL,
    dt_ref 	IN DATE  DEFAULT NULL)
    RETURN VARCHAR2;

    FUNCTION IsBillingCycleUpdProhibitedByG
    (
      p_dt_now DATE,
      p_id_acc INT
    )
    RETURN INT;

    FUNCTION ISINTERVALOPEN(
    aAccountID 	IN NUMBER  DEFAULT NULL,
    aIntervalID 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION LOOKUPACCOUNT(
    login 	IN VARCHAR2  DEFAULT NULL,
    namespace 	IN VARCHAR2  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION MTCOMPUTEEFFECTIVEENDDATE(
    type_ 	IN NUMBER  DEFAULT NULL,
    offset 	IN NUMBER  DEFAULT NULL,
    base 	IN DATE  DEFAULT NULL,
    sub_begin 	IN DATE  DEFAULT NULL,
    id_usage_cycle 	IN NUMBER  DEFAULT NULL)
    RETURN DATE;

    FUNCTION WARNONEBCRMEMBERSTARTDATECHANG(
    id_sub 	IN NUMBER  DEFAULT NULL,
    id_acc 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION WARNONEBCRSTARTDATECHANGE(
    id_sub 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION POCONTAINSBILLINGCYCLERELATIVE(
    id_po 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    function mthexformat(
      value 	in number  default null)
    return varchar2;

    function getbillinggroupancestor(p_id_current_billgroup int)
    return int;

    function getbillinggroupdescendants(p_id_billgroup_current int)
    return billgroupdesc_results_tab;

    function getexpiredintervals(
      p_dt_now date,
      p_not_materialized int
      ) return id_table;

	  function GetAllDescendentAccountTypes(
		  parent varchar2
		  ) return retDescendents_table;

   function IsSystemPartitioned
      return int;

    function GetUsageIntervalID (
      p_dt_end timestamp,
      p_id_cycle int
      ) return int;
      
    function DaysFromPartitionEpoch(
      dt timestamp)
    return int;
	
	function GenGuid return raw;
end;
/

CREATE OR REPLACE TRIGGER TRG_UPDATE_REC_WIND_ON_REC_VAL
  FOR INSERT OR UPDATE ON T_RECUR_VALUE
    COMPOUND TRIGGER

  startDate DATE;
  v_id_sub INTEGER;

  AFTER EACH ROW IS
  BEGIN
    IF UPDATING THEN
      INSERT
      INTO TMP_CHANGED_UNITS VALUES
        (
          :OLD.id_prop,
          :OLD.id_sub,
          :OLD.n_value,
          :OLD.vt_start,
          :OLD.vt_end,
          :OLD.tt_start,
          :OLD.tt_end
        );
    END IF;

    IF INSERTING THEN
      INSERT
      INTO TMP_CHANGED_UNITS VALUES
        (
          :NEW.id_prop,
          :NEW.id_sub,
          :NEW.n_value,
          :NEW.vt_start,
          :NEW.vt_end,
          :NEW.tt_start,
          :NEW.tt_end
        );
      v_id_sub:= :NEW.id_sub;
    END IF;

  END AFTER EACH ROW;


  AFTER STATEMENT IS BEGIN

    IF sql%rowcount != 0 THEN
      /*TODO: look at MSSQL version... now it different */
      SELECT metratime(1,'RC') INTO startDate FROM dual;

      IF UPDATING THEN
        INSERT INTO TMP_NEWRW
        SELECT
          C_CYCLEEFFECTIVEDATE,
          C_CYCLEEFFECTIVESTART,
          C_CYCLEEFFECTIVEEND,
          C_SUBSCRIPTIONSTART,
          C_SUBSCRIPTIONEND,
          C_ADVANCE,
          C__ACCOUNTID,
          C__PAYINGACCOUNT,
          C__PRICEABLEITEMINSTANCEID,
          C__PRICEABLEITEMTEMPLATEID,
          C__PRODUCTOFFERINGID,
          C_PAYERSTART,
          C_PAYEREND,
          C__SUBSCRIPTIONID,
          C_UNITVALUESTART,
          C_UNITVALUEEND,
          C_UNITVALUE,
          C_BILLEDTHROUGHDATE,
          C_LASTIDRUN,
          C_MEMBERSHIPSTART,
          C_MEMBERSHIPEND,
          1 c__IsAllowGenChargeByTrigger
        FROM   t_recur_window
        WHERE  EXISTS
           (
             SELECT 1 FROM TMP_CHANGED_UNITS d
             WHERE  t_recur_window.c__SubscriptionID = d.id_sub
                AND t_recur_window.c__PriceableItemInstanceID = d.id_prop
                AND t_recur_window.c_UnitValueStart = d.vt_start
                AND t_recur_window.c_UnitValueEnd = d.vt_end
           );

        MERGE
        INTO    TMP_NEWRW rw
        USING   (
                  SELECT current_sub.* FROM t_sub_history new_sub
                    JOIN t_sub_history current_sub ON current_sub.id_acc = new_sub.id_acc
                      AND current_sub.id_sub = new_sub.id_sub
                      AND current_sub.tt_end = dbo.SubtractSecond(new_sub.tt_start)
                  WHERE new_sub.tt_end = dbo.MTMaxDate()
                ) cur_sub
        ON      ( rw.c__AccountID = cur_sub.id_acc AND rw.c__SubscriptionID = cur_sub.id_sub)
        WHEN MATCHED THEN
        UPDATE
        SET     rw.c_SubscriptionStart = cur_sub.vt_start, rw.c_SubscriptionEnd = cur_sub.vt_end;

        DELETE
        FROM   t_recur_window
        WHERE  EXISTS
               (
                   SELECT 1 FROM TMP_CHANGED_UNITS d
                   WHERE  t_recur_window.c__SubscriptionID = d.id_sub
                          AND t_recur_window.c__PriceableItemInstanceID = d.id_prop
                          AND t_recur_window.c_UnitValueStart = d.vt_start
                          AND t_recur_window.c_UnitValueEnd = d.vt_end
               );

        MeterUdrcFromRecurWindow(startDate, 'AdvanceCorrection');

      END IF;


      IF INSERTING THEN

        /*Get the old windows for recur values that have changed*/
        INSERT INTO TMP_NEWRW
        SELECT sub.vt_start c_CycleEffectiveDate ,
          sub.vt_start c_CycleEffectiveStart ,
          sub.vt_end c_CycleEffectiveEnd ,
          sub.vt_start c_SubscriptionStart ,
          sub.vt_end c_SubscriptionEnd ,
          rcr.b_advance c_Advance ,
          pay.id_payee c__AccountID ,
          pay.id_payer c__PayingAccount ,
          plm.id_pi_instance c__PriceableItemInstanceID ,
          plm.id_pi_template c__PriceableItemTemplateID ,
          plm.id_po c__ProductOfferingID ,
          pay.vt_start c_PayerStart ,
          pay.vt_end c_PayerEnd ,
          sub.id_sub c__SubscriptionID ,
          NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart ,
          NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd ,
          rv.n_value c_UnitValue ,
          dbo.mtmindate() c_BilledThroughDate ,
          -1 c_LastIdRun ,
          dbo.mtmindate() c_MembershipStart ,
          dbo.mtmaxdate() c_MembershipEnd,
          AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, startDate) c__IsAllowGenChargeByTrigger
          from t_sub sub
            INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
            INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
            INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
            INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
            JOIN TMP_CHANGED_UNITS rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate()
              AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
              AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
            WHERE
                sub.id_group IS NULL
                AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
        
        UNION ALL
        
        SELECT gsm.vt_start c_CycleEffectiveDate ,
          gsm.vt_start c_CycleEffectiveStart ,
          gsm.vt_end c_CycleEffectiveEnd ,
          gsm.vt_start c_SubscriptionStart ,
          gsm.vt_end c_SubscriptionEnd ,
          rcr.b_advance c_Advance ,
          pay.id_payee c__AccountID ,
          pay.id_payer c__PayingAccount ,
          plm.id_pi_instance c__PriceableItemInstanceID ,
          plm.id_pi_template c__PriceableItemTemplateID ,
          plm.id_po c__ProductOfferingID ,
          pay.vt_start c_PayerStart ,
          pay.vt_end c_PayerEnd ,
          sub.id_sub c__SubscriptionID ,
          NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart ,
          NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd ,
          rv.n_value c_UnitValue ,
          dbo.mtmindate() c_BilledThroughDate ,
          -1 c_LastIdRun ,
          dbo.mtmindate() c_MembershipStart ,
          dbo.mtmaxdate() c_MembershipEnd,
          AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, gsm.vt_end, startDate) c__IsAllowGenChargeByTrigger
          FROM t_gsubmember gsm
            INNER JOIN t_sub sub ON sub.id_group = gsm.id_group
            INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc
              AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
              AND pay.vt_start < gsm.vt_end AND pay.vt_end > gsm.vt_start
            INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
            INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
            INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
            JOIN TMP_CHANGED_UNITS rv ON rv.id_prop = rcr.id_prop
              AND sub.id_sub = rv.id_sub
              AND rv.tt_end = dbo.MTMaxDate()
              AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
              AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
              AND rv.vt_start < gsm.vt_end AND rv.vt_end > gsm.vt_start
        WHERE
          rcr.b_charge_per_participant = 'Y'
              AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
        
        UNION ALL
        
        SELECT sub.vt_start c_CycleEffectiveDate ,
          sub.vt_start c_CycleEffectiveStart ,
          sub.vt_end c_CycleEffectiveEnd ,
          sub.vt_start c_SubscriptionStart ,
          sub.vt_end c_SubscriptionEnd ,
          rcr.b_advance c_Advance ,
          pay.id_payee c__AccountID ,
          pay.id_payer c__PayingAccount ,
          plm.id_pi_instance c__PriceableItemInstanceID ,
          plm.id_pi_template c__PriceableItemTemplateID ,
          plm.id_po c__ProductOfferingID ,
          pay.vt_start c_PayerStart ,
          pay.vt_end c_PayerEnd ,
          sub.id_sub c__SubscriptionID ,
          NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart ,
          NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd ,
          rv.n_value c_UnitValue ,
          dbo.mtmindate() c_BilledThroughDate ,
          -1 c_LastIdRun ,
          grm.vt_start c_MembershipStart ,
          grm.vt_end c_MembershipEnd,
          AllowInitialArrersCharge(rcr.b_advance, pay.id_payee, sub.vt_end, null) c__IsAllowGenChargeByTrigger
          FROM t_gsub_recur_map grm
            /* TODO: GRM dates or sub dates or both for filtering */
            INNER JOIN t_sub sub ON grm.id_group = sub.id_group
            INNER JOIN t_payment_redirection pay ON pay.id_payee = grm.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
            INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
            INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
            INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
            JOIN TMP_CHANGED_UNITS rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub
            AND rv.tt_end = dbo.MTMaxDate()
            AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
            AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
        WHERE
          grm.tt_end = dbo.mtmaxdate()
              AND rcr.b_charge_per_participant = 'N'
              AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);

        /* Should be analozed for Arrears RC*/
        MeterInitialFromRecurWindow(startDate);
        MeterUdrcFromRecurWindow(startDate, 'DebitCorrection');

        INSERT INTO t_recur_window
          SELECT DISTINCT c_CycleEffectiveDate,
          c_CycleEffectiveStart,
          c_CycleEffectiveEnd,
          c_SubscriptionStart,
          c_SubscriptionEnd,
          c_Advance,
          c__AccountID,
          c__PayingAccount,
          c__PriceableItemInstanceID,
          c__PriceableItemTemplateID,
          c__ProductOfferingID,
          c_PayerStart,
          c_PayerEnd,
          c__SubscriptionID,
          c_UnitValueStart,
          c_UnitValueEnd,
          c_UnitValue,
          c_BilledThroughDate,
          c_LastIdRun,
          c_MembershipStart,
          c_MembershipEnd
          FROM TMP_NEWRW
          WHERE c__SubscriptionID = v_id_sub;

      END IF;
      /* TODO: Using "ON COMMIT DELETE ROWS" caused "ORA-14450: attempt to access a transactional temp table already in use" some time ago */
      DELETE FROM TMP_CHANGED_UNITS;
      DELETE FROM TMP_NEWRW;
      DELETE FROM TMP_UDRC;

    END IF;
  END AFTER STATEMENT;
END;
/

DROP TABLE tmp_rv_new;

DROP TABLE tmp_new_units;

ALTER FUNCTION metratime COMPILE ;

ALTER PROCEDURE insertchargesintosvctables COMPILE ;

CREATE OR REPLACE PROCEDURE MeterUdrcFromRecurWindow (currentDate date, actionType VARCHAR2) AS
  enabled VARCHAR2(10);
BEGIN
  SELECT value INTO enabled FROM t_db_values WHERE parameter = N'InstantRc';
  IF (enabled = 'false') THEN RETURN; END IF;

  INSERT INTO TMP_UDRC
  SELECT
    pci.dt_start                                                                        AS c_RCIntervalStart,
    pci.dt_end                                                                          AS c_RCIntervalEnd,
    ui.dt_start                                                                         AS c_BillingIntervalStart,
    ui.dt_end                                                                           AS c_BillingIntervalEnd,
    dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)                           AS c_RCIntervalSubscriptionStart,
    dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)                               AS c_RCIntervalSubscriptionEnd,
    rw.c_SubscriptionStart                                                              AS c_SubscriptionStart,
    rw.c_SubscriptionEnd                                                                AS c_SubscriptionEnd,
    CASE WHEN rw.c_advance  ='Y' THEN '1' ELSE '0' END                                  AS c_Advance,
    CASE WHEN rcr.b_prorate_on_activate ='Y' THEN '1' ELSE '0' END                      AS c_ProrateOnSubscription,
    trv.vt_start                                                                        AS c_UnitValueStart,
    trv.vt_end                                                                          AS c_UnitValueEnd,
    trv.n_value                                                                         AS c_UnitValue,
    rcr.n_rating_type                                                                   AS c_RatingType,
    CASE WHEN rcr.b_prorate_on_deactivate  ='Y' THEN '1' ELSE '0' END                   AS c_ProrateOnUnsubscription,
    CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END AS c_ProrationCycleLength,
    rw.c__accountid                                                                     AS c__AccountID,
    rw.c__payingaccount                                                                 AS c__PayingAccount,
    rw.c__priceableiteminstanceid                                                       AS c__PriceableItemInstanceID,
    rw.c__priceableitemtemplateid                                                       AS c__PriceableItemTemplateID,
    rw.c__productofferingid                                                             AS c__ProductOfferingID,
    dbo.MTMinOfTwoDates(pci.dt_end,rw.c_SubscriptionEnd)                                AS c_BilledRateDate,
    rw.c__subscriptionid                                                                AS c__SubscriptionID,
    currentui.id_interval                                                               AS c__IntervalID
  FROM t_usage_interval ui
    INNER JOIN TMP_NEWRW rw
      ON rw.c_payerstart            < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
      AND rw.c_cycleeffectivestart  < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
      AND rw.c_membershipstart      < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
      AND rw.c_SubscriptionStart    < ui.dt_end AND rw.c_SubscriptionEnd   > ui.dt_start
      AND rw.c_unitvaluestart       < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
    INNER JOIN TMP_CHANGED_UNITS trv ON trv.id_sub = rw.C__SubscriptionID AND trv.id_prop = rw.c__PriceableItemInstanceID
      AND trv.vt_start < rw.c_UnitValueEnd AND trv.vt_end > rw.c_UnitValueStart
    INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
    INNER JOIN t_usage_cycle ccl
      ON  ccl.id_usage_cycle = CASE
                            WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                            WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                            ELSE NULL
                        END
    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
    INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
      AND (
            (rcr.b_advance = 'Y' AND pci.dt_start BETWEEN ui.dt_start AND ui.dt_end)      /* If this is in advance, check if rc start falls in this interval */
            OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                               /* or check if the cycle end falls into this interval */
            OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)                    /* or this interval could be in the middle of the cycle */
          )
      AND pci.dt_end BETWEEN rw.c_payerstart AND rw.c_payerend                            /* rc start goes to this payer */
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
      AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
      AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
    INNER JOIN t_usage_interval currentui ON currentDate BETWEEN currentui.dt_start AND currentui.dt_end
      AND currentui.id_usage_cycle = ui.id_usage_cycle
  WHERE
    /* Only issue corrections if there's a previous iteration. */
    EXISTS (SELECT 1 FROM t_recur_value rv WHERE rv.id_sub = rw.c__SubscriptionID AND rv.tt_end < dbo.MTMaxDate())
    AND ui.dt_start < currentDate
    AND rw.c__IsAllowGenChargeByTrigger = 1;

  INSERT INTO TMP_RC
  SELECT actionType AS c_RCActionType,
         c_RCIntervalStart,
         c_RCIntervalEnd,
         c_BillingIntervalStart,
         c_BillingIntervalEnd,
         c_RCIntervalSubscriptionStart,
         c_RCIntervalSubscriptionEnd,
         c_SubscriptionStart,
         c_SubscriptionEnd,
         c_Advance,
         c_ProrateOnSubscription,
         'N' AS c_ProrateInstantly,
         c_UnitValueStart,
         c_UnitValueEnd,
         c_UnitValue,
         c_RatingType,
         c_ProrateOnUnsubscription,
         c_ProrationCycleLength,
         c__AccountID,
         c__PayingAccount,
         c__PriceableItemInstanceID,
         c__PriceableItemTemplateID,
         c__ProductOfferingID,
         c_BilledRateDate,
         c__SubscriptionID,
         c__IntervalID,
         SYS_GUID() AS idSourceSess
  FROM   TMP_UDRC;

  insertChargesIntoSvcTables('AdvanceCorrection','DebitCorrection');

  UPDATE  tmp_newrw rw
  SET     c_BilledThroughDate = currentDate
  WHERE   rw.c__IsAllowGenChargeByTrigger = 1;

END MeterUdrcFromRecurWindow;
/

DROP TABLE tmp_old_units;

CREATE INDEX mvm_scheduled_tasks_ndx1 ON mvm_scheduled_tasks(mvm_scheduled_dt,is_scheduled,mvm_logical_cluster);

CREATE INDEX mvm_scheduled_tasks_ndx2 ON mvm_scheduled_tasks(mvm_poll_guid);

CREATE INDEX idx_adj_txn_dt_crt_ndel_usage ON t_adjustment_transaction(dt_crt,UPPER("C_STATUS"),id_sess);

CREATE INDEX idx_t_audit_dt_crt ON t_audit("DT_CRT" DESC);

CREATE INDEX idx_tb_date ON t_batch("DT_CRT" DESC);

CREATE INDEX idx_s_billgroup_member_history ON t_billgroup_member_history(DECODE("TX_STATUS",'Failed',1,NULL));

CREATE UNIQUE INDEX idx_enum_id_data ON t_enum_data(id_enum_data,UPPER("NM_ENUM_DATA"));

CREATE INDEX idx_ft_date ON t_failed_transaction("DT_FAILURETIME" DESC);

ALTER PROCEDURE getlocalizedsiteinfo COMPILE ;

ALTER PROCEDURE sp_insertpolicy COMPILE ;

ALTER PROCEDURE checkaccountcreationbusinessru COMPILE ;

ALTER PROCEDURE clonesecuritypolicy COMPILE ;

ALTER PROCEDURE createpaymentrecordbitemporal COMPILE ;

ALTER PROCEDURE createpaymentrecord COMPILE ;

ALTER PROCEDURE addacctohierarchy COMPILE ;

CREATE OR REPLACE PROCEDURE addnewaccount  (
   p_id_acc_ext                 IN       VARCHAR2,
   p_acc_state                  IN       VARCHAR2,
   p_acc_status_ext             IN       INT,
   p_acc_vtstart                IN       DATE,
   p_acc_vtend                  IN       DATE,
   p_nm_login                   IN       NVARCHAR2,
   p_nm_space                   IN       NVARCHAR2,
   p_tx_password                IN       NVARCHAR2,
   p_auth_type                  IN       INT,
   p_langcode                   IN       VARCHAR2,
   p_profile_timezone           IN       INT,
   p_id_cycle_type              IN       INT,
   p_day_of_month               IN       INT,
   p_day_of_week                IN       INT,
   p_first_day_of_month         IN       INT,
   p_second_day_of_month        IN       INT,
   p_start_day                  IN       INT,
   p_start_month                IN       INT,
   p_start_year                 IN       INT,
   p_billable                   IN       VARCHAR2,
   p_id_payer                   IN       INT,
   p_payer_startdate            IN       DATE,
   p_payer_enddate              IN       DATE,
   p_payer_login                IN       NVARCHAR2,
   p_payer_namespace            IN       NVARCHAR2,
   p_id_ancestor                IN       INT,
   p_hierarchy_start            IN       DATE,
   p_hierarchy_end              IN       DATE,
   p_ancestor_name              IN       NVARCHAR2,
   p_ancestor_namespace         IN       NVARCHAR2,
   p_acc_type                   IN       VARCHAR2,
   p_apply_default_policy       IN       VARCHAR2,
   p_systemdate                 IN       DATE,
   p_enforce_same_corporation            VARCHAR2, /*  pass the currency through to CreatePaymentRecord */ /*  stored procedure only to validate it against the payer */ /*  We have to do it, because the t_av_internal record */ /* is not created yet */
   p_account_currency                    NVARCHAR2,
   p_profile_id                          INT,
   p_login_app                           VARCHAR2,
   accountid                             INTEGER,
   status                       OUT      INTEGER,
   p_hierarchy_path             OUT      VARCHAR2,
   p_currency                   OUT      NVARCHAR2,
   p_id_ancestor_out            OUT      INT,
   p_corporate_account_id       OUT      INT,
   p_ancestor_type_out          OUT      VARCHAR2
)
AS
   existing_account     INTEGER;
   payerid              INT;
   intervalid           INTEGER;
   intervalstart        DATE;
   intervalend          DATE;
   usagecycleid         INTEGER;
   acc_startdate        DATE;
   acc_enddate          DATE;
   payer_startdate      DATE;
   payer_enddate        DATE;
   ancestor_startdate   DATE;
   ancestor_enddate     DATE;
   create_dt_end        DATE;
   ancestorid           INTEGER;
   siteid               INTEGER;
   foldername           VARCHAR2 (255);
   isnotsubscriber      INTEGER;
   payerbillable        VARCHAR2 (1);
   authancestor         INTEGER;
   varmaxdatetime       DATE;
   stoo_error           INTEGER        := 0;
   stoo_errmsg          VARCHAR2 (255);
   temp_count           INT;
   dummycursor          sys_refcursor;
   id_type              INT;
   acc_type_out         VARCHAR2 (40);
   p_count              INTEGER;
   l_polID              INTEGER;
   l_id_parent_cap          INTEGER;
   l_id_atomic_cap          INTEGER;
   templateId           INTEGER;
   templateOwner        INTEGER;
   sessionId            INTEGER;
   templateCount        INTEGER;
BEGIN
   p_ancestor_type_out := 'Err';
/* step : validate that the account does not already exist.  Note    that this check is performed by checking the t_account_mapper table.    However, we don't check the account state so the new account could
conflict with an account that is an archived state.  You would need
to purge the archived account before the new account could be created.
*/
   varmaxdatetime := dbo.mtmaxdate ();
   existing_account := dbo.lookupaccount (p_nm_login, p_nm_space);

   IF existing_account <> -1
   THEN
      /* ACCOUNTMAPPER_ERR_ALREADY_EXISTS*/
      status := -501284862;
      RETURN;
   END IF;

   /* step : check account creation business rules*/
   IF (LOWER (p_nm_login) NOT IN ('rm', 'mps_folder'))
   THEN
      checkaccountcreationbusinessru (p_nm_space,
                                      p_acc_type,
                                      p_id_ancestor,
                                      status
                                     );

      IF (status <> 1)
      THEN
         RETURN;
      END IF;
   END IF;

   /* step : populate the account start dates if the values were
   not passed into the sproc
   */
   SELECT CASE
             WHEN p_acc_vtstart IS NULL
                THEN dbo.mtstartofday (p_systemdate)
             ELSE dbo.mtstartofday (p_acc_vtstart)
          END,
          CASE
             WHEN p_acc_vtend IS NULL
                THEN dbo.mtmaxdate ()
             ELSE dbo.mtendofday (p_acc_vtend)
          END
     INTO acc_startdate,
          acc_enddate
     FROM DUAL;

   /* step : get the account ID and increment counter
   select id_current
     into accountid
     from t_current_id
    where nm_current = 'id_acc';

   update t_current_id
      set id_current = id_current + 1
    where nm_current = 'id_acc'; */

   /* step: populate t_account*/
   SELECT id_type
     INTO id_type
     FROM t_account_type
    WHERE LOWER (NAME) = LOWER (p_acc_type);

   IF p_id_acc_ext IS NULL
   THEN
      INSERT INTO t_account
                  (id_acc, id_acc_ext, dt_crt, id_type
                  )
           VALUES (accountid, SYS_GUID (), acc_startdate, id_type
                  );
   ELSE
      INSERT INTO t_account
                  (id_acc, id_acc_ext, dt_crt, id_type
                  )
           VALUES (accountid, p_id_acc_ext, acc_startdate, id_type
                  );
   END IF;

   /* step : initial account state*/
   INSERT INTO t_account_state
               (id_acc, status, vt_start, vt_end
               )
        VALUES (accountid, p_acc_state, acc_startdate, acc_enddate
               );

   INSERT INTO t_account_state_history
               (id_acc, status, vt_start, vt_end,
                tt_start, tt_end
               )
        VALUES (accountid, p_acc_state, acc_startdate, acc_enddate,
                p_systemdate, varmaxdatetime
               );

   /* step : login and namespace information*/
   INSERT INTO t_account_mapper
               (nm_login, nm_space, id_acc
               )
        VALUES (p_nm_login, LOWER (p_nm_space), accountid
               );

   /* step : user credentials*/
   /* check if authentification is MetraNetInternal then add user credentials */
   IF (COALESCE(p_auth_type, 1) = 1)
   THEN
       INSERT INTO t_user_credentials
                   (nm_login, nm_space, tx_password
                   )
            VALUES (p_nm_login, LOWER (p_nm_space), p_tx_password
                   );
   END IF;

   /* step : t_profile. This looks like it is only for timezone information */
   INSERT INTO t_profile
               (id_profile, nm_tag, val_tag, tx_desc
               )
        VALUES (p_profile_id, 'timeZoneID', p_profile_timezone, 'System'
               );

   /* step : site user information*/
   getlocalizedsiteinfo (p_nm_space, p_langcode, siteid);

   INSERT INTO t_site_user
               (nm_login, id_site, id_profile
               )
        VALUES (p_nm_login, siteid, p_profile_id
               );

   /* associates the account with the Usage Server */

   /* step : determines the usage cycle ID from the passed in date properties*/
   IF (p_id_cycle_type is not null) THEN
	   BEGIN
	      FOR i IN (SELECT id_usage_cycle
	                  FROM t_usage_cycle CYCLE
	                 WHERE CYCLE.id_cycle_type = p_id_cycle_type
	                   AND (   p_day_of_month = CYCLE.day_of_month
	                        OR p_day_of_month IS NULL
	                       )
	                   AND (   p_day_of_week = CYCLE.day_of_week
	                        OR p_day_of_week IS NULL
	                       )
	                   AND (   p_first_day_of_month = CYCLE.first_day_of_month
	                        OR p_first_day_of_month IS NULL
	                       )
	                   AND (   p_second_day_of_month = CYCLE.second_day_of_month
	                        OR p_second_day_of_month IS NULL
	                       )
	                   AND (p_start_day = CYCLE.start_day OR p_start_day IS NULL
	                       )
	                   AND (   p_start_month = CYCLE.start_month
	                        OR p_start_month IS NULL
	                       )
	                   AND (p_start_year = CYCLE.start_year
	                        OR p_start_year IS NULL
	                       ))
	      LOOP
	         usagecycleid := i.id_usage_cycle;
	      END LOOP;
	   END;

	   /* step : add the account to usage cycle mapping */
	   INSERT INTO t_acc_usage_cycle
	               (id_acc, id_usage_cycle
	               )
	        VALUES (accountid, usagecycleid
	               );

	   /* step : creates only needed intervals and mappings for this account only.
	    other accounts affected by any new intervals (same cycle) will
	    be associated later in the day via a usm -create. */
	   /* Defines the date range that an interval must fall into to
	     be considered 'active'. */
	   SELECT (p_systemdate + n_adv_interval_creation) INTO create_dt_end FROM t_usage_server;

	   IF (
	     /* Exclude archived accounts. */
	     p_acc_state <> 'AR'
	     /* The account has already started or is about to start. */
	     AND acc_startdate < create_dt_end
	     /* The account has not yet ended. */
	     AND acc_enddate >= p_systemdate)
	   THEN
	     INSERT INTO t_usage_interval(id_interval,id_usage_cycle,dt_start,dt_end,tx_interval_status)
	     SELECT ref.id_interval,ref.id_cycle,ref.dt_start,ref.dt_end, 'O'
	     FROM
	     t_pc_interval ref
	     WHERE
	     /* Only add intervals that don't exist */
	     NOT EXISTS (
	       SELECT 1 FROM t_usage_interval ui
	       WHERE ref.id_interval = ui.id_interval)
	     AND
	     ref.id_cycle = usagecycleid AND
	     /* Reference interval must at least partially overlap the [minstart, maxend] period. */
	     (ref.dt_end >= acc_startdate AND
	      ref.dt_start <= CASE WHEN acc_enddate < create_dt_end THEN acc_enddate ELSE create_dt_end END);

	     INSERT INTO t_acc_usage_interval(id_acc,id_usage_interval,tx_status,dt_effective)
	     SELECT accountid, ref.id_interval, ref.tx_interval_status, NULL
	     FROM t_usage_interval ref
	     WHERE
	     ref.id_usage_cycle = usagecycleid AND
	     /* Reference interval must at least partially overlap the [minstart, maxend] period. */
	     (ref.dt_end >= acc_startdate AND
	      ref.dt_start <= CASE WHEN acc_enddate < create_dt_end THEN acc_enddate ELSE create_dt_end END)
	     /* Only add mappings for non-blocked intervals */
	     AND ref.tx_interval_status <> 'B';
	   END IF;
  END IF;
   /* step : Non-billable accounts must have a payment redirection record*/
   IF (    p_billable = 'N'
       AND (    p_id_payer IS NULL
            AND (    p_id_payer IS NULL
                 AND p_payer_login IS NULL
                 AND p_payer_namespace IS NULL
                )
           )
      )
   THEN
      /* MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER*/
      status := -486604768;
      RETURN;
   END IF;

   SELECT
          /* default the payer start date to the start of the account  */
          CASE
             WHEN p_payer_startdate IS NULL
                THEN acc_startdate
             ELSE dbo.mtstartofday (p_payer_startdate)
          END,
          /* default the payer end date to the end of the account if NULL*/
          CASE
             WHEN p_payer_enddate IS NULL
                THEN acc_enddate
             ELSE dbo.mtendofday (p_payer_enddate)
          END,
          /* step : default the hierarchy start date to the account start date */
          CASE
             WHEN p_hierarchy_start IS NULL
                THEN acc_startdate
             ELSE p_hierarchy_start
          END,
          /* step : default the hierarchy end date to the account end date*/
          CASE
             WHEN p_hierarchy_end IS NULL
                THEN acc_enddate
             ELSE dbo.mtendofday(p_hierarchy_end)
          END,
          /* step : resolve the ancestor ID if necessary*/
          CASE
             WHEN p_ancestor_name IS NOT NULL
             AND p_ancestor_namespace IS NOT NULL
                THEN dbo.lookupaccount (p_ancestor_name, p_ancestor_namespace)
             ELSE
                 /* if the ancestor ID iis NULL then default to the root*/
          CASE
             WHEN p_id_ancestor IS NULL
                THEN 1
             ELSE p_id_ancestor
          END
          END,
          /* step : resolve the payer account if necessary*/
          CASE
             WHEN p_payer_login IS NOT NULL AND p_payer_namespace IS NOT NULL
                THEN dbo.lookupaccount (p_payer_login, p_payer_namespace)
             ELSE CASE
             WHEN p_id_payer IS NULL
                THEN accountid
             ELSE p_id_payer
          END
          END
     INTO payer_startdate,
          payer_enddate,
          ancestor_startdate,
          ancestor_enddate,
          ancestorid,
          payerid
     FROM DUAL;

   /* -- Fix CORE-762: Check that payerid exists */
   begin
     select count(*) into p_count
     from t_account
     where id_acc = payerid;
     if p_count = 0 then /* MT_CANNOT_RESOLVE_PAYING_ACCOUNT*/
       status := -486604792;
       return;
     end if;
   end;

   IF ancestorid = -1
   THEN
      /* MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT*/
      status := -486604791;
      RETURN;
   ELSE
      p_id_ancestor_out := ancestorid;
   END IF;

   IF (UPPER (p_acc_type) = 'SYSTEMACCOUNT')
   THEN
      /* anyone who is not a system account is a subscriber */
      isnotsubscriber := 1;
   END IF;

   /* step: we trust AddAccToHIerarchy to set the status
   to 1 in case of success*/
   addacctohierarchy (ancestorid,
                      accountid,
                      ancestor_startdate,
                      ancestor_enddate,
                      acc_startdate,
                      p_ancestor_type_out,
                      acc_type_out,
                      status
                     );

   IF status <> 1
   THEN
      RETURN;
   END IF;

   /* step: populate t_dm_account and t_dm_account_ancestor table */
   INSERT INTO t_dm_account
               (id_dm_acc, id_acc, vt_start, vt_end)
      SELECT seq_t_dm_account.NEXTVAL, id_descendent, vt_start, vt_end
        FROM t_account_ancestor
       WHERE id_ancestor = 1 AND id_descendent = accountid;

   INSERT INTO t_dm_account_ancestor
               (id_dm_ancestor, id_dm_descendent, num_generations)
      SELECT dm2.id_dm_acc, dm1.id_dm_acc, aa1.num_generations
        FROM t_account_ancestor aa1 INNER JOIN t_dm_account dm1 ON aa1.id_descendent =
                                                                     dm1.id_acc
                                                              AND aa1.vt_start <=
                                                                     dm1.vt_end
                                                              AND dm1.vt_start <=
                                                                     aa1.vt_end
             INNER JOIN t_dm_account dm2 ON aa1.id_ancestor = dm2.id_acc
                                       AND aa1.vt_start <= dm2.vt_end
                                       AND dm2.vt_start <= aa1.vt_end
       WHERE dm1.id_acc <> dm2.id_acc
         AND dm1.vt_start >= dm2.vt_start
         AND dm1.vt_end <= dm2.vt_end
         AND aa1.id_descendent = accountid;

   INSERT INTO t_dm_account_ancestor
               (id_dm_ancestor, id_dm_descendent, num_generations)
      SELECT id_dm_acc, id_dm_acc, 0
        FROM t_dm_account
       WHERE id_acc = accountid;

   /* step: pass in the current account's billable flag when creating the    payment redirection record IF the account is paying for itself */
   SELECT CASE
             WHEN payerid = accountid
                THEN p_billable
             ELSE NULL
          END
     INTO payerbillable
     FROM DUAL;

   createpaymentrecord (payerid,
                        accountid,
                        payer_startdate,
                        payer_enddate,
                        payerbillable,
                        p_systemdate,
                        'N',
                        p_enforce_same_corporation,
                        p_account_currency,
                        status
                       );

   IF (status <> 1)
   THEN
      RETURN;
   END IF;

      BEGIN
      SELECT tx_path
        INTO p_hierarchy_path
        FROM t_account_ancestor
       WHERE id_descendent = accountid
         AND id_ancestor = 1
         AND ancestor_startdate BETWEEN vt_start AND vt_end;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   /* if "Apply Default Policy" flag is set, then figure out    "ancestor" id based on account type in case the account is not    a subscriber*/

    /*BP: 10/5 Make sure that t_principal_policy record is always there, otherwise ApplyRoleMembership will break*/
    Sp_Insertpolicy( 'id_acc', accountID,'A', l_polID );

    /* 2/11/2010: TRW - We are now granting the "Manage Account Hierarchies" capability to all accounts
        upon their creation.  They are being granted read/write access to their own account only (not to
        sub accounts).  This is being done to facilitate access to their own information via the MetraNet
        ActivityServices web services, which are now checking capabilities a lot more */

    /* Insert "Manage Account Hierarchies" parent capability */
    insert into t_capability_instance(id_cap_instance, tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
    select
        seq_t_cap_instance.NextVal,
    'ABCD',
        null,
        l_polID,
        id_cap_type
    from
        t_composite_capability_type
    where
        tx_name = 'Manage Account Hierarchies';

    select seq_t_cap_instance.CURRVAL into l_id_parent_cap from dual;

    /* Insert MTPathCapability atomic capability */
    insert into t_capability_instance(id_cap_instance, tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
    select
        seq_t_cap_instance.NextVal,
        'ABCD',
        l_id_parent_cap,
        l_polID,
        id_cap_type
    from
        t_atomic_capability_type
    where
        upper(tx_name) = 'MTPATHCAPABILITY';

    select seq_t_cap_instance.CURRVAL into l_id_atomic_cap from dual;

    /* Insert into t_path_capability account's path */
    insert into t_path_capability(id_cap_instance, tx_param_name, tx_op, param_value)
    values( l_id_atomic_cap, null, null, p_hierarchy_path || '/');

    /* Insert MTEnumCapability atomic capability */
    insert into t_capability_instance(id_cap_instance, tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
    select
        seq_t_cap_instance.NextVal,
        'ABCD',
        l_id_parent_cap,
        l_polID,
        id_cap_type
    from
        t_atomic_capability_type
    where
        upper(tx_name) = 'MTENUMTYPECAPABILITY';

    select seq_t_cap_instance.CURRVAL into l_id_atomic_cap from dual;

    /* Insert into t_enum_capability to grant Write access */
    insert into t_enum_capability(id_cap_instance, tx_param_name, tx_op, param_value)
    select
        l_id_atomic_cap,
        null,
        '=',
        id_enum_data
    from
        t_enum_data
    where
        upper(nm_enum_data) = 'GLOBAL/ACCESSLEVEL/WRITE';

   IF (   UPPER (p_apply_default_policy) = 'Y'
       OR UPPER (p_apply_default_policy) = 'T'
       OR UPPER (p_apply_default_policy) = '1'
      )
   THEN
      authancestor := ancestorid;

      IF isnotsubscriber > 0
      THEN
         foldername :=
            CASE
               WHEN UPPER (p_login_app) = 'CSR'
                  THEN 'csr_folder'
               WHEN UPPER (p_login_app) = 'MOM'
                  THEN 'mom_folder'
               WHEN UPPER (p_login_app) = 'MCM'
                  THEN 'mcm_folder'
               WHEN UPPER (p_login_app) = 'MPS'
                  THEN 'mps_folder'
            END;

         BEGIN
            authancestor := NULL;

            SELECT id_acc
              INTO authancestor
              FROM t_account_mapper
             WHERE UPPER (nm_login) = UPPER (foldername)
               AND UPPER (nm_space) = 'AUTH'; /* record  for ancestor is not on t_account_mapper just return OK*/
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               status := 1;
         END;
      END IF; /* apply default security policy; only do it if ancestor was found*/

      IF authancestor > 1
      THEN
         clonesecuritypolicy (authancestor, accountid, 'D', 'A');
      END IF;
   END IF;

    /* resolve accounts' corporation.
    select ancestor whose ancestor is of a type that
    has b_iscorporate set to true */

   BEGIN
      SELECT max(ancestor.id_ancestor)
        INTO p_corporate_account_id
        FROM t_account_ancestor ancestor INNER JOIN t_account acc ON acc.id_acc =
                                                                       ancestor.id_ancestor
             INNER JOIN t_account_type atype ON acc.id_type = atype.id_type
       WHERE ancestor.id_descendent = accountid
         AND atype.b_iscorporate = '1'
         AND acc_startdate BETWEEN ancestor.vt_start AND ancestor.vt_end;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   IF (p_corporate_account_id IS NULL)
   THEN
      p_corporate_account_id := accountid;
   END IF;

   IF ancestorid <> 1
   THEN
      BEGIN
         SELECT c_currency
           INTO p_currency
           FROM t_av_internal
          WHERE id_acc = ancestorid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      /* if cross corp business rule is enforced,
      verify that currencis match */
      IF (    p_enforce_same_corporation = '1'
          AND (LOWER (p_currency) <> LOWER (p_account_currency))
         )
      THEN
         /* MT_CURRENCY_MISMATCH*/
         status := -486604737;
         RETURN;
      END IF;
   END IF;

   /* done*/
   status := 1;
END;
/

CREATE OR REPLACE procedure SequencedDeleteAccOwnership
		(p_id_owner	int,
		p_id_owned	int,
		p_vt_start	date,
		p_vt_end	date,
		p_tt_current	TIMESTAMP,
		p_tt_max	TIMESTAMP,
		p_status OUT int)
		as
		begin
    p_status := 0;
    INSERT INTO t_acc_ownership(id_owner, id_owned, id_relation_type, n_percent,  vt_start, vt_end, tt_start, tt_end)
    SELECT id_owner, id_owned, id_relation_type, n_percent, (p_vt_end + INTERVAL '1' SECOND) AS vt_start, vt_end, p_tt_current as tt_start, p_tt_max as tt_end
        FROM t_acc_ownership
        WHERE id_owner = p_id_owner AND id_owned = p_id_owned
	  AND vt_start < p_vt_start AND vt_end > p_vt_end and tt_end = p_tt_max;
	    /* Valid time update becomes bi-temporal insert and update */
      INSERT INTO t_acc_ownership(id_owner, id_owned, id_relation_type, n_percent,  vt_start, vt_end, tt_start, tt_end)
      SELECT id_owner, id_owned, id_relation_type, n_percent, vt_start, (p_vt_start - INTERVAL '1' SECOND) AS vt_end, p_tt_current AS tt_start, p_tt_max AS tt_end
      FROM t_acc_ownership
	    WHERE id_owner = p_id_owner AND id_owned = p_id_owned
	    AND vt_start < p_vt_start AND vt_end >= p_vt_start AND tt_end = p_tt_max;
      
      UPDATE t_acc_ownership SET tt_end = p_tt_current
	    WHERE id_owner = p_id_owner AND id_owned = p_id_owned
	    AND vt_start < p_vt_start AND vt_end >= p_vt_start AND tt_end = p_tt_max;
	    /* Valid time update becomes bi-temporal insert (of the modified existing history into the past history) and update (of the modified existing history) */
      INSERT INTO t_acc_ownership(id_owner, id_owned, id_relation_type, n_percent,  vt_start, vt_end, tt_start, tt_end)
      SELECT  id_owner, id_owned, id_relation_type, n_percent, (p_vt_end + INTERVAL '1' SECOND) AS vt_start, vt_end, p_tt_current AS tt_start, p_tt_max AS tt_end
      FROM t_acc_ownership
	    WHERE id_owner = p_id_owner AND id_owned = p_id_owned
	    AND vt_start <= p_vt_end AND vt_end > p_vt_end AND tt_end = p_tt_max;

      UPDATE t_acc_ownership SET tt_end = p_tt_current
      WHERE id_owner = p_id_owner AND id_owned = p_id_owned
      AND vt_start <= p_vt_end AND vt_end > p_vt_end AND tt_end = p_tt_max;
      /*-- Now we delete any interval contained entirely in the interval we are deleting.
       Transaction table delete is really an update of the tt_end
         [----------------]                 (interval that is being modified)
       [------------------------]           (interval we are deleting) */
      UPDATE t_acc_ownership SET tt_end = p_tt_current
      WHERE id_owner = p_id_owner AND id_owned = p_id_owned
	    AND vt_start >= p_vt_start AND vt_end <= p_vt_end AND tt_end = p_tt_max;
      exception
				when others then null;
      end;
/

CREATE OR REPLACE procedure SequencedInsertAccOwnership
		(p_id_owner	int,
		p_id_owned	int,
		p_id_relation_type	int,
		p_percent int,
		p_vt_start	date,
		p_vt_end	date,
		p_tt_current	TIMESTAMP,
		p_tt_max	TIMESTAMP,
		p_status OUT int)
    as
    p_cnt INT;
    begin
    p_status	:=	0;
    INSERT INTO	t_acc_ownership(id_owner,	id_owned,	id_relation_type,	n_percent,	vt_start,	vt_end,	tt_start,	tt_end)
    SELECT owner.id_acc, owned.id_acc, ed.id_enum_data,	p_percent,	p_vt_start, p_vt_end,	p_tt_current, p_tt_max
    FROM t_account owner
    CROSS	JOIN t_account owned
    CROSS	JOIN t_enum_data ed
    WHERE
    owner.id_acc=p_id_owner
    AND
    owned.id_acc=p_id_owned
    AND
    ed.id_enum_data=p_id_relation_type;
    IF (SQL%rowcount	<> 1) then
			SELECT COUNT(*) into p_cnt FROM	t_account	where	id_acc = p_id_owner;
			IF (p_cnt	=	0) then
				p_status	:=	-515899365;
			else
			SELECT COUNT(*) into p_cnt FROM	t_account	where	id_acc = p_id_owned;
			IF (p_cnt	=	0) then
			p_status	:=	-515899365;
			ELSE
			SELECT COUNT(*) into p_cnt FROM	t_enum_data	where	id_enum_data = p_id_relation_type;
			IF (p_cnt	=	0) then
			p_status	:=	-2147483607;
			END if;
			END if;
			END if;
		end IF;
    END;
/

CREATE OR REPLACE procedure SequencedUpsertAccOwnership
	    	(p_id_owner int,
		    p_id_owned int,
		    p_id_relation_type int,
		    p_percent int,
		    p_vt_start date,
		    p_vt_end date,
		    p_tt_current TIMESTAMP,
		    p_tt_max TIMESTAMP,
		    p_status OUT int)
        as
        begin
          SequencedDeleteAccOwnership (p_id_owner, p_id_owned, p_vt_start, p_vt_end, p_tt_current, p_tt_max, p_status);
        if (p_status = 0) then
          SequencedInsertAccOwnership (p_id_owner, p_id_owned, p_id_relation_type,
							p_percent, p_vt_start, p_vt_end, p_tt_current, p_tt_max, p_status);
        END if;
        end;
/

CREATE PROCEDURE GetReconcileParameters(
do_recovery OUT int,
dt_min OUT date,
dt_max OUT date
)
AS
BEGIN

    /******************************************
     ** SET DEFAULTS
     ******************************************/
    do_recovery := 1;
    DECLARE cnt INT;
    BEGIN

      SELECT count(*) INTO cnt FROM mvm_resubmit_runs WHERE dt_completed > MTMINDATE();

      IF cnt > 0 THEN
        SELECT range_end_date INTO dt_min FROM (
          SELECT range_end_date  FROM mvm_resubmit_runs
          WHERE dt_completed > MTMINDATE()
          ORDER BY dt_completed DESC)
        WHERE rownum = 1;
      ELSE
        dt_min := MTMINDATE();
      END IF;
    /**************************************************
     ** IF there is usage then we get the current value,
     ** otherwise we fall back to the set default above 
     *************************************************/
    SELECT MAX(dt_completed) INTO dt_max  FROM t_message
    WHERE dt_completed BETWEEN dt_min and METRATIME(1,'RAMP');
    IF dt_max IS NULL THEN
      BEGIN
        do_recovery := 0;
        dt_min := MTMINDATE();
        dt_max := MTMINDATE();
      END;
    ELSE
      IF dt_max = dt_min THEN
        do_recovery := 0;
      END IF;
    END IF;
  END;
END;
/

ALTER PROCEDURE mvm_generate_table_name COMPILE ;

CREATE OR REPLACE PROCEDURE mvm_create_blk_upd_table2(
    p_table  VARCHAR2,            -- table to bulk update
    p_prefix VARCHAR2,            -- prefix on blk_upd_table name
    p_mvm_run_id NUMBER,           --  identifier of mvm run
    p_node_id VARCHAR2,           --  identifier of mvm node_id
    p_blk_upd_table OUT VARCHAR2, -- table we created
    p_pk_col_string VARCHAR2 DEFAULT '' )
AS
  CURSOR cur_columns
  IS
    -- RAW needs 1 added to datalength to work around OracleBulkCopy bug:
    -- http://forums.oracle.com/forums/thread.jspa?threadID=968824
    SELECT column_name
      ||' '
      ||data_type
      || DECODE(data_type,'NUMBER',DECODE(data_precision, NULL, '','('
      ||data_precision
      ||','
      ||data_scale
      ||')'),'CHAR','('
      ||data_length
      ||')','VARCHAR2','('
      ||data_length
      ||')','NVARCHAR2','('
      ||char_length
      ||')','RAW','('
      ||(data_length+1)
      ||')',' ') col_string
    FROM user_tab_columns a
    WHERE table_name = upper(p_table)
    ORDER BY column_id;
  sql_stmt LONG;
  v_col_string VARCHAR2(4000);
  v_curr_count NUMBER;
  field_prefix VARCHAR2(4000);
  temp_prefix  VARCHAR2(1000);
  my_attempts  NUMBER;
  idx          NUMBER;
TYPE T_TABLE
IS
  TABLE OF VARCHAR2(30);
  v_pk_cols T_TABLE;
BEGIN
  -- Populate v_pk_cols with ordered list of primary key columns.
  -- Use comma delimited string p_pk_col_string if passed, else look at pk fields
  -- in p_table
  v_pk_cols          :=T_TABLE();

  IF p_pk_col_string IS NULL THEN
    idx              := 1;
    FOR csr          IN
    (SELECT column_name--,
 --     position idx 
    FROM user_constraints cons,
      user_cons_columns cols
    WHERE cols.table_name    = upper(p_table)
    AND cons.constraint_type = 'P'
    AND cons.constraint_name = cols.constraint_name
    AND cons.owner           = cols.owner
    ORDER BY cols.position
    )
    LOOP
      v_pk_cols.extend;
      v_pk_cols(idx):=csr.column_name;
      idx := idx + 1;
    END LOOP;
  ELSE
    FOR csr IN
    (
    -- this is a way to split p_pk_col_string 'a,b,c' into 3 rows
  WITH lines AS
    (SELECT level line FROM dual CONNECT BY level <= 10
    ),
    data AS
    (SELECT ','||p_pk_col_string||',' pk_string_list FROM dual
    )
  SELECT line                                              -1 pk_idx,
    SUBSTR(pk_string_list, instr(pk_string_list,',',1,line)+1, instr(pk_string_list,',',1,line+1)-instr(pk_string_list,',',1,line)-1 ) pk_col
  FROM data,
    lines
  WHERE line < LENGTH(pk_string_list)-LENGTH(REPLACE(pk_string_list,',',''))
  ORDER BY 1,
    2
    )
    LOOP
      v_pk_cols.extend;
      v_pk_cols(csr.pk_idx+1):=csr.pk_col;
    END LOOP;
  END IF;
  -- name of tmp bulk update table
  mvm_generate_table_name(p_prefix, p_blk_upd_table);
  -- create statement
  sql_stmt     := 'create table '||p_blk_upd_table||'( format_id int,';
  field_prefix := '';
  -- add orig pk cols --
  FOR v_pk_idx IN v_pk_cols.FIRST..v_pk_cols.LAST
  LOOP
    FOR col IN
    (SELECT 'pk_'
      || (v_pk_idx-1)
      ||' '
      ||data_type
      || DECODE(data_type,'NUMBER',DECODE(data_precision, NULL, '','('
      ||data_precision
      ||','
      ||data_scale
      ||')'),'CHAR','('
      ||data_length
      ||')','VARCHAR2','('
      ||data_length
      ||')','NVARCHAR2','('
      ||char_length
      ||')','RAW','('
      ||(data_length+1)
      ||')',' ') col_string
    FROM user_tab_columns a
    WHERE a.table_name= upper(p_table)
    AND lower(a.column_name) = lower(v_pk_cols(v_pk_idx))
    )
    LOOP
      sql_stmt    :=sql_stmt || field_prefix ||col.col_string;
      field_prefix:=',';
    END LOOP;
  END LOOP;
  ----------------------
  -- add every field in the table
  FOR v_rec IN cur_columns
  LOOP
    sql_stmt     := sql_stmt||field_prefix||' '||v_rec.col_string;
    field_prefix := ',';
  END LOOP;
  -- specify  the pk
  field_prefix := '';
  sql_stmt     :=sql_stmt||',CONSTRAINT '||p_blk_upd_table||' PRIMARY KEY (';
  FOR v_pk_idx IN v_pk_cols.FIRST..v_pk_cols.LAST
  LOOP
    sql_stmt    :=sql_stmt || field_prefix ||'pk_'||(v_pk_idx-1);
    field_prefix:=',';
  END LOOP;
  IF field_prefix IS NULL THEN
    raise_application_error(-20101 , 'Error, cannot create bulk update table for '||p_table|| ' since it has no unique index');
  END IF;
  sql_stmt :=sql_stmt||')';
  --end the create
  sql_stmt := sql_stmt||')';
  dbms_output.put_line(sql_stmt);
  EXECUTE IMMEDIATE (sql_stmt);

  insert into amp_staging_tables (mvm_run_id, node_id, staging_table_name, create_dt) values(p_mvm_run_id, p_node_id, p_blk_upd_table, SYSDATE);
END;
/

ALTER PROCEDURE getidblock COMPILE ;

ALTER FUNCTION mtmaxdate COMPILE ;

CREATE PROCEDURE ReconcileUsageForward
(
  v_WindowBegin IN DATE DEFAULT NULL ,
  v_WindowEnd IN DATE DEFAULT NULL ,
  v_SafeDate IN DATE DEFAULT NULL
)
AS
  
   v_dt_reconcile DATE;
   /***************************************************************
        ** FIRST ORDER OF BUSINESS (SUSPENDED PIPELINE TRANSACTIONS)
        ** CLEAR THEM SINCE WE WILL RESUBMIT THEM HERE...
        ***************************************************************/
   v_suspended_txn_time NUMBER(10,0);
   /***************************************************************
    ** END (SUSPENDED PIPELINE TRANSACTIONS)
    ***************************************************************/
   v_idMessage NUMBER(10,0);
   v_id_run NUMBER(10,0);
   v_msg_count NUMBER(10,0);
   v_ss_count NUMBER(10,0);
   v_s_count NUMBER(10,0);
   v_new_partition NUMBER(10,0);
   v_id_svc NUMBER(10,0);
   v_tbl_name VARCHAR2(128);
   v_statement VARCHAR2(2000);
   v_start_tm DATE;
   v_mtr_tm DATE;
   v_dt_complete DATE;
   v_counter NUMBER;

   /**********************************************************************
    ** I DETEST CURSORS, BUT NOW SURE HOW TO DO THIS WELL SINCE I 
    ** NEED TO UPDATE THE TABLE WHICH NAME IS IN A TABLE...
    **********************************************************************/
   CURSOR svc_tbl_cursor
     IS SELECT DISTINCT id_svc
     FROM tt_tmpReconcileMessageTable_2
     GROUP BY id_svc;

BEGIN

   /**********************************************************************
    ** VALIDATE INPUTS 
    **********************************************************************/

/*TODO:SETSET XACT_ABORT ON*/
   IF v_WindowBegin IS NULL OR v_WindowEnd IS NULL THEN
   BEGIN
      DBMS_OUTPUT.PUT_LINE('WINDOW DATES ARE NULL: msg_count = -1, ss_count = -1, s_count = -1');
      RETURN;
   END;
   END IF;

/*   IF v_WindowBegin = ' ' OR v_WindowEnd = ' ' THEN
   BEGIN
      DBMS_OUTPUT.PUT_LINE('WINDOW DATES ARE EMPTY: msg_count = -2, ss_count = -2, s_count = -2');
      RETURN;
   END;
   END IF;*/
   
   IF v_WindowBegin >= v_WindowEnd THEN
   BEGIN
      DBMS_OUTPUT.PUT_LINE('WINDOW DATES ARE INVALID: msg_count = 0, ss_count = 0, s_count = 0');
      RETURN;
   END;
   END IF;
   
    /**********************************************************************
    ** CREATE TEMPORARY TABLES IF DO NOT EXIST 
    **********************************************************************/

  SELECT count(*) INTO v_counter FROM all_objects WHERE object_type='TABLE' AND LOWER(object_name)='tt_servicemap';
  IF v_counter = 0 THEN
    EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE tt_ServiceMap
     (id_svc NUMBER(10,0)  NOT NULL,
      table_name VARCHAR2(255)  NOT NULL,
      PRIMARY KEY( id_svc ));';
  END IF;
   
  SELECT count(*) INTO v_counter FROM all_objects WHERE object_type='TABLE' AND LOWER(object_name)='tt_sessionsetmap';
  IF v_counter = 0 THEN
    EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE tt_SessionSetMap
     (id_ss NUMBER(10,0)  NOT NULL,
      new_id_ss NUMBER(10,0) ,
      sess_cnt NUMBER(10,0) ,
      PRIMARY KEY( id_ss ));';
  END IF;
   
  SELECT count(*) INTO v_counter FROM all_objects WHERE object_type='TABLE' AND LOWER(object_name)='tt_messageidtable';
  IF v_counter = 0 THEN
    EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE tt_MessageIdTable
    ( id_message NUMBER(10,0)  NOT NULL,
      new_id_message NUMBER(10,0) ,
      PRIMARY KEY( id_message ));';
  END IF;
  
  SELECT count(*) INTO v_counter FROM all_objects WHERE object_type='TABLE' AND LOWER(object_name)='tt_tmpreconcilemessagetable';
  IF v_counter = 0 THEN
    EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE tt_tmpReconcileMessageTable
    ( id_message NUMBER(10,0) ,
      dt_completed DATE ,
      dt_assigned DATE ,
      b_root CHAR(1) ,
      id_ss NUMBER(10,0) ,
      id_svc NUMBER(10,0) ,
      id_partition NUMBER(10,0) ,
      id_source_sess RAW(16) ,
      dt_metered DATE ,
      tx_ip_address VARCHAR2(15) ,
      PRIMARY KEY( id_message,id_ss,id_source_sess ));';
  END IF;
   
  SELECT count(*) INTO v_counter FROM all_objects WHERE object_type='TABLE' AND LOWER(object_name)='tt_tmpreconcilemessagetable_2';
  IF v_counter = 0 THEN
    EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE tt_tmpReconcileMessageTable_2
    ( id_message NUMBER(10,0) ,
      dt_completed DATE ,
      dt_assigned DATE ,
      b_root CHAR(1) ,
      id_ss NUMBER(10,0) ,
      id_svc NUMBER(10,0) ,
      id_partition NUMBER(10,0) ,
      id_source_sess RAW(16) ,
      dt_metered DATE ,
      tx_ip_address VARCHAR2(15) ,
      b_resubmit CHAR(1) ,
      PRIMARY KEY( id_message,id_ss,id_source_sess ));';
  END IF;
   
   v_dt_reconcile := metratime(1, 'RAMP') ;

   SELECT count(*) INTO v_suspended_txn_time  FROM mvm_global_params p WHERE p.param_name = 'suspended_txn_time';
   IF v_suspended_txn_time = 0 THEN
     v_suspended_txn_time := 1;
   ELSE
     SELECT CAST(param_value as NUMBER(10)) INTO v_suspended_txn_time
     FROM mvm_global_params p
     WHERE p.param_name = 'suspended_txn_time';
   END IF;

   BEGIN
      BEGIN
         UPDATE t_message
            SET dt_completed = v_WindowEnd
            WHERE 1 = 1
           AND dt_completed IS NULL
           AND dt_assigned <  v_dt_reconcile - v_suspended_txn_time/24
           AND id_pipeline IN ( SELECT t_pipeline.id_pipeline
                                FROM t_pipeline
                                  WHERE t_pipeline.b_online = '1'
                                          AND t_pipeline.b_paused = '0' );
         COMMIT;
      END;
   EXCEPTION
      WHEN OTHERS THEN
         
         BEGIN
            ROLLBACK;
         END;
   END;
   /**********************************************************************
    ** If Partitioning is not enabled, the value is always one... which is 
    ** what we want.
    ** If partitioning is enabled, we need to update to 
    ** the partition and ensure the svc data is moved to the new partition
    ** so we don't loose the read usage...
    ** AND
    ** Identify Service definition mapping to table
    **********************************************************************/
   SELECT current_id_partition
     INTO v_new_partition
     FROM t_archive_queue_partition ;
   INSERT INTO tt_ServiceMap
     ( id_svc, table_name )
     ( SELECT b.id_enum_data id_svc  ,
              a.nm_table_name table_name
       FROM t_service_def_log a
              JOIN t_enum_data b   ON a.nm_service_def = b.nm_enum_data );
   /**********************************************************************
    ** Identify messages and the sessions which we must Reconcile
    **********************************************************************/
   BEGIN
      INSERT INTO tt_tmpReconcileMessageTable
        ( id_message, dt_completed, dt_assigned, b_root, id_ss, id_svc,
          id_partition, id_source_sess, dt_metered, tx_ip_address )
        SELECT MAX(a.id_message) id_message  ,
               MAX(NVL(a.dt_completed, mtmaxdate())) dt_completed  ,
               MAX(NVL(a.dt_assigned, mtmaxdate())) dt_assigned  ,
               b.b_root ,
               MAX(b.id_ss) ,
               b.id_svc ,
               MAX(c.id_partition) ,
               c.id_source_sess ,
               MAX(a.dt_metered) ,
               MAX(a.tx_ip_address)
          FROM t_message a
                 JOIN t_session_set b   ON a.id_message = b.id_message
                 JOIN t_session c   ON b.id_ss = c.id_ss
                 LEFT JOIN t_acc_usage D   ON c.id_source_sess = D.tx_UID
                 LEFT JOIN t_session_state e   ON c.id_source_sess = e.id_sess
                 AND e.dt_end = mtmaxdate()
                 AND e.tx_state IN ( 'F','D' )

          WHERE 1 = 1
                  AND D.tx_UID IS NULL
                  AND e.id_sess IS NULL
                  AND NVL(a.dt_completed, MTMaxDate()) >= v_WindowBegin
          GROUP BY b.b_root,b.id_svc,c.id_source_sess
          ORDER BY id_message;
   END;
   /**********************************************************************
    ** Delete the non-maximum messages
    **********************************************************************/
   INSERT INTO tt_tmpReconcileMessageTable_2
     ( id_message, dt_completed, dt_assigned, b_root, id_ss, id_svc, id_partition,
       id_source_sess, dt_metered, tx_ip_address, b_resubmit )
     ( SELECT id_message ,
              dt_completed ,
              dt_assigned ,
              b_root ,
              id_ss ,
              id_svc ,
              id_partition ,
              id_source_sess ,
              dt_metered ,
              tx_ip_address ,
              1
       FROM tt_tmpReconcileMessageTable
         WHERE dt_completed BETWEEN v_WindowBegin AND v_WindowEnd );
   v_s_count := SQL%ROWCOUNT ;
   /**********************************************************************
    ** Capture the count we expect
    **********************************************************************/
   /*	IF v_SafeDate IS NOT NULL THEN
   		UPDATE tt_tmpReconcileMessageTable2 set b_resubmit = NULL where dt_completed < v_SafeDate;
   	END IF;
   	*/
   IF v_s_count = 0 THEN
   
   BEGIN
      BEGIN
         BEGIN
            INSERT INTO mvm_resubmit_runs
              ( resubmit_date, dt_started, dt_completed, dt_assigned, range_start_date,
                range_end_date, msg_count, ss_count, s_count )
                VALUES (v_dt_reconcile,v_dt_reconcile,v_dt_reconcile,v_dt_reconcile,v_WindowBegin,v_WindowEnd, 0, 0, 0 );
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('msg_count = 0, ss_count = 0, s_count = 0');
         END;
      EXCEPTION
         WHEN OTHERS THEN
            
            BEGIN
               ROLLBACK;
               DBMS_OUTPUT.PUT_LINE('msg_count = -4, ss_count = -4, s_count = -4');
            END;
      END;
      RETURN;
   END;
   END IF;
   v_start_tm := metratime(1, 'RAMP') ;
   /**********************************************************************
    ** Capture the count of new messages
    **********************************************************************/
   INSERT INTO tt_MessageIdTable
     ( id_message )
     ( SELECT DISTINCT id_message
       FROM tt_tmpReconcileMessageTable_2
         GROUP BY id_message );
   v_msg_count := SQL%ROWCOUNT ;
   /**********************************************************************
    ** Isolate the service types to allow us to minimize the number of 
    ** messages that are necessary to create.
    **********************************************************************/
   INSERT INTO tt_SessionSetMap
     ( id_ss )
     ( SELECT DISTINCT id_ss
       FROM tt_tmpReconcileMessageTable_2
         GROUP BY id_ss );
   v_ss_count := SQL%ROWCOUNT ;
   /**********************************************************************
    ** Grab the new ID blocks
    **********************************************************************/
   GetIdBlock(v_msg_count, 'id_dbqueuesch', v_idMessage) ;
   GetIdBlock(v_ss_count,  'id_dbqueuess',  v_id_run) ;
   /**********************************************************************
    ** Assign new SS values
    **********************************************************************/

      MERGE INTO tt_MessageIdTable M
      USING (WITH UpdateData AS
              ( SELECT id_message,-1 + ROW_NUMBER() OVER ( ORDER BY id_message DESC  ) row_num FROM tt_MessageIdTable  )
              (SELECT M.ROWID row_id, row_num + v_idMessage AS new_id_message FROM tt_MessageIdTable M
               JOIN UpdateData    ON M.id_message = UpdateData.id_message )) src
      ON ( M.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET new_id_message = src.new_id_message;
   /**********************************************************************
    ** Assign new SS values
    **********************************************************************/

      MERGE INTO tt_SessionSetMap ssm
      USING (WITH UpdateData AS
      (SELECT id_ss, -1 + ROW_NUMBER() OVER ( ORDER BY id_ss DESC  ) row_num FROM tt_SessionSetMap)
      (SELECT ssm.ROWID row_id, row_num + v_id_run AS new_id_ss FROM tt_SessionSetMap ssm
      JOIN UpdateData    ON ssm.id_ss = UpdateData.id_ss )) src
      ON ( ssm.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET new_id_ss = src.new_id_ss;
   /**********************************************************************
    ** To avoid using a cursor, we need to do a bit of work to capture the 
    ** count of sessions per session set...
    ** Update Session Count per session from our resubmit table
    **********************************************************************/

      MERGE INTO tt_SessionSetMap ssm
      USING (WITH UpdateData AS (SELECT id_ss, COUNT(id_source_sess) sess_cnt
                          FROM tt_tmpReconcileMessageTable_2 GROUP BY id_ss )
       (SELECT ssm.ROWID row_id, UpdateData.sess_cnt FROM tt_SessionSetMap ssm
        JOIN UpdateData    ON ssm.id_ss = UpdateData.id_ss )) src
      ON ( ssm.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET sess_cnt = src.sess_cnt;
   OPEN svc_tbl_cursor;
   FETCH svc_tbl_cursor INTO v_id_svc;
   WHILE svc_tbl_cursor%FOUND
   LOOP
      
      BEGIN
         /**************************************************** 
          ** GET THE SERVICE TABLE NAME AND 
          ** UPDATE THE PARTITION FOR THE ENTRIES 
          ** (entries with the correct id_source_sess)
          ****************************************************/
        SELECT count(*) INTO v_counter FROM tt_ServiceMap sm WHERE sm.id_svc = v_id_svc;
        IF v_counter > 0 THEN
         SELECT sm.table_name INTO v_tbl_name FROM tt_ServiceMap sm WHERE sm.id_svc = v_id_svc;
         v_statement := 'MERGE INTO ' || v_tbl_name || '
                USING   (
                        SELECT tb.rowid AS rid FROM ' || v_tbl_name || ' tb
                        INNER JOIN tt_tmpReconcileMessageTable_2 lst ON lst.id_source_sess = tb.id_source_sess
                        )
                ON      (' || v_tbl_name || '.rowid = rid)
                WHEN MATCHED THEN
                UPDATE SET     c__resubmit = 1';

         EXECUTE IMMEDIATE v_statement;
         END IF;
         FETCH svc_tbl_cursor INTO v_id_svc;
      END;
   END LOOP;
   CLOSE svc_tbl_cursor;

   /**********************************************************************
    ** Move the partition for the svc table
    **********************************************************************/
   INSERT INTO t_session
     ( id_ss, id_source_sess, id_partition )
     ( SELECT ssm.new_id_ss id_ss  ,
              rmt.id_source_sess id_source_sess  ,
              rmt.id_partition id_partition
       FROM tt_tmpReconcileMessageTable_2 rmt
              JOIN tt_SessionSetMap ssm   ON ssm.id_ss = rmt.id_ss );
   INSERT INTO t_session_set
     ( id_message, id_ss, id_svc, b_root, session_count, id_partition )
     ( SELECT DISTINCT mit.new_id_message id_message  ,
                       ssm.new_id_ss id_ss  ,
                       rmt.id_svc id_svc  ,
                       rmt.b_root b_root  ,
                       ssm.sess_cnt session_count  ,
                       rmt.id_partition id_partition
       FROM tt_tmpReconcileMessageTable_2 rmt
              JOIN tt_SessionSetMap ssm   ON ssm.id_ss = rmt.id_ss
              JOIN tt_MessageIdTable mit   ON mit.id_message = rmt.id_message );
   v_mtr_tm := metratime(1, 'RAMP') ;

        INSERT INTO t_message
        ( id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_TransactionID, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address, id_partition )
         WITH my_msgs AS ( SELECT DISTINCT id_message,tx_ip_address,id_partition,dt_metered
                            FROM tt_tmpReconcileMessageTable_2 rmt )
        ( SELECT mit.new_id_message id_message,
                 NULL id_route,
                 v_mtr_tm dt_crt,
                 rmt.dt_metered dt_metered,
                 NULL dt_assigned,
                 NULL id_listener,
                 NULL id_pipeline,
                 NULL dt_completed,
                 NULL id_feedback,
                 orig.tx_TransactionID tx_TransactionID  ,
                 orig.tx_sc_username tx_sc_username  ,
                 orig.tx_sc_password tx_sc_password  ,
                 orig.tx_sc_namespace tx_sc_namespace  ,
                 orig.tx_sc_serialized tx_sc_serialized  ,
                 rmt.tx_ip_address tx_ip_address  ,
                 rmt.id_partition id_partition
          FROM my_msgs rmt
                 JOIN tt_MessageIdTable mit   ON mit.id_message = rmt.id_message
                 JOIN t_message orig   ON orig.id_message = mit.id_message );
   v_dt_complete := metratime(1, 'RAMP') ;
   INSERT INTO mvm_resubmit_runs
     ( resubmit_date, dt_started, dt_completed, dt_assigned, range_start_date, range_end_date, msg_count, ss_count, s_count )
     VALUES (v_dt_reconcile,v_start_tm,v_dt_complete,v_mtr_tm,v_WindowBegin,v_WindowEnd, v_msg_count, v_ss_count, v_s_count );

      DBMS_OUTPUT.PUT_LINE('msg_count = ' || v_msg_count || ', ss_count = ' || v_ss_count ||', s_count = ' || v_s_count);
      COMMIT;

   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmpReconcileMessageTable ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmpReconcileMessageTable_2 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ServiceMap ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_SessionSetMap ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MessageIdTable ';
END;
/

ALTER FUNCTION addsecond COMPILE ;

CREATE PROCEDURE MTSP_GENERATE_CHARGES_QUOTING
(   v_id_interval  INT ,
    v_id_billgroup INT ,
    v_id_run       INT ,
    v_id_accounts VARCHAR2,
	v_id_poid VARCHAR2,
    v_id_batch VARCHAR2 ,
    v_n_batch_size INT ,
    v_run_date DATE ,
	v_is_group_sub INT,
	v_dt_start    DATE,
	v_dt_end      DATE,
    p_count OUT INT)
AS
  v_total_rcs  INT;
  v_total_flat INT;
  v_total_udrc INT;
  v_n_batches  INT;
  v_id_flat    INT;
  v_id_udrc    INT;
  v_id_message INT;
  v_id_ss      INT;
  v_tx_batch   VARCHAR2(256);
  v_id_nonrec  INT;
  v_total_nrcs INT;
  
BEGIN
  
   DELETE FROM TMP_RC_ACCOUNTS_FOR_RUN;
   INSERT INTO TMP_RC_ACCOUNTS_FOR_RUN ( ID_ACC )
        SELECT * FROM table(cast(dbo.CSVToInt(v_id_accounts) as  tab_id_instance));
		
   DELETE FROM TMP_RC_POS_FOR_RUN;
   INSERT INTO TMP_RC_POS_FOR_RUN ( ID_PO )
        SELECT * FROM table(cast(dbo.CSVToInt(v_id_poid) as  tab_id_instance));

   DELETE FROM TMP_RCS;
   DELETE FROM TMP_NRC;
   
   v_tx_batch := v_id_batch;

   -- prepare TMP_RCS
   INSERT INTO TMP_RCS
   (
      idSourceSess,
      c_RCActionType,
      c_RCIntervalStart,
      c_RCIntervalEnd,
      c_BillingIntervalStart,
      c_BillingIntervalEnd,
      c_RCIntervalSubscriptionStart,
      c_RCIntervalSubscriptionEnd,
      c_SubscriptionStart,
      c_SubscriptionEnd,
      c_Advance,
      c_ProrateOnSubscription,
      c_ProrateInstantly,
      c_ProrateOnUnsubscription,
      c_ProrationCycleLength,
      c__AccountID,
      c__PayingAccount,
      c__PriceableItemInstanceID,
      c__PriceableItemTemplateID,
      c__ProductOfferingID,
      c_BilledRateDate,
      c__SubscriptionID,
      c_payerstart,
      c_payerend,
      c_unitvaluestart,
      c_unitvalueend,
      c_unitvalue,
      c_RatingType
    )
      SELECT
        ID_SOURCE_SESS AS idSourceSess,
        c_RCActionType,
        c_RCIntervalStart,
        c_RCIntervalEnd,
        c_BillingIntervalStart,
        c_BillingIntervalEnd,
        c_RCIntervalSubscriptionStart,
        c_RCIntervalSubscriptionEnd,
        c_SubscriptionStart,
        c_SubscriptionEnd,
        c_Advance,
        c_ProrateOnSubscription,
        c_ProrateInstantly,
        c_ProrateOnUnsubscription,
        c_ProrationCycleLength,
        c_AccountID,
        c_PayingAccount,
        c_PriceableItemInstanceID,
        c_PriceableItemTemplateID,
        c_ProductOfferingID,
        c_BilledRateDate,
        c_SubscriptionID,
        c_payerstart,
        c_payerend,
        c_unitvaluestart,
        c_unitvalueend,
        c_unitvalue,
        c_ratingtype
        FROM
        ( SELECT SYS_GUID() AS ID_SOURCE_SESS,
          'Arrears' AS c_RCActionType,
          pci.dt_start AS c_RCIntervalStart,
          pci.dt_end AS c_RCIntervalEnd,
          ui.dt_start AS c_BillingIntervalStart,
          ui.dt_end AS c_BillingIntervalEnd,
          dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart) AS c_RCIntervalSubscriptionStart,
          dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd) AS c_RCIntervalSubscriptionEnd,
          rw.c_SubscriptionStart AS c_SubscriptionStart,
          rw.c_SubscriptionEnd AS c_SubscriptionEnd,
          case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance,
		  case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription,
		  case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly ,
		  case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription,
		  CASE
			WHEN rcr.b_fixed_proration_length = 'Y'
			THEN fxd.n_proration_length
			ELSE 0
		  END                           AS c_ProrationCycleLength ,
		  rw.c__accountid AS c_AccountID,
          rw.C__PAYINGACCOUNT AS c_PayingAccount,
          rw.c__priceableiteminstanceid AS c_PriceableItemInstanceID,
          rw.c__priceableitemtemplateid AS c_PriceableItemTemplateID,
          rw.c__productofferingid AS c_ProductOfferingID,
          pci.dt_end AS c_BilledRateDate,
          rw.c__subscriptionid AS c_SubscriptionID,
          rw.c_payerstart,
          rw.c_payerend,
          CASE
            WHEN rw.c_unitvaluestart < TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
            THEN TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
            ELSE rw.c_unitvaluestart
          END AS c_unitvaluestart,
          rw.c_unitvalueend,
          rw.c_unitvalue,
          rcr.n_rating_type AS c_RatingType
        /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
         INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
   /* interval overlaps with UDRC */
   /* rc overlaps with this subscription */
        FROM t_usage_interval ui
          LEFT JOIN TMP_RC_ACCOUNTS_FOR_RUN bgm ON 1 = 1
          JOIN t_recur_window rw ON bgm.id_acc = rw.C__PAYINGACCOUNT
			AND rw.c_payerstart < ui.dt_end  AND rw.c_payerend > ui.dt_start
          /* interval overlaps with payer */
		    AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start
          /* interval overlaps with cycle */
            AND rw.c_membershipstart < ui.dt_end AND rw.c_membershipend > ui.dt_start
          /* interval overlaps with membership */
		    AND rw.c_subscriptionstart < ui.dt_end AND rw.c_subscriptionend > ui.dt_start
          /* interval overlaps with subscription */
			AND rw.c_unitvaluestart < ui.dt_end AND rw.c_unitvalueend > ui.dt_start
		  JOIN TMP_RC_POS_FOR_RUN po on po.id_po = rw.c__ProductOfferingID
          JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
          JOIN t_usage_cycle ccl ON ccl.id_usage_cycle =
            CASE
                WHEN rcr.tx_cycle_mode = 'Fixed'
                    THEN rcr.id_usage_cycle
                WHEN rcr.tx_cycle_mode LIKE 'BCR%'
                    THEN ui.id_usage_cycle
                WHEN rcr.tx_cycle_mode = 'EBCR'
                    THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                ELSE NULL
            END
                      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
          JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
			  AND pci.dt_end BETWEEN ui.dt_start AND ui.dt_end
			  /* rc end falls in this interval */
			  AND pci.dt_end BETWEEN rw.c_payerstart AND rw.c_payerend
			  /* rc end goes to this payer */
			  AND rw.c_unitvaluestart < pci.dt_end AND rw.c_unitvalueend > pci.dt_start
			  /* rc overlaps with this UDRC */
			  AND rw.c_membershipstart < pci.dt_end AND rw.c_membershipend > pci.dt_start
			  /* rc overlaps with this membership */
			  AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start
			  /* rc overlaps with this cycle */
			  AND rw.c_SubscriptionStart < pci.dt_end AND rw.c_subscriptionend > pci.dt_start
          JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
          WHERE 1 = 1
          AND ui.id_interval = v_id_interval
          AND rcr.b_advance <> 'Y'
        UNION ALL
               
        SELECT
          SYS_GUID() AS ID_SOURCE_SESS,
          'Advance' AS c_RCActionType,
          pci.dt_start AS c_RCIntervalStart,
          pci.dt_end AS c_RCIntervalEnd,
          ui.dt_start AS c_BillingIntervalStart,
          ui.dt_end AS c_BillingIntervalEnd,
          CASE
              WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate
              THEN dbo.MTMaxOfTwoDates(AddSecond(c_cycleEffectiveDate), pci.dt_start)
              ELSE pci.dt_start
          END AS c_RCIntervalSubscriptionStart,
          dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd) AS c_RCIntervalSubscriptionEnd,
          rw.c_SubscriptionStart AS c_SubscriptionStart,
          rw.c_SubscriptionEnd AS c_SubscriptionEnd,
          case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance,
		  case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription,
		  case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly ,
		  case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription,
		  CASE
			WHEN rcr.b_fixed_proration_length = 'Y'
			THEN fxd.n_proration_length
			ELSE 0
		  END                           AS c_ProrationCycleLength ,
          rw.c__accountid AS c_AccountID,
		  rw.c__payingaccount AS c_PayingAccount,
          rw.c__priceableiteminstanceid AS c_PriceableItemInstanceID,
          rw.c__priceableitemtemplateid AS c_PriceableItemTemplateID,
          rw.c__productofferingid AS c_ProductOfferingID,
          pci.dt_start AS c_BilledRateDate,
          rw.c__subscriptionid AS c_SubscriptionID,
          rw.c_payerstart,
          rw.c_payerend,
          CASE
            WHEN rw.c_unitvaluestart < TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
            THEN TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
            ELSE rw.c_unitvaluestart
          END AS c_unitvaluestart,
          rw.c_unitvalueend,
          rw.c_unitvalue,
          rcr.n_rating_type AS c_RatingType
   /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
         INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
   /* next interval overlaps with UDRC */
   /* rc overlaps with this subscription */
          FROM t_usage_interval ui JOIN t_usage_interval nui ON ui.id_usage_cycle = nui.id_usage_cycle AND dbo.AddSecond(ui.dt_end) = nui.dt_start
              LEFT JOIN TMP_RC_ACCOUNTS_FOR_RUN bgm ON 1 = 1
              JOIN t_recur_window rw ON bgm.id_acc = rw.c__payingaccount
              AND rw.c_payerstart < nui.dt_end AND rw.c_payerend > nui.dt_start
              /* next interval overlaps with payer */
              AND rw.c_cycleeffectivestart < nui.dt_end AND rw.c_cycleeffectiveend > nui.dt_start
              /* next interval overlaps with cycle */
              AND rw.c_membershipstart < nui.dt_end AND rw.c_membershipend > nui.dt_start
              /* next interval overlaps with membership */
              AND rw.c_subscriptionstart < nui.dt_end AND rw.c_subscriptionend > nui.dt_start
              /* next interval overlaps with subscription */
              AND rw.c_unitvaluestart < nui.dt_end AND rw.c_unitvalueend > nui.dt_start
              JOIN TMP_RC_POS_FOR_RUN po on po.id_po = rw.c__ProductOfferingID
			  JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
              JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE
                                            WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode LIKE 'BCR%' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                                            ELSE NULL
											END
              JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
              AND pci.dt_start BETWEEN nui.dt_start AND nui.dt_end
              /* rc start falls in this interval */
              AND pci.dt_start BETWEEN rw.c_payerstart AND rw.c_payerend
              /* rc start goes to this payer */
              AND rw.c_unitvaluestart < pci.dt_end AND rw.c_unitvalueend > pci.dt_start
              /* rc overlaps with this UDRC */
              AND rw.c_membershipstart < pci.dt_end AND rw.c_membershipend > pci.dt_start
              /* rc overlaps with this membership */
              AND rw.c_cycleeffectiveend > pci.dt_start
              /* rc overlaps with this cycle */
              AND rw.c_subscriptionend > pci.dt_start
              JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
          WHERE 1 = 1
              AND ui.id_interval = v_id_interval
              AND rcr.b_advance = 'Y'
        )  A;

   SELECT COUNT(1) INTO v_total_rcs FROM TMP_RCS ;
   
   -- prepare TMP_NRCS
   IF v_is_group_sub > 0 THEN
   BEGIN
   INSERT INTO TMP_NRC
       (
            id_source_sess,
            c_NRCEventType,
            c_NRCIntervalStart,
            c_NRCIntervalEnd,
            c_NRCIntervalSubscriptionStart,
            c_NRCIntervalSubscriptionEnd,
            c__AccountID,
            c__PriceableItemInstanceID,
            c__PriceableItemTemplateID,
            c__ProductOfferingID,
            c__SubscriptionID,
            c__IntervalID,
            c__Resubmit
       )
            SELECT SYS_GUID() AS id_source_sess,
              nrc.n_event_type AS c_NRCEventType,
              v_dt_start AS c_NRCIntervalStart,
              v_dt_end AS c_NRCIntervalEnd,
              mem.vt_start AS c_NRCIntervalSubscriptionStart,
              mem.vt_end AS c_NRCIntervalSubscriptionEnd,
              mem.id_acc AS c__AccountID,
              plm.id_pi_instance AS c__PriceableItemInstanceID,
              plm.id_pi_template AS c__PriceableItemTemplateID,
              sub.id_po AS c__ProductOfferingID,
              sub.id_sub AS c__SubscriptionID,
              v_id_interval AS c__IntervalID,
              '0' AS c__Resubmit
            FROM t_sub sub
                  JOIN t_gsubmember mem ON mem.id_group = sub.id_group
                  JOIN TMP_RC_ACCOUNTS_FOR_RUN acc ON acc.id_acc = mem.id_acc
                  JOIN TMP_RC_POS_FOR_RUN po ON po.id_po = sub.id_po
                  JOIN t_po ON sub.id_po = t_po.id_po
                  JOIN t_pl_map plm ON sub.id_po = plm.id_po AND plm.id_paramtable IS NULL
                  JOIN t_base_props bp ON bp.id_prop = plm.id_pi_instance AND bp.n_kind = 30
                  JOIN t_nonrecur nrc ON nrc.id_prop = bp.id_prop AND nrc.n_event_type = 1
        ;

   END;
   ELSE
   BEGIN

       INSERT INTO TMP_NRC
       (
            id_source_sess,
            c_NRCEventType,
            c_NRCIntervalStart,
            c_NRCIntervalEnd,
            c_NRCIntervalSubscriptionStart,
            c_NRCIntervalSubscriptionEnd,
            c__AccountID,
            c__PriceableItemInstanceID,
            c__PriceableItemTemplateID,
            c__ProductOfferingID,
            c__SubscriptionID,
            c__IntervalID,
            c__Resubmit
       )
            SELECT SYS_GUID() AS id_source_sess,
              nrc.n_event_type AS c_NRCEventType,
              v_dt_start AS c_NRCIntervalStart,
              v_dt_end AS c_NRCIntervalEnd,
              sub.vt_start AS c_NRCIntervalSubscriptionStart,
              sub.vt_end AS c_NRCIntervalSubscriptionEnd,
              sub.id_acc AS c__AccountID,
              plm.id_pi_instance AS c__PriceableItemInstanceID,
              plm.id_pi_template AS c__PriceableItemTemplateID,
              sub.id_po AS c__ProductOfferingID,
              sub.id_sub AS c__SubscriptionID,
              v_id_interval AS c__IntervalID,
              '0' AS c__Resubmit
            FROM t_sub sub
                  JOIN TMP_RC_ACCOUNTS_FOR_RUN acc ON acc.id_acc = sub.id_acc
                  JOIN TMP_RC_POS_FOR_RUN po ON po.id_po = sub.id_po
                  JOIN t_po ON sub.id_po = t_po.id_po
                  JOIN t_pl_map plm ON sub.id_po = plm.id_po AND plm.id_paramtable IS NULL
                  JOIN t_base_props bp ON bp.id_prop = plm.id_pi_instance AND bp.n_kind = 30
                  JOIN t_nonrecur nrc ON nrc.id_prop = bp.id_prop AND nrc.n_event_type = 1
        ;
  END;
  END IF;

   SELECT COUNT(1) INTO v_total_nrcs FROM TMP_NRC ;
  
   IF v_total_rcs > 0 THEN
   BEGIN
      SELECT COUNT(1) INTO v_total_flat FROM TMP_RCS WHERE c_unitvalue IS NULL;

      SELECT COUNT(1) INTO v_total_udrc FROM TMP_RCS WHERE c_unitvalue IS NOT NULL;
      
      IF v_total_flat > 0 THEN
      BEGIN
         SELECT id_enum_data
           INTO v_id_flat
           FROM t_enum_data ted
            WHERE ted.nm_enum_data = 'metratech.com/flatrecurringcharge';

         v_n_batches := (v_total_flat / v_n_batch_size) + 1;

         GetIdBlock(v_n_batches,'id_dbqueuesch',v_id_message);
         GetIdBlock(v_n_batches,'id_dbqueuess',v_id_ss);

         INSERT INTO t_session
           ( id_ss, id_source_sess )
           SELECT v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_ss,
                  idSourceSess
             FROM TMP_RCS
              WHERE c_unitvalue IS NULL;

         INSERT INTO t_session_set
           ( id_message, id_ss, id_svc, b_root, session_count )
           SELECT id_message,
                  id_ss,
                  id_svc,
                  b_root,
                  COUNT(1) session_count
             FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_message,
                           v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_ss,
                           v_id_flat id_svc,
                           1 b_root
                    FROM TMP_RCS
                       WHERE c_unitvalue IS NULL ) a
             GROUP BY id_message,id_ss,id_svc,b_root;

         INSERT INTO t_svc_FlatRecurringCharge
            (
              id_source_sess ,
              id_parent_source_sess ,
              id_external ,
              c_RCActionType ,
              c_RCIntervalStart ,
              c_RCIntervalEnd ,
              c_BillingIntervalStart ,
              c_BillingIntervalEnd ,
              c_RCIntervalSubscriptionStart ,
              c_RCIntervalSubscriptionEnd ,
              c_SubscriptionStart ,
              c_SubscriptionEnd ,
              c_Advance ,
              c_ProrateOnSubscription ,
              c_ProrateInstantly ,
              c_ProrateOnUnsubscription ,
              c_ProrationCycleLength ,
              c__AccountID ,
              c__PayingAccount ,
              c__PriceableItemInstanceID ,
              c__PriceableItemTemplateID ,
              c__ProductOfferingID ,
              c_BilledRateDate ,
              c__SubscriptionID ,
              c__IntervalID ,
              c__Resubmit ,
              c__TransactionCookie ,
              c__CollectionID
            )
            SELECT  idSourceSess,
                    NULL AS id_parent_source_sess,
                    NULL AS id_external,
                    c_RCActionType,
                    c_RCIntervalStart,
                    c_RCIntervalEnd,
                    c_BillingIntervalStart,
                    c_BillingIntervalEnd,
                    c_RCIntervalSubscriptionStart,
                    c_RCIntervalSubscriptionEnd,
                    c_SubscriptionStart,
                    c_SubscriptionEnd,
                    c_Advance,
                    c_ProrateOnSubscription,
                    c_ProrateInstantly,
                    c_ProrateOnUnsubscription,
                    c_ProrationCycleLength,
                    c__AccountID,
                    c__PayingAccount,
                    c__PriceableItemInstanceID,
                    c__PriceableItemTemplateID,
                    c__ProductOfferingID,
                    c_BilledRateDate,
                    c__SubscriptionID,
                    v_id_interval AS c__IntervalID,
                    '0' AS c__Resubmit,
                    NULL AS c__TransactionCookie,
                    v_tx_batch AS c__CollectionID
             FROM TMP_RCS
                WHERE c_unitvalue IS NULL ;

         INSERT INTO t_message
           ( id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_TransactionID, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address )
           SELECT id_message,
                  NULL,
                  v_run_date,
                  v_run_date,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  '127.0.0.1'
             FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_message
                    FROM TMP_RCS
                       WHERE c_unitvalue IS NULL ) a
             GROUP BY a.id_message;

      END;
      END IF;

      /*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting Flat RCs');*/
      IF v_total_udrc > 0 THEN
      BEGIN
         SELECT id_enum_data
           INTO v_id_udrc
           FROM t_enum_data ted
            WHERE ted.nm_enum_data = 'metratech.com/udrecurringcharge';

         v_n_batches := (v_total_udrc / v_n_batch_size) + 1;

         GetIdBlock(v_n_batches, 'id_dbqueuesch', v_id_message);
         GetIdBlock(v_n_batches, 'id_dbqueuess', v_id_ss);

         INSERT INTO t_session
           ( id_ss, id_source_sess )
           SELECT v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_ss,
                  idSourceSess id_source_sess
             FROM TMP_RCS
              WHERE c_unitvalue IS NOT NULL;

         INSERT INTO t_session_set
           ( id_message, id_ss, id_svc, b_root, session_count )
           SELECT id_message,
                  id_ss,
                  id_svc,
                  b_root,
                  COUNT(1) session_count
             FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_message,
                           v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_ss,
                           v_id_udrc id_svc,
                           1 b_root
                    FROM TMP_RCS
                       WHERE c_unitvalue IS NOT NULL ) a
             GROUP BY id_message,id_ss,id_svc,b_root;

         INSERT INTO t_svc_UDRecurringCharge
           (
          id_source_sess,
          id_parent_source_sess,
          id_external,
          c_RCActionType,
          c_RCIntervalStart,
          c_RCIntervalEnd,
          c_BillingIntervalStart,
          c_BillingIntervalEnd ,
          c_RCIntervalSubscriptionStart ,
          c_RCIntervalSubscriptionEnd ,
          c_SubscriptionStart ,
          c_SubscriptionEnd ,
          c_Advance ,
          c_ProrateOnSubscription ,
          /*    c_ProrateInstantly , */
          c_ProrateOnUnsubscription ,
          c_ProrationCycleLength ,
          c__AccountID ,
          c__PayingAccount ,
          c__PriceableItemInstanceID ,
          c__PriceableItemTemplateID ,
          c__ProductOfferingID ,
          c_BilledRateDate ,
          c__SubscriptionID ,
          c__IntervalID ,
          c__Resubmit ,
          c__TransactionCookie ,
          c__CollectionID ,
          c_unitvaluestart ,
          c_unitvalueend ,
          c_unitvalue ,
          c_ratingtype
        )
         SELECT
            idSourceSess,
            NULL AS id_parent_source_sess,
            NULL AS id_external,
            c_RCActionType,
            c_RCIntervalStart,
            c_RCIntervalEnd,
            c_BillingIntervalStart,
            c_BillingIntervalEnd,
            c_RCIntervalSubscriptionStart,
            c_RCIntervalSubscriptionEnd,
            c_SubscriptionStart,
            c_SubscriptionEnd,
            c_Advance,
            c_ProrateOnSubscription,
            /*    ,c_ProrateInstantly */
            c_ProrateOnUnsubscription,
            c_ProrationCycleLength,
            c__AccountID,
            c__PayingAccount,
            c__PriceableItemInstanceID,
            c__PriceableItemTemplateID,
            c__ProductOfferingID,
            c_BilledRateDate,
            c__SubscriptionID,
            v_id_interval AS c__IntervalID,
            '0' AS c__Resubmit,
            NULL AS c__TransactionCookie,
            v_tx_batch c__CollectionID,
            c_unitvaluestart,
            c_unitvalueend,
            c_unitvalue,
            c_ratingtype
        FROM TMP_RCS
        WHERE c_unitvalue IS NOT NULL ;

        INSERT INTO t_message
           ( id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_TransactionID, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address )
           SELECT id_message,
                  NULL,
                  v_run_date,
                  v_run_date,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  '127.0.0.1'
             FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_message
                    FROM TMP_RCS
                       WHERE c_unitvalue IS NOT NULL ) a
             GROUP BY id_message;

      END;
      END IF;

   END;
   END IF;
   
   IF v_total_nrcs > 0 THEN
   BEGIN
   SELECT id_enum_data
     INTO v_id_nonrec
     FROM t_enum_data ted
      WHERE ted.nm_enum_data = 'metratech.com/nonrecurringcharge';

   v_n_batches := (v_total_nrcs / v_n_batch_size) + 1;

   GetIdBlock(v_n_batches, 'id_dbqueuesch', v_id_message);

   GetIdBlock(v_n_batches, 'id_dbqueuess', v_id_ss);

   INSERT INTO t_session
     ( id_ss, id_source_sess )
     SELECT v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_ss,
            id_source_sess
       FROM tmp_nrc ;

   INSERT INTO t_session_set
     ( id_message, id_ss, id_svc, b_root, session_count )
     SELECT id_message,
            id_ss,
            v_id_nonrec,
            b_root,
            COUNT(1) session_count
       FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_message,
                     v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_ss,
                     1 b_root
              FROM tmp_nrc  ) a
       GROUP BY id_message,id_ss,b_root;

   INSERT INTO t_svc_nonrecurringcharge
     (  id_source_sess,
        id_parent_source_sess,
        id_external,
        c_NRCEventType,
        c_NRCIntervalStart,
        c_NRCIntervalEnd,
        c_NRCIntervalSubscriptionStart,
        c_NRCIntervalSubscriptionEnd,
        c__AccountID,
        c__PriceableItemInstanceID,
        c__PriceableItemTemplateID,
        c__ProductOfferingID,
        c__SubscriptionID,
        c__IntervalID,
        c__Resubmit,
        c__TransactionCookie,
        c__CollectionID )
     ( SELECT
          id_source_sess,
          NULL id_parent_source_sess,
          NULL id_external,
          c_NRCEventType,
          c_NRCIntervalStart,
          c_NRCIntervalEnd,
          c_NRCIntervalSubscriptionStart,
          c_NRCIntervalSubscriptionEnd,
          c__AccountID,
          c__PriceableItemInstanceID,
          c__PriceableItemTemplateID,
          c__ProductOfferingID,
          c__SubscriptionID,
          c__IntervalID,
          c__Resubmit,
          NULL as c__TransactionCookie,
          v_tx_batch as c__CollectionID
       FROM tmp_nrc  );
	   
	INSERT INTO t_message
     ( id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_TransactionID, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address )
     SELECT id_message,
            NULL,
            v_run_date,
            v_run_date,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            '127.0.0.1'
       FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_message
              FROM tmp_nrc  ) a
       GROUP BY id_message;
	   
    DELETE FROM TMP_NRC;
   END;
   END IF;

   /*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting UDRC RCs');*/
   p_count := v_total_rcs + v_total_nrcs;
   /*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Info', 'Finished submitting RCs, count: ' + CAST(@total_rcs AS VARCHAR));*/
END;
/

CREATE OR REPLACE PROCEDURE MTSP_GENERATE_ST_NRCS_QUOTING
(
  v_dt_start    DATE,
  v_dt_end      DATE,
  v_id_accounts VARCHAR2,
  v_id_poid VARCHAR2,
  v_id_interval INT,
  v_id_batch    VARCHAR2,
  v_n_batch_size INT,
  v_run_date    DATE,
  v_is_group_sub INT,
  p_count OUT INT
)
AS
   v_id_nonrec  INT;
   v_n_batches  INT;
   v_total_nrcs INT;
   v_id_message INT;
   v_id_ss      INT;
   v_tx_batch   VARCHAR2(256);
BEGIN

   DELETE FROM TMP_NRC_ACCOUNTS_FOR_RUN;
   INSERT INTO TMP_NRC_ACCOUNTS_FOR_RUN ( ID_ACC )
        SELECT * FROM table(cast(dbo.CSVToInt(v_id_accounts) as  tab_id_instance));
        
   DELETE FROM TMP_NRC_POS_FOR_RUN;
   INSERT INTO TMP_NRC_POS_FOR_RUN ( ID_PO )
        SELECT * FROM table(cast(dbo.CSVToInt(v_id_poid) as  tab_id_instance));

   DELETE FROM TMP_NRC;

   v_tx_batch := v_id_batch;

   IF v_is_group_sub > 0 THEN
   BEGIN
   INSERT INTO TMP_NRC
       (
            id_source_sess,
            c_NRCEventType,
            c_NRCIntervalStart,
            c_NRCIntervalEnd,
            c_NRCIntervalSubscriptionStart,
            c_NRCIntervalSubscriptionEnd,
            c__AccountID,
            c__PriceableItemInstanceID,
            c__PriceableItemTemplateID,
            c__ProductOfferingID,
            c__SubscriptionID,
            c__IntervalID,
            c__Resubmit
       )
            SELECT SYS_GUID() AS id_source_sess,
              nrc.n_event_type AS c_NRCEventType,
              v_dt_start AS c_NRCIntervalStart,
              v_dt_end AS c_NRCIntervalEnd,
              mem.vt_start AS c_NRCIntervalSubscriptionStart,
              mem.vt_end AS c_NRCIntervalSubscriptionEnd,
              mem.id_acc AS c__AccountID,
              plm.id_pi_instance AS c__PriceableItemInstanceID,
              plm.id_pi_template AS c__PriceableItemTemplateID,
              sub.id_po AS c__ProductOfferingID,
              sub.id_sub AS c__SubscriptionID,
              v_id_interval AS c__IntervalID,
              '0' AS c__Resubmit
            FROM t_sub sub
                  JOIN t_gsubmember mem ON mem.id_group = sub.id_group
                  JOIN TMP_NRC_ACCOUNTS_FOR_RUN acc ON acc.id_acc = mem.id_acc
                  JOIN TMP_NRC_POS_FOR_RUN po ON po.id_po = sub.id_po
                  JOIN t_po ON sub.id_po = t_po.id_po
                  JOIN t_pl_map plm ON sub.id_po = plm.id_po AND plm.id_paramtable IS NULL
                  JOIN t_base_props bp ON bp.id_prop = plm.id_pi_instance AND bp.n_kind = 30
                  JOIN t_nonrecur nrc ON nrc.id_prop = bp.id_prop AND nrc.n_event_type = 1
            WHERE sub.vt_start >= v_dt_start
                  AND sub.vt_start < v_dt_end
        ;

   END;
   ELSE
   BEGIN

       INSERT INTO TMP_NRC
       (
            id_source_sess,
            c_NRCEventType,
            c_NRCIntervalStart,
            c_NRCIntervalEnd,
            c_NRCIntervalSubscriptionStart,
            c_NRCIntervalSubscriptionEnd,
            c__AccountID,
            c__PriceableItemInstanceID,
            c__PriceableItemTemplateID,
            c__ProductOfferingID,
            c__SubscriptionID,
            c__IntervalID,
            c__Resubmit
       )
            SELECT SYS_GUID() AS id_source_sess,
              nrc.n_event_type AS c_NRCEventType,
              v_dt_start AS c_NRCIntervalStart,
              v_dt_end AS c_NRCIntervalEnd,
              sub.vt_start AS c_NRCIntervalSubscriptionStart,
              sub.vt_end AS c_NRCIntervalSubscriptionEnd,
              sub.id_acc AS c__AccountID,
              plm.id_pi_instance AS c__PriceableItemInstanceID,
              plm.id_pi_template AS c__PriceableItemTemplateID,
              sub.id_po AS c__ProductOfferingID,
              sub.id_sub AS c__SubscriptionID,
              v_id_interval AS c__IntervalID,
              '0' AS c__Resubmit
            FROM t_sub sub
                  JOIN TMP_NRC_ACCOUNTS_FOR_RUN acc ON acc.id_acc = sub.id_acc
                  JOIN TMP_NRC_POS_FOR_RUN po ON po.id_po = sub.id_po
                  JOIN t_po ON sub.id_po = t_po.id_po
                  JOIN t_pl_map plm ON sub.id_po = plm.id_po AND plm.id_paramtable IS NULL
                  JOIN t_base_props bp ON bp.id_prop = plm.id_pi_instance AND bp.n_kind = 30
                  JOIN t_nonrecur nrc ON nrc.id_prop = bp.id_prop AND nrc.n_event_type = 1
            WHERE sub.vt_start >= v_dt_start
                  AND sub.vt_start < v_dt_end
        ;
  END;
  END IF;

   SELECT COUNT(*)
     INTO v_total_nrcs
     FROM TMP_NRC ;

   SELECT id_enum_data
     INTO v_id_nonrec
     FROM t_enum_data ted
      WHERE ted.nm_enum_data = 'metratech.com/nonrecurringcharge';

   v_n_batches := (v_total_nrcs / v_n_batch_size) + 1;

   GetIdBlock(v_n_batches, 'id_dbqueuesch', v_id_message);

   GetIdBlock(v_n_batches, 'id_dbqueuess', v_id_ss);

   INSERT INTO t_session
     ( id_ss, id_source_sess )
     SELECT v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_ss,
            id_source_sess
       FROM tmp_nrc ;

   INSERT INTO t_session_set
     ( id_message, id_ss, id_svc, b_root, session_count )
     SELECT id_message,
            id_ss,
            v_id_nonrec,
            b_root,
            COUNT(1) session_count
       FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_message,
                     v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_ss,
                     1 b_root
              FROM tmp_nrc  ) a
       GROUP BY id_message,id_ss,b_root;

   INSERT INTO t_svc_nonrecurringcharge
     (  id_source_sess,
        id_parent_source_sess,
        id_external,
        c_NRCEventType,
        c_NRCIntervalStart,
        c_NRCIntervalEnd,
        c_NRCIntervalSubscriptionStart,
        c_NRCIntervalSubscriptionEnd,
        c__AccountID,
        c__PriceableItemInstanceID,
        c__PriceableItemTemplateID,
        c__ProductOfferingID,
        c__SubscriptionID,
        c__IntervalID,
        c__Resubmit,
        c__TransactionCookie,
        c__CollectionID )
     ( SELECT
          id_source_sess,
          NULL id_parent_source_sess,
          NULL id_external,
          c_NRCEventType,
          c_NRCIntervalStart,
          c_NRCIntervalEnd,
          c_NRCIntervalSubscriptionStart,
          c_NRCIntervalSubscriptionEnd,
          c__AccountID,
          c__PriceableItemInstanceID,
          c__PriceableItemTemplateID,
          c__ProductOfferingID,
          c__SubscriptionID,
          c__IntervalID,
          c__Resubmit,
          NULL as c__TransactionCookie,
          v_tx_batch as c__CollectionID
       FROM tmp_nrc  );
	   
	INSERT INTO t_message
     ( id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_TransactionID, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address )
     SELECT id_message,
            NULL,
            v_run_date,
            v_run_date,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            '127.0.0.1'
       FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_message
              FROM tmp_nrc  ) a
       GROUP BY id_message;
	   
    DELETE FROM TMP_NRC;

   p_count := v_total_nrcs;

END;
/

CREATE OR REPLACE PROCEDURE MeterCreditFromRecurWindow (currentDate DATE)
AS
    enabled varchar2(10);
    v_newSubStart DATE;
    v_newSubEnd   DATE;
    v_curSubStart DATE;
    v_curSubEnd   DATE;
    v_rcActionForEndDateUpdate varchar2(20);
    /* Borders of updated Sub.End range will stand for internal v_subscriptionStart and v_subscriptionEnd to charge this range. */
    v_subscriptionStart        DATE;
    v_subscriptionEnd          DATE;
    v_isEndDateUpdated         CHAR(1 BYTE) := '0';
    v_rcActionForEndDateUpdate2 varchar2(20);
    /* Borders of updated Sub.Start range will stand for internal v_subscriptionStart2 and v_subscriptionEnd2 to charge this range. */
    v_subscriptionStart2        DATE;
    v_subscriptionEnd2          DATE;
    v_isStartDateUpdated        CHAR(1 BYTE) := '0';
BEGIN
  SELECT value INTO enabled FROM t_db_values WHERE parameter = N'InstantRc';
  IF (enabled LIKE 'false') THEN RETURN; END IF;

  /* Assuming only 1 subscription can be changed at a time */
  BEGIN
    SELECT new_sub.vt_start, new_sub.vt_end, current_sub.vt_start, current_sub.vt_end
    INTO v_newSubStart,    v_newSubEnd,    v_curSubStart,        v_curSubEnd
    FROM TMP_NEWRW rw
        INNER JOIN t_sub_history new_sub ON new_sub.id_acc = rw.c__AccountID
            AND new_sub.id_sub = rw.c__SubscriptionID
            AND new_sub.tt_end = dbo.MTMaxDate()
        INNER JOIN t_sub_history current_sub ON current_sub.id_acc = rw.c__AccountID
            AND current_sub.id_sub = rw.c__SubscriptionID
            AND current_sub.tt_end = dbo.SubtractSecond(new_sub.tt_start)
    /* Work with RC only. Exclude UDRC. */
    WHERE rw.c_UnitValue IS NULL AND ROWNUM <= 1; /* Select only 1 PI*/
  EXCEPTION
    /* It is a new subscription or UDRC - nothing to recharge */
    WHEN NO_DATA_FOUND THEN
      RETURN;
  END;

  IF (v_newSubEnd <> v_curSubEnd) THEN
      /* TODO: Run only 1-st query if condition is true */
      v_isEndDateUpdated := '1';

      SELECT dbo.MTMinOfTwoDates(v_newSubEnd, v_curSubEnd),
             dbo.MTMaxOfTwoDates(v_newSubEnd, v_curSubEnd),
             CASE
                  WHEN v_newSubEnd > v_curSubEnd THEN
                       'Debit'
                  ELSE 'Credit'
             END
      INTO v_subscriptionStart, v_subscriptionEnd, v_rcActionForEndDateUpdate FROM DUAL;
      /* Sub. start date has 23:59:59 time. We need next day and 00:00:00 time for the start date */
      SELECT dbo.AddSecond(v_subscriptionStart) INTO v_subscriptionStart FROM DUAL;
  END IF;

  IF (v_newSubStart <> v_curSubStart) THEN
      /* TODO: Run only 2-nd query if condition is true */
      v_isStartDateUpdated := '1';

      SELECT dbo.MTMinOfTwoDates(v_newSubStart, v_curSubStart),
             dbo.MTMaxOfTwoDates(v_newSubStart, v_curSubStart),
             CASE
                  WHEN v_newSubStart < v_curSubStart THEN
                       'InitialDebit'
                  ELSE 'InitialCredit'
             END
      INTO v_subscriptionStart2, v_subscriptionEnd2, v_rcActionForEndDateUpdate2 FROM DUAL;
      /* Sub. end date has 00:00:00 time. We need previous day and 23:59:59 time for the end date */
      SELECT dbo.SubtractSecond(v_subscriptionEnd2) INTO v_subscriptionEnd2 FROM DUAL;
  END IF;

  INSERT INTO tmp_rc
  SELECT
         /* First, credit or debit the difference in the ending of the subscription.  If the new one is later, this will be a debit, otherwise a credit.
         * TODO: Remove this comment:"There's a weird exception when this is (a) an arrears charge, (b) the old subscription end was after the pci end date, and (c) the new sub end is inside the pci end date." */
         v_rcActionForEndDateUpdate                                                                 AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, v_subscriptionStart)                                     AS c_RCIntervalSubscriptionStart,
         dbo.mtminoftwodates(pci.dt_end, v_subscriptionEnd)                                         AS c_RCIntervalSubscriptionEnd,
         v_subscriptionStart                                                                        AS c_SubscriptionStart,
         v_subscriptionEnd                                                                          AS c_SubscriptionEnd,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,
         CASE WHEN rcr.b_prorate_on_activate = 'Y' THEN '1' ELSE '0' END                            AS c_ProrateOnSubscription,
         CASE WHEN rcr.b_prorate_instantly = 'Y' THEN '1' ELSE '0' END                              AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         rcr.n_rating_type                                                                          AS c_RatingType,
         CASE WHEN rcr.b_prorate_on_deactivate = 'Y' THEN '1' ELSE '0' END                          AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__payingaccount                                                                        AS c__PayingAccount,
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         dbo.MTMinOfTwoDates(pci.dt_end, v_subscriptionStart)                                       AS c_BilledRateDate,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         currentui.id_interval                                                                      AS c__IntervalID,
         SYS_GUID()                                                                                 AS id_source_sess
  FROM   t_usage_interval ui
         INNER JOIN TMP_NEWRW rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              /* rw.c_cycleeffectivestart EQUAL TO v_subscriptionStart , rw.c_cycleeffectiveend EQUAL TO v_subscriptionEnd */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND v_subscriptionStart      < ui.dt_end AND v_subscriptionEnd      > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
         INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
         INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, v_subscriptionStart, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      (rcr.b_advance = 'Y' AND pci.dt_start BETWEEN ui.dt_start AND ui.dt_end) /* If this is in advance, check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              /* rw.c_cycleeffectivestart EQUAL TO v_subscriptionStart , rw.c_cycleeffectiveend EQUAL TO v_subscriptionEnd */
              AND v_subscriptionStart      < pci.dt_end AND v_subscriptionEnd      > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON currentDate BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
  WHERE
         ui.dt_start < currentDate
         AND rw.c__IsAllowGenChargeByTrigger = 1
         AND v_isEndDateUpdated = '1'

  UNION ALL

  SELECT
         /* Now, credit or debit the difference in the start of the subscription.  If the new one is earlier, this will be a debit, otherwise a credit*/
         v_rcActionForEndDateUpdate2                                                                AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, v_subscriptionStart2)                                    AS c_RCIntervalSubscriptionStart,
         /* If new Subscription Start somewhere in future, after EOP - always use End of RC cycle */
         CASE
              WHEN ui.dt_end <= v_subscriptionEnd2 THEN pci.dt_end
              ELSE dbo.mtminoftwodates(pci.dt_end, v_subscriptionEnd2)
         END                                                                                        AS c_RCIntervalSubscriptionEnd,
         v_subscriptionStart2                                                                       AS c_SubscriptionStart,
         v_subscriptionEnd2                                                                         AS c_SubscriptionEnd,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,
         CASE WHEN rcr.b_prorate_on_activate = 'Y' THEN '1' ELSE '0' END                            AS c_ProrateOnSubscription,
         CASE WHEN rcr.b_prorate_instantly = 'Y' THEN '1' ELSE '0' END                              AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         rcr.n_rating_type                                                                          AS c_RatingType,
         CASE WHEN rcr.b_prorate_on_deactivate = 'Y' THEN '1' ELSE '0' END                          AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__payingaccount                                                                        AS c__PayingAccount,
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         dbo.MTMinOfTwoDates(pci.dt_end, v_subscriptionStart2)                                      AS c_BilledRateDate,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         currentui.id_interval                                                                      AS c__IntervalID,
         SYS_GUID()                                                                                 AS id_source_sess
  FROM   t_usage_interval ui
         INNER JOIN TMP_NEWRW rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              /* rw.c_cycleeffectivestart EQUAL TO v_subscriptionStart , rw.c_cycleeffectiveend EQUAL TO v_subscriptionEnd */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND v_subscriptionStart2     < ui.dt_end AND v_subscriptionEnd2     > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
         INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
         INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, v_subscriptionStart2, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      (rcr.b_advance = 'Y' AND pci.dt_start BETWEEN ui.dt_start AND ui.dt_end) /* If this is in advance, check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              /* rw.c_cycleeffectivestart EQUAL TO v_subscriptionStart , rw.c_cycleeffectiveend EQUAL TO v_subscriptionEnd */
              AND v_subscriptionStart2     < pci.dt_end AND v_subscriptionEnd2     > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON currentDate BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
  WHERE
         ui.dt_start < currentDate
         AND rw.c__IsAllowGenChargeByTrigger = 1
         AND v_isStartDateUpdated = '1';


  /* Remove extra charges for RCs with No Proration (CORE-6789) */
  IF (v_isEndDateUpdated = 1) THEN
    /* PIs, that starts outside of End Date Update range, should not be handled here */
    DELETE FROM tmp_rc WHERE c_ProrateOnUnsubscription = '0' AND c_RCIntervalStart < v_subscriptionStart;

    /* Turn On "Prorate On Subscription" if this is the 1-st RC Cycle */
    UPDATE tmp_rc
    SET c_ProrateOnSubscription = '1'
    WHERE c_ProrateOnUnsubscription = '1' AND v_newSubStart BETWEEN c_RCIntervalStart AND c_RCIntervalEnd;
  END IF;
  IF (v_isStartDateUpdated = 1) THEN
    /* PIs, that ends outside of Start Date Update range, should not be handled here */
    DELETE FROM tmp_rc WHERE c_ProrateOnSubscription = '0' AND c_RCIntervalEnd > v_subscriptionEnd2
      AND v_subscriptionEnd2 < c_BillingIntervalEnd; /* If start date was updated To or From "after EOP date" all PIs should be charged. Don't delete anything. */
  END IF;


  insertChargesIntoSvcTables('%Credit','%Debit');

  UPDATE tmp_newrw rw
  SET c_BilledThroughDate = currentDate
  where rw.c__IsAllowGenChargeByTrigger = 1;

  /*We can get an no data exception if there are no previous subscriptions; just return in this case.*/
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
end MeterCreditFromRecurWindow;
/

CREATE OR REPLACE PROCEDURE MeterInitialFromRecurWindow (currentDate date) AS
  enabled varchar2(10);
BEGIN
  SELECT value INTO enabled FROM t_db_values WHERE parameter = N'InstantRc';
  IF (enabled = 'false') THEN RETURN; END IF;

  INSERT INTO tmp_rc
  SELECT
    'Initial'                                                                           AS c_RCActionType,
    pci.dt_start                                                                        AS c_RCIntervalStart,
    pci.dt_end                                                                          AS c_RCIntervalEnd,
    ui.dt_start                                                                         AS c_BillingIntervalStart,
    ui.dt_end                                                                           AS c_BillingIntervalEnd,
    dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)                           AS c_RCIntervalSubscriptionStart,
    dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)                               AS c_RCIntervalSubscriptionEnd,
    rw.c_SubscriptionStart                                                              AS c_SubscriptionStart,
    rw.c_SubscriptionEnd                                                                AS c_SubscriptionEnd,
    CASE WHEN rw.c_advance  ='Y' THEN '1' ELSE '0' END                                  AS c_Advance,
    CASE WHEN rcr.b_prorate_on_activate ='Y' THEN '1' ELSE '0' END                      AS c_ProrateOnSubscription,
    CASE WHEN rcr.b_prorate_instantly  ='Y' THEN '1' ELSE '0' END                       AS c_ProrateInstantly,
    rw.c_UnitValueStart                                                                 AS c_UnitValueStart,
    rw.c_UnitValueEnd                                                                   AS c_UnitValueEnd,
    rw.c_UnitValue                                                                      AS c_UnitValue,
    rcr.n_rating_type                                                                   AS c_RatingType,
    CASE WHEN rcr.b_prorate_on_deactivate  ='Y' THEN '1' ELSE '0' END                   AS c_ProrateOnUnsubscription,
    CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END AS c_ProrationCycleLength,
    rw.c__accountid                                                                     AS c__AccountID,
    rw.c__payingaccount                                                                 AS c__PayingAccount,
    rw.c__priceableiteminstanceid                                                       AS c__PriceableItemInstanceID,
    rw.c__priceableitemtemplateid                                                       AS c__PriceableItemTemplateID,
    rw.c__productofferingid                                                             AS c__ProductOfferingID,
    dbo.MTMinOfTwoDates(pci.dt_end,rw.c_SubscriptionEnd)                                AS c_BilledRateDate,
    rw.c__subscriptionid                                                                AS c__SubscriptionID,
    currentui.id_interval                                                               AS c__IntervalID,
    SYS_GUID()                                                                          AS id_source_sess
  FROM t_usage_interval ui
    INNER JOIN tmp_newrw rw
      ON  rw.c_payerstart           < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
      AND rw.c_cycleeffectivestart  < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
      AND rw.c_membershipstart      < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
      AND rw.c_SubscriptionStart    < ui.dt_end AND rw.c_SubscriptionEnd   > ui.dt_start
      AND rw.c_unitvaluestart       < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
    INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
    INNER JOIN t_usage_cycle ccl
      ON  ccl.id_usage_cycle = CASE
                            WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                            WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                            ELSE NULL
                        END
    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
    INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
      AND (
            (rcr.b_advance = 'Y' AND pci.dt_start BETWEEN ui.dt_start AND ui.dt_end)      /* If this is in advance, check if rc start falls in this interval */
            OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                               /* or check if the cycle end falls into this interval */
            OR (pci.dt_start < ui.dt_start and pci.dt_end > ui.dt_end)                    /* or this interval could be in the middle of the cycle */
          )
      AND pci.dt_end BETWEEN rw.c_payerstart AND rw.c_payerend                            /* rc start goes to this payer */
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
      AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
      AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
    INNER JOIN t_usage_interval currentui ON currentDate BETWEEN currentui.dt_start AND currentui.dt_end
      AND currentui.id_usage_cycle = ui.id_usage_cycle
  WHERE
    /*Only meter new subscriptions as initial -- so select only items that have at most one entry in t_sub_history*/
    NOT EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.c__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < currentDate)
    /*Also no old unit values*/
    AND NOT EXISTS (SELECT 1 FROM t_recur_value trv WHERE trv.id_sub = rw.c__SubscriptionID AND trv.tt_end < dbo.MTMaxDate())
    /* Don't meter in the current interval for initial*/
    AND ui.dt_start < currentDate
    AND rw.c__IsAllowGenChargeByTrigger = 1;

  insertChargesIntoSvcTables('Initial','Initial');

	UPDATE  tmp_newrw rw
	SET     c_BilledThroughDate = currentDate
	WHERE   rw.c__IsAllowGenChargeByTrigger = 1;

END MeterInitialFromRecurWindow;
/

CREATE OR REPLACE PROCEDURE MeterPayerChangeFromRecWind (currentDate date) AS

  enabled varchar2(10);
  BEGIN
   SELECT value into enabled FROM t_db_values WHERE parameter = N'InstantRc';
   IF (enabled = 'false')then return;  end if;
    
   INSERT INTO TMP_PAYER_CHANGES
   SELECT DISTINCT
        pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND ui.dt_start <> rw.c_cycleEffectiveDate
        THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(rw.c_cycleEffectiveDate), pci.dt_start)
        ELSE pci.dt_start END as c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      /*Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.*/
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
      ,rw.c_UnitValueStart AS c_UnitValueStart
      ,rw.c_UnitValueEnd AS c_UnitValueEnd
      ,rw.c_UnitValue AS c_UnitValue
      ,rcr.n_rating_type AS c_RatingType
      ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccountCredit
      ,rwnew.c__payingaccount AS c__PayingAccountDebit
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,dbo.MTMinOfTwoDates(pci.dt_end,rw.c_SubscriptionEnd)  AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
      ,currentui.id_interval AS c__IntervalID
     FROM tmp_oldrw rw  INNER JOIN t_usage_interval ui
         on rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
           AND rw.c_subscriptionstart   < ui.dt_end AND rw.c_subscriptionend   > ui.dt_start /* next interval overlaps with subscription */
           AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend > ui.dt_start /* next interval overlaps with membership */
    /*Between the new and old values, one contains the other, depending on if we've added a payer in the middle or taken one out.
    * Whichever is smaller is the one we actually have to debit/credit, because it's the part that has changed.
    */
    INNER JOIN tmp_newrw rwnew ON rwnew.c__AccountID = rw.c__AccountID AND rwnew.c__PayingAccount != rw.c__PayingAccount
        and dbo.MTMaxOfTwoDates(rwnew.c_payerstart, rw.c_PayerStart) < ui.dt_end AND dbo.MTMinOfTwoDates(rw.c_PayerEnd,rwnew.c_payerend) > ui.dt_start
        /*we only want the cases where the new payer contains the old payer or vice versa.*/
        AND ((rw.c_PayerStart >= rwnew.c_PayerStart AND rw.c_PayerEnd <= rwnew.c_PayerEnd)
            OR (rw.c_PayerStart <= rwnew.c_PayerStart AND rw.c_PayerEnd >= rwnew.c_PayerEnd))
      INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE
	    WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
		WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
		WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
		ELSE NULL END
      JOIN t_acc_usage_cycle auc on auc.id_acc = rw.c__payingaccount and auc.id_usage_cycle = ccl.id_usage_cycle
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
      INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_start BETWEEN ui.dt_start     AND ui.dt_end                            /* rc start falls in this interval */
                                   AND pci.dt_start < dbo.MTMinOfTwoDates(rw.c_PayerEnd, rwnew.c_payerend)
                                   AND pci.dt_end > dbo.MTMaxOfTwoDates(rwnew.c_payerstart, rw.c_PayerStart)             /* rc start goes to this payer */
                                   /*Also, RC end needs to be for this payer -- otherwise the other payer gets it.*/
                                   AND pci.dt_end <= dbo.MTMinOfTwoDates(rw.c_PayerEnd, rwnew.c_payerend)
                                   AND rwnew.c_membershipstart     < pci.dt_end AND rwnew.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
								   and pci.dt_start < currentDate /* Don't go into the future*/
      INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      inner join t_usage_interval currentui on currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = ui.id_usage_cycle
   where 1=1;
	  
	  insert INTO tmp_rc
 		SELECT 'InitialCredit' AS c_RCActionType
           ,c_RCIntervalStart
           ,c_RCIntervalEnd
           ,c_BillingIntervalStart
           ,c_BillingIntervalEnd
           ,c_RCIntervalSubscriptionStart
           ,c_RCIntervalSubscriptionEnd
           ,c_SubscriptionStart
           ,c_SubscriptionEnd
           ,c_Advance
           ,c_ProrateOnSubscription
           ,c_ProrateInstantly
           ,c_UnitValueStart
           ,c_UnitValueEnd
           ,c_UnitValue
           ,c_RatingType
           ,c_ProrateOnUnsubscription
           ,c_ProrationCycleLength
           ,c__AccountID
           ,c__PayingAccountDebit AS c__PayingAccount
           ,c__PriceableItemInstanceID
           ,c__PriceableItemTemplateID
           ,c__ProductOfferingID
           ,c_BilledRateDate
           ,c__SubscriptionID
           ,c__IntervalID
           ,sys_guid() AS idSourceSess FROM TMP_PAYER_CHANGES
           
           UNION ALL
           		SELECT 'InitialDebit' AS c_RCActionType
           ,c_RCIntervalStart
           ,c_RCIntervalEnd
           ,c_BillingIntervalStart
           ,c_BillingIntervalEnd
           ,c_RCIntervalSubscriptionStart
           ,c_RCIntervalSubscriptionEnd
           ,c_SubscriptionStart
           ,c_SubscriptionEnd
           ,c_Advance
           ,c_ProrateOnSubscription
           ,c_ProrateInstantly
           ,c_UnitValueStart
           ,c_UnitValueEnd
           ,c_UnitValue
           ,c_RatingType
           ,c_ProrateOnUnsubscription
           ,c_ProrationCycleLength
           ,c__AccountID
           ,c__PayingAccountCredit AS c__PayingAccount
           ,c__PriceableItemInstanceID
           ,c__PriceableItemTemplateID
           ,c__ProductOfferingID
           ,c_BilledRateDate
           ,c__SubscriptionID
           ,c__IntervalID
           ,sys_guid() AS idSourceSess FROM TMP_PAYER_CHANGES ;
          
    InsertChargesIntoSvcTables('InitialCredit','InitialDebit');
	
	UPDATE tmp_newrw rw
	SET c_BilledThroughDate = currentDate
	where rw.c__IsAllowGenChargeByTrigger = 1;

end MeterPayerChangeFromRecWind;
/

ALTER FUNCTION getutcdate COMPILE ;

CREATE OR REPLACE PROCEDURE mtsp_generate_stateful_rcs(
    v_id_interval  INT ,
    v_id_billgroup INT ,
    v_id_run       INT ,
    v_id_batch NVARCHAR2 ,
    v_n_batch_size INT ,
    v_run_date DATE ,
    p_count OUT INT)
AS
  l_total_rcs  INT;
  l_total_flat INT;
  l_total_udrc INT;
  l_n_batches  INT;
  l_id_flat    INT;
  l_id_udrc    INT;
  l_id_message NUMBER;
  l_id_ss      INT;
  l_tx_batch   VARCHAR2(256);
BEGIN
  INSERT
  INTO t_recevent_run_details
    (
	id_detail,
      id_run,
      dt_crt,
      tx_type,
      tx_detail
    )
    VALUES
    (
	seq_t_recevent_run_details.nextval,
      v_id_run,
      GETUTCDATE(),
      'Debug',
      'Retrieving RC candidates'
    );

  BEGIN
     EXECUTE IMMEDIATE 'DROP TABLE t_rec_win_bcp_for_reverse';
  EXCEPTION
     WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
           RAISE;
        END IF;
  END;
  EXECUTE IMMEDIATE 'CREATE TABLE t_rec_win_bcp_for_reverse AS SELECT c_BilledThroughDate, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c__ProductOfferingID, c__SubscriptionID FROM t_recur_window';

  INSERT
  INTO TMP_RCS
    (
      idSourceSess,
      c_RCActionType,
      c_RCIntervalStart,
      c_RCIntervalEnd,
      c_BillingIntervalStart,
      c_BillingIntervalEnd,
      c_RCIntervalSubscriptionStart,
      c_RCIntervalSubscriptionEnd,
      c_SubscriptionStart,
      c_SubscriptionEnd,
      c_Advance,
      c_ProrateOnSubscription,
      c_ProrateInstantly,
      c_ProrateOnUnsubscription,
      c_ProrationCycleLength,
      c__AccountID,
      c__PayingAccount,
      c__PriceableItemInstanceID,
      c__PriceableItemTemplateID,
      c__ProductOfferingID,
      c_BilledRateDate,
      c__SubscriptionID,
      c_payerstart,
      c_payerend,
      c_unitvaluestart,
      c_unitvalueend,
      c_unitvalue,
	  c_RatingType
    )
  SELECT idSourceSess,
    c_RCActionType,
    c_RCIntervalStart,
    c_RCIntervalEnd,
    c_BillingIntervalStart,
    c_BillingIntervalEnd,
    c_RCIntervalSubscriptionStart,
    c_RCIntervalSubscriptionEnd,
    c_SubscriptionStart,
    c_SubscriptionEnd,
    c_Advance,
    c_ProrateOnSubscription,
    c_ProrateInstantly,
    c_ProrateOnUnsubscription,
    c_ProrationCycleLength,
    c__AccountID,
    c__PayingAccount,
    c__PriceableItemInstanceID,
    c__PriceableItemTemplateID,
    c__ProductOfferingID,
    c_BilledRateDate,
    c__SubscriptionID,
    c_payerstart,
    c_payerend,
    c_unitvaluestart,
    c_unitvalueend,
    c_unitvalue,
	c_ratingtype
  FROM
    (SELECT sys_guid()                                          AS idSourceSess,
      'Arrears'                                                 AS c_RCActionType ,
      pci.dt_start                                              AS c_RCIntervalStart ,
      pci.dt_end                                                AS c_RCIntervalEnd ,
      ui.dt_start                                               AS c_BillingIntervalStart ,
      ui.dt_end                                                 AS c_BillingIntervalEnd ,
      dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart) AS c_RCIntervalSubscriptionStart ,
      dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)     AS c_RCIntervalSubscriptionEnd ,
      rw.c_SubscriptionStart                                    AS c_SubscriptionStart ,
      rw.c_SubscriptionEnd                                      AS c_SubscriptionEnd ,
      case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance,
      case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription,
      case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly ,
      case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription,
      CASE
        WHEN rcr.b_fixed_proration_length = 'Y'
        THEN fxd.n_proration_length
        ELSE 0
      END                           AS c_ProrationCycleLength ,
      rw.c__accountid               AS c__AccountID ,
      rw.c__payingaccount           AS c__PayingAccount ,
      rw.c__priceableiteminstanceid AS c__PriceableItemInstanceID ,
      rw.c__priceableitemtemplateid AS c__PriceableItemTemplateID ,
      rw.c__productofferingid       AS c__ProductOfferingID ,
      pci.dt_end                    AS c_BilledRateDate ,
      rw.c__subscriptionid          AS c__SubscriptionID ,
      rw.c_payerstart,
      rw.c_payerend,
      CASE
        WHEN rw.c_unitvaluestart < TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
        THEN TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
        ELSE rw.c_unitvaluestart
      END AS c_unitvaluestart ,
      rw.c_unitvalueend ,
      rw.c_unitvalue ,
	  rcr.n_rating_type AS c_RatingType
    FROM t_usage_interval ui
	INNER JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
    INNER JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup
    INNER JOIN t_recur_window rw ON bgm.id_acc       = rw.c__payingaccount
		AND rw.c_payerstart < ui.dt_end AND rw.c_payerend   > ui.dt_start
      /* interval overlaps with payer */
		AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend   > ui.dt_start
      /* interval overlaps with cycle */
		AND rw.c_membershipstart < ui.dt_end AND rw.c_membershipend   > ui.dt_start
      /* interval overlaps with membership */
		AND rw.c_subscriptionstart < ui.dt_end AND rw.c_subscriptionend   > ui.dt_start
      /* interval overlaps with subscription */
		AND rw.c_unitvaluestart < ui.dt_end AND rw.c_unitvalueend   > ui.dt_start
      /* interval overlaps with UDRC */
    INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle =
      CASE
        WHEN rcr.tx_cycle_mode = 'Fixed'
        THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained'
        THEN ui.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR'
        THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL
      END
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
		AND pci.dt_end BETWEEN ui.dt_start AND ui.dt_end
      /* rc end falls in this interval */
		AND pci.dt_end BETWEEN rw.c_payerstart AND rw.c_payerend
      /* rc end goes to this payer */
	    AND rw.c_unitvaluestart < pci.dt_end AND rw.c_unitvalueend   > pci.dt_start
      /* rc overlaps with this UDRC */
		AND rw.c_membershipstart < pci.dt_end AND rw.c_membershipend   > pci.dt_start
      /* rc overlaps with this membership */
		AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend   > pci.dt_start
      /* rc overlaps with this cycle */
		AND rw.c_SubscriptionStart < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start
      /* rc overlaps with this subscription */
    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
    WHERE 1              =1
    AND ui.id_interval   = v_id_interval
    AND bg.id_billgroup  = v_id_billgroup
    AND rcr.b_advance   <> 'Y'
    UNION ALL
    SELECT sys_guid()										AS idSourceSess,
      'Advance'												AS c_RCActionType ,
      pci.dt_start											AS c_RCIntervalStart,		/* Start date of Next RC Interval - the one we'll pay for In Advance in current interval */
      pci.dt_end											AS c_RCIntervalEnd,			/* End date of Next RC Interval - the one we'll pay for In Advance in current interval */
      ui.dt_start											AS c_BillingIntervalStart,	/* Start date of Current Billing Interval */
      ui.dt_end												AS c_BillingIntervalEnd,	/* End date of Current Billing Interval */
      CASE
        WHEN rcr.tx_cycle_mode <> 'Fixed'
        AND nui.dt_start       <> c_cycleEffectiveDate
        THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start)
        ELSE dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)
      END													AS c_RCIntervalSubscriptionStart ,
      dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)	AS c_RCIntervalSubscriptionEnd ,
      rw.c_SubscriptionStart								AS c_SubscriptionStart ,
      rw.c_SubscriptionEnd									AS c_SubscriptionEnd ,
      case when rw.c_advance  ='Y' then '1' else '0' end				AS c_Advance,
      case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end	AS c_ProrateOnSubscription,
      case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end		AS c_ProrateInstantly ,
      case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end	AS c_ProrateOnUnsubscription,
      CASE
        WHEN rcr.b_fixed_proration_length = 'Y'
        THEN fxd.n_proration_length
        ELSE 0
      END													AS c_ProrationCycleLength ,
      rw.c__accountid										AS c__AccountID ,
      rw.c__payingaccount									AS c__PayingAccount ,
      rw.c__priceableiteminstanceid							AS c__PriceableItemInstanceID ,
      rw.c__priceableitemtemplateid							AS c__PriceableItemTemplateID ,
      rw.c__productofferingid								AS c__ProductOfferingID ,
      pci.dt_start											AS c_BilledRateDate ,
      rw.c__subscriptionid									AS c__SubscriptionID ,
      rw.c_payerstart,
      rw.c_payerend,
      CASE
        WHEN rw.c_unitvaluestart < TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
        THEN TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
        ELSE rw.c_unitvaluestart
      END													AS c_unitvaluestart,
      rw.c_unitvalueend ,
      rw.c_unitvalue ,
	  rcr.n_rating_type										AS c_RatingType
    FROM t_usage_interval ui
    INNER JOIN t_usage_interval nui
    ON ui.id_usage_cycle         = nui.id_usage_cycle
    AND dbo.AddSecond(ui.dt_end) = nui.dt_start
    INNER JOIN t_billgroup bg
    ON bg.id_usage_interval = ui.id_interval
    INNER JOIN t_billgroup_member bgm
    ON bg.id_billgroup = bgm.id_billgroup
    INNER JOIN t_recur_window rw
     ON bgm.id_acc = rw.c__payingaccount
                                   AND rw.c_payerstart          < nui.dt_end AND rw.c_payerend          > nui.dt_start /* next interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < nui.dt_end AND rw.c_cycleeffectiveend > nui.dt_start /* next interval overlaps with cycle */
                                   AND rw.c_membershipstart     < nui.dt_end AND rw.c_membershipend     > nui.dt_start /* next interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < nui.dt_end AND rw.c_subscriptionend   > nui.dt_start /* next interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < nui.dt_end AND rw.c_unitvalueend      > nui.dt_start /* next interval overlaps with UDRC */
    INNER JOIN t_recur rcr
    ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER JOIN t_usage_cycle ccl
    ON ccl.id_usage_cycle =
      CASE
        WHEN rcr.tx_cycle_mode = 'Fixed'
        THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained'
        THEN ui.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR'
        THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL
      END
    INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
							AND (
								pci.dt_start BETWEEN nui.dt_start AND nui.dt_end /* RCs that starts in Next Account's Billing Cycle */
								/* Fix for CORE-7060:
								In case subscription starts after current EOP we should also charge:
								RCs that ends in Next Account's Billing Cycle
								and if Next Account's Billing Cycle in the middle of RCs interval.
								As in this case, they haven't been charged as Instant RC (by trigger) */
								OR (
									  rw.c_SubscriptionStart >= nui.dt_start
									  AND pci.dt_end >= nui.dt_start
									  AND pci.dt_start < nui.dt_end
									)
							)
							AND (
								pci.dt_start BETWEEN rw.c_payerstart  AND rw.c_payerend	/* rc start goes to this payer */
								
								/* Fix for CORE-7273:
								Logic above, that relates to Account Billing Cycle, should be duplicated for Payer's Billing Cycle.
								
								CORE-7273 related case: If Now = EOP = Subscription Start then:
								1. Not only RC's that starts in this payer's cycle should be charged, but also the one, that ends and overlaps it;
								2. Proration wasn't calculated by trigger and should be done by EOP. */
								OR (
									  rw.c_SubscriptionStart >= rw.c_payerstart
									  AND pci.dt_end >= rw.c_payerstart
									  AND pci.dt_start < rw.c_payerend
									)
							)
							AND rw.c_unitvaluestart		< pci.dt_end AND rw.c_unitvalueend	> pci.dt_start /* rc overlaps with this UDRC */
							AND rw.c_membershipstart	< pci.dt_end AND rw.c_membershipend	> pci.dt_start /* rc overlaps with this membership */
							AND rw.c_cycleeffectiveend	> pci.dt_start	/* rc overlaps with this cycle */
							AND rw.c_subscriptionend	> pci.dt_start	/* rc overlaps with this subscription */
      /* rc overlaps with this subscription */
    INNER JOIN t_usage_cycle_type fxd
    ON fxd.id_cycle_type = ccl.id_cycle_type
    WHERE 1              =1
    AND ui.id_interval   = v_id_interval
    AND bg.id_billgroup  = v_id_billgroup
    AND rcr.b_advance    = 'Y'
    )A ;
  SELECT COUNT(1) INTO l_total_rcs FROM tmp_rcs;
  INSERT
  INTO t_recevent_run_details
    (
    	id_detail,
      id_run,
      dt_crt,
      tx_type,
      tx_detail
    )
    VALUES
    (
    seq_t_recevent_run_details.nextval,
      v_id_run,
      GETUTCDATE(),
      'Debug',
      'RC Candidate Count: '
      || l_total_rcs
    );
  IF l_total_rcs > 0 THEN
    SELECT COUNT(1) INTO l_total_flat FROM tmp_rcs WHERE c_unitvalue IS NULL;
    SELECT COUNT(1) INTO l_total_udrc FROM tmp_rcs WHERE c_unitvalue IS NOT NULL;
    INSERT
    INTO t_recevent_run_details
      (
      	id_detail,
        id_run,
        dt_crt,
        tx_type,
        tx_detail
      )
      VALUES
      (
          seq_t_recevent_run_details.nextval,
        v_id_run,
        GETUTCDATE(),
        'Debug',
        'Flat RC Candidate Count: '
        || l_total_flat
      );
    INSERT
    INTO t_recevent_run_details
      (
      id_detail,
        id_run,
        dt_crt,
        tx_type,
        tx_detail
      )
      VALUES
      (
          seq_t_recevent_run_details.nextval,
        v_id_run,
        GETUTCDATE(),
        'Debug',
        'UDRC RC Candidate Count: '
        || l_total_udrc
      );
    INSERT
    INTO t_recevent_run_details
      (
      id_detail,
        id_run,
        dt_crt,
        tx_type,
        tx_detail
      )
      VALUES
      (
          seq_t_recevent_run_details.nextval,
        v_id_run,
        GETUTCDATE(),
        'Debug',
        'Session Set Count: '
        || v_n_batch_size
      );
    INSERT
    INTO t_recevent_run_details
      (
      id_detail,
        id_run,
        dt_crt,
        tx_type,
        tx_detail
      )
      VALUES
      (
          seq_t_recevent_run_details.nextval,
        v_id_run,
        GETUTCDATE(),
        'Debug',
        'Batch: '
        || v_id_batch
      );
    l_tx_batch := v_id_batch;
	
	INSERT
    INTO t_recevent_run_details
      (
      id_detail,
        id_run,
        dt_crt,
        tx_type,
        tx_detail
      )
      VALUES
      (
          seq_t_recevent_run_details.nextval,
        v_id_run,
        GETUTCDATE(),
        'Debug',
        'Batch ID: '
        || l_tx_batch
      );
    IF l_total_flat > 0 THEN
      SELECT id_enum_data
      INTO l_id_flat
      FROM t_enum_data ted
      WHERE ted.nm_enum_data = 'metratech.com/flatrecurringcharge';
      l_n_batches           := (l_total_flat / v_n_batch_size) + 1;
      GetIdBlock( l_n_batches, 'id_dbqueuesch', l_id_message);
      GetIdBlock( l_n_batches, 'id_dbqueuess', l_id_ss);
      INSERT INTO t_session
        (id_ss, id_source_sess
        )
      SELECT l_id_ss + (MOD(ROW_NUMBER() OVER (ORDER BY idSourceSess), l_n_batches)) AS id_ss,
        idSourceSess                                                                 AS id_source_sess
      FROM tmp_rcs
      WHERE c_unitvalue IS NULL;
      INSERT INTO t_session_set
        (id_message, id_ss, id_svc, b_root, session_count
        )
      SELECT id_message,
        id_ss,
        id_svc,
        b_root,
        COUNT(1) AS session_count
      FROM
        (SELECT l_id_message + (MOD(ROW_NUMBER() OVER (ORDER BY idSourceSess), l_n_batches)) AS id_message,
          l_id_ss + (MOD(ROW_NUMBER() OVER (ORDER BY idSourceSess), l_n_batches)) AS id_ss,
          l_id_flat                                                               AS id_svc,
          1                                                                       AS b_root
        FROM tmp_rcs
        WHERE c_unitvalue IS NULL
        ) a
      GROUP BY a.id_message,
        a.id_ss,
        a.id_svc,
        a.b_root;
      INSERT
      INTO t_svc_FlatRecurringCharge
        (
          id_source_sess ,
          id_parent_source_sess ,
          id_external ,
          c_RCActionType ,
          c_RCIntervalStart ,
          c_RCIntervalEnd ,
          c_BillingIntervalStart ,
          c_BillingIntervalEnd ,
          c_RCIntervalSubscriptionStart ,
          c_RCIntervalSubscriptionEnd ,
          c_SubscriptionStart ,
          c_SubscriptionEnd ,
          c_Advance ,
          c_ProrateOnSubscription ,
          c_ProrateInstantly ,
          c_ProrateOnUnsubscription ,
          c_ProrationCycleLength ,
          c__AccountID ,
          c__PayingAccount ,
          c__PriceableItemInstanceID ,
          c__PriceableItemTemplateID ,
          c__ProductOfferingID ,
          c_BilledRateDate ,
          c__SubscriptionID ,
          c__IntervalID ,
          c__Resubmit ,
          c__TransactionCookie ,
          c__CollectionID
        )
      SELECT idSourceSess AS id_source_sess ,
        NULL              AS id_parent_source_sess ,
        NULL              AS id_external
        /*If the old subscription ends later than the current one, then we owe a credit, otherwise a debit.
        * But in either case, take the earlier date as the beginning, the other date as the end.
        */
        ,
        c_RCActionType ,
        c_RCIntervalStart ,
        c_RCIntervalEnd ,
        c_BillingIntervalStart ,
        c_BillingIntervalEnd ,
        c_RCIntervalSubscriptionStart ,
        c_RCIntervalSubscriptionEnd ,
        c_SubscriptionStart ,
        c_SubscriptionEnd ,
        c_Advance ,
        c_ProrateOnSubscription ,
        c_ProrateInstantly ,
        c_ProrateOnUnsubscription ,
        c_ProrationCycleLength ,
        c__AccountID ,
        c__PayingAccount ,
        c__PriceableItemInstanceID ,
        c__PriceableItemTemplateID ,
        c__ProductOfferingID ,
        c_BilledRateDate ,
        c__SubscriptionID ,
        v_id_interval AS c__IntervalID ,
        '0'           AS c__Resubmit ,
        NULL          AS c__TransactionCookie ,
        l_tx_batch    AS c__CollectionID
      FROM tmp_rcs
      WHERE c_unitvalue IS NULL;
          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              v_run_date,
              v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT l_id_message + (MOD(ROW_NUMBER() OVER (ORDER BY idSourceSess), l_n_batches)) AS id_message
              FROM tmp_rcs
              WHERE c_unitvalue IS NULL
              ) a
            GROUP BY a.id_message;
      INSERT
      INTO t_recevent_run_details
        (
        id_detail,
          id_run,
          dt_crt,
          tx_type,
          tx_detail
        )
        VALUES
        (
            seq_t_recevent_run_details.nextval,
          v_id_run,
          GETUTCDATE(),
          'Debug',
          'Done inserting Flat RCs'
        );
    END IF;
    IF l_total_udrc > 0 THEN
      SELECT id_enum_data
      INTO l_id_udrc
      FROM t_enum_data ted
      WHERE ted.nm_enum_data = 'metratech.com/udrecurringcharge';
      l_n_batches           := (l_total_udrc / v_n_batch_size) + 1;
      GetIdBlock( l_n_batches, 'id_dbqueuesch', l_id_message);
      GetIdBlock( l_n_batches, 'id_dbqueuess', l_id_ss);
      INSERT INTO t_session
        (id_ss, id_source_sess
        )
      SELECT l_id_ss + (MOD(ROW_NUMBER() OVER (ORDER BY idSourceSess), l_n_batches)) AS id_ss,
        idSourceSess                                                                 AS id_source_sess
      FROM tmp_rcs
      WHERE c_unitvalue IS NOT NULL;
      INSERT INTO t_session_set
        (id_message, id_ss, id_svc, b_root, session_count
        )
      SELECT id_message,
        id_ss,
        id_svc,
        b_root,
        COUNT(1) AS session_count
      FROM
        (SELECT l_id_message + (MOD(ROW_NUMBER() OVER (ORDER BY idSourceSess), l_n_batches)) AS id_message,
          l_id_ss + (MOD(ROW_NUMBER() OVER (ORDER BY idSourceSess), l_n_batches)) AS id_ss,
          l_id_udrc                                                               AS id_svc,
          1                                                                       AS b_root
        FROM tmp_rcs
        WHERE c_unitvalue IS NOT NULL
        ) a
      GROUP BY a.id_message,
        a.id_ss,
        a.id_svc,
        a.b_root;
      INSERT
      INTO t_svc_UDRecurringCharge
        (
          id_source_sess,
          id_parent_source_sess,
          id_external,
          c_RCActionType,
          c_RCIntervalStart,
          c_RCIntervalEnd,
          c_BillingIntervalStart,
          c_BillingIntervalEnd ,
          c_RCIntervalSubscriptionStart ,
          c_RCIntervalSubscriptionEnd ,
          c_SubscriptionStart ,
          c_SubscriptionEnd ,
          c_Advance ,
          c_ProrateOnSubscription ,
          /*    c_ProrateInstantly , */
          c_ProrateOnUnsubscription ,
          c_ProrationCycleLength ,
          c__AccountID ,
          c__PayingAccount ,
          c__PriceableItemInstanceID ,
          c__PriceableItemTemplateID ,
          c__ProductOfferingID ,
          c_BilledRateDate ,
          c__SubscriptionID ,
          c__IntervalID ,
          c__Resubmit ,
          c__TransactionCookie ,
          c__CollectionID ,
		  c_unitvaluestart ,
		  c_unitvalueend ,
		  c_unitvalue ,
		  c_ratingtype
        )
      SELECT idSourceSess AS id_source_sess ,
        NULL              AS id_parent_source_sess ,
        NULL              AS id_external ,
        c_RCActionType ,
        c_RCIntervalStart ,
        c_RCIntervalEnd ,
        c_BillingIntervalStart ,
        c_BillingIntervalEnd ,
        c_RCIntervalSubscriptionStart ,
        c_RCIntervalSubscriptionEnd ,
        c_SubscriptionStart ,
        c_SubscriptionEnd ,
        c_Advance ,
        c_ProrateOnSubscription ,
        /* c_ProrateInstantly , */
        c_ProrateOnUnsubscription ,
        c_ProrationCycleLength ,
        c__AccountID ,
        c__PayingAccount ,
        c__PriceableItemInstanceID ,
        c__PriceableItemTemplateID ,
        c__ProductOfferingID ,
        c_BilledRateDate ,
        c__SubscriptionID ,
        v_id_interval AS c__IntervalID ,
        '0'           AS c__Resubmit ,
        NULL          AS c__TransactionCookie ,
        l_tx_batch    AS c__CollectionID ,
		c_unitvaluestart ,
		c_unitvalueend ,
		c_unitvalue ,
		c_ratingtype
      FROM tmp_rcs
      WHERE c_unitvalue IS NOT NULL;
          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              v_run_date,
              v_run_date,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '127.0.0.1'
            FROM
              (SELECT l_id_message + (MOD(ROW_NUMBER() OVER (ORDER BY idSourceSess), l_n_batches)) AS id_message
              FROM tmp_rcs
              WHERE c_unitvalue IS NOT NULL
              ) a
            GROUP BY a.id_message;
      INSERT
      INTO t_recevent_run_details
        (
        id_detail,
          id_run,
          dt_crt,
          tx_type,
          tx_detail
        )
        VALUES
        (
            seq_t_recevent_run_details.nextval,
          v_id_run,
          GETUTCDATE(),
          'Debug',
          'Done inserting UDRC RCs'
        );
    END IF;
  END IF;
  p_count := l_total_rcs;
  INSERT
  INTO t_recevent_run_details
    (
    id_detail,
      id_run,
      dt_crt,
      tx_type,
      tx_detail
    )
    VALUES
    (
        seq_t_recevent_run_details.nextval,
      v_id_run,
      GETUTCDATE(),
      'Info',
      'Finished submitting RCs, count: '
      || l_total_rcs
    );
END mtsp_generate_stateful_rcs;
/

ALTER PROCEDURE arch_q_p_next_part_single_tab COMPILE ;

ALTER PROCEDURE arch_q_p_rollback_next_prtn COMPILE ;

CREATE OR REPLACE PROCEDURE arch_q_p_apply_next_partition(
    p_new_current_id_partition		INT,
    p_current_time					DATE,
    p_meter_tablespace_name			VARCHAR2,
    p_meter_partition_field_name	VARCHAR2
)
AUTHID CURRENT_USER
AS
BEGIN
    
    DBMS_OUTPUT.PUT_LINE(
    'Begin execution of "archive_queue_partition_apply_next_partition"...');

    FOR x IN (  SELECT   nm_table_name
                FROM     t_service_def_log
                ORDER BY nm_table_name)
    LOOP
        arch_q_p_next_part_single_tab(
            P_TABLE_NAME => x.nm_table_name,
            P_ID_PARTITION => p_new_current_id_partition,
            P_TABLESPACE_NAME => p_meter_tablespace_name,
            P_PARTITION_FIELD_NAME => p_meter_partition_field_name);
    END LOOP;

    arch_q_p_next_part_single_tab(
        P_TABLE_NAME => 't_message',
        P_ID_PARTITION => p_new_current_id_partition,
        P_TABLESPACE_NAME => p_meter_tablespace_name,
        P_PARTITION_FIELD_NAME => p_meter_partition_field_name);

    arch_q_p_next_part_single_tab(
        P_TABLE_NAME => 't_session_set',
        P_ID_PARTITION => p_new_current_id_partition,
        P_TABLESPACE_NAME => p_meter_tablespace_name,
        P_PARTITION_FIELD_NAME => p_meter_partition_field_name);

    arch_q_p_next_part_single_tab(
        P_TABLE_NAME => 't_session',
        P_ID_PARTITION => p_new_current_id_partition,
        P_TABLESPACE_NAME => p_meter_tablespace_name,
        P_PARTITION_FIELD_NAME => p_meter_partition_field_name);

    arch_q_p_next_part_single_tab(
        P_TABLE_NAME => 't_session_state',
        P_ID_PARTITION => p_new_current_id_partition,
        P_TABLESPACE_NAME => p_meter_tablespace_name,
        P_PARTITION_FIELD_NAME => p_meter_partition_field_name);

    /* Update Default id_partition in [t_archive_queue_partition] table */
    INSERT INTO t_archive_queue_partition
    VALUES
      (
        p_new_current_id_partition,
        p_current_time,
        NULL
      );

      /* Adding a commit before calling the proc again to fix ORA-00054: resource busy and acquire with NOWAIT specified or timeout expired */
    COMMIT;
    
    EXCEPTION
      WHEN OTHERS THEN
        arch_q_p_rollback_next_prtn(
			P_ID_PARTITION => p_new_current_id_partition,
			P_PARTITION_FIELD_NAME => p_meter_partition_field_name);
		RAISE;
END;
/

ALTER PROCEDURE arch_q_p_clone_ind_and_cons COMPILE ;

CREATE OR REPLACE PROCEDURE arch_q_p_prep_sess_to_keep_tab(
	p_old_partition					INT,
	p_table_name					VARCHAR2,
	table_with_sess_to_keep			VARCHAR2
)
AUTHID CURRENT_USER
AS
	preserved_partition				INT := p_old_partition - 1;
	WHERE_clause_for_sess_to_keep	VARCHAR2(1000);
	sqlCommand						VARCHAR2(4000);
BEGIN

	IF p_table_name = 'T_SESSION_SET' THEN
		WHERE_clause_for_sess_to_keep  :=
		' WHERE  tab.id_ss IN (SELECT s.id_ss
							FROM   tt_id_sess_to_keep t
								JOIN t_session s
									ON  s.id_source_sess = t.id_sess)';
	ELSIF p_table_name = 'T_SESSION_STATE' THEN
		WHERE_clause_for_sess_to_keep  :=
		' WHERE tab.id_sess IN (SELECT t.id_sess
			FROM   tt_id_sess_to_keep t)';
	ELSIF p_table_name = 'T_MESSAGE' THEN
		WHERE_clause_for_sess_to_keep  :=
		' WHERE tab.id_message IN (SELECT ss.id_message
								FROM   t_session_set ss
									   JOIN t_session s
											ON  s.id_ss = ss.id_ss
									   JOIN tt_id_sess_to_keep t
											ON  s.id_source_sess = t.id_sess)';
	/* For T_SESSION and all T_SVC_* tables using default WHERE clause */
	ELSE
		WHERE_clause_for_sess_to_keep  :=
		' WHERE tab.id_source_sess IN (SELECT t.id_sess
		   FROM   tt_id_sess_to_keep t)';
	END IF;
	
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE ' || table_with_sess_to_keep;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
    END;
	
  DBMS_OUTPUT.ENABLE(1000000);
	DBMS_OUTPUT.PUT_LINE('	Preparing "' || table_with_sess_to_keep || '" for EXCHANGE PARTITION operation...');
    /* Create temp table for storing sessions that should not be deleted */
    sqlCommand :=  'CREATE TABLE ' || table_with_sess_to_keep
                || ' AS SELECT * FROM ' || p_table_name || ' tab '
				|| WHERE_clause_for_sess_to_keep
                || ' AND id_partition = ' || preserved_partition;
    EXECUTE IMMEDIATE sqlCommand;

    sqlCommand :=  'UPDATE ' || table_with_sess_to_keep
                || ' SET id_partition =  ' || p_old_partition;
    EXECUTE IMMEDIATE sqlCommand;

    sqlCommand :=  'INSERT INTO ' || table_with_sess_to_keep
                || ' SELECT * FROM ' || p_table_name || ' tab '
				|| WHERE_clause_for_sess_to_keep
                || ' AND id_partition = ' || p_old_partition;
    EXECUTE IMMEDIATE sqlCommand;

	arch_q_p_clone_ind_and_cons(
		SOURCE_TABLE => p_table_name,
		DESTINATION_TABLES => str_tab( table_with_sess_to_keep ) );
END;
/

CREATE OR REPLACE PROCEDURE arch_q_p_prep_all_keep_ses_tab(
	p_old_id_partition	INT
)
AUTHID CURRENT_USER
AS
	v_tab_name			VARCHAR2(30);
	v_temp_tab_name		VARCHAR2(30);
    cur_keep_sess_tabs	SYS_REFCURSOR;
	old_part_row_count	INT := 0;
	pres_part_row_count	INT := 0;
	kept_row_count		INT := 0;
	rows_to_archive		INT := 0;
BEGIN

	DBMS_OUTPUT.put_line ('Preparation of table that will bind meter table names with auto-generated unique temp-table names...');
	LOOP
		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE tt_tab_names_with_sess_to_keep';
		EXCEPTION
		  WHEN OTHERS THEN
			IF SQLCODE != -942 THEN
				RAISE;
			END IF;
		END;

		EXECUTE IMMEDIATE 'CREATE TABLE tt_tab_names_with_sess_to_keep
		AS
		SELECT UPPER(nm_table_name) TAB_NAME, SUBSTR(UPPER(nm_table_name), 0, 20) || DBMS_RANDOM.string(''x'',10) TEMP_TAB_NAME
		FROM t_service_def_log
		UNION ALL
		SELECT ''T_SESSION'', ''T_SESSION'' || DBMS_RANDOM.string(''x'',10) FROM dual
		UNION ALL
		SELECT ''T_SESSION_SET'', ''T_SESSION_SET'' || DBMS_RANDOM.string(''x'',10) FROM dual
		UNION ALL
		SELECT ''T_SESSION_STATE'', ''T_SESSION_STATE'' || DBMS_RANDOM.string(''x'',10) FROM dual
		UNION ALL
		SELECT ''T_MESSAGE'', ''T_MESSAGE'' || DBMS_RANDOM.string(''x'',10) FROM dual';

		/* Ensure auto-generated names are unique */
		BEGIN
			EXECUTE IMMEDIATE'ALTER TABLE tt_tab_names_with_sess_to_keep ADD CONSTRAINT cons_check_unique UNIQUE (TEMP_TAB_NAME)';
			EXECUTE IMMEDIATE'ALTER TABLE tt_tab_names_with_sess_to_keep DROP CONSTRAINT cons_check_unique';
			EXIT;
		EXCEPTION
		  WHEN OTHERS THEN
			IF SQLCODE != -2299 THEN
				RAISE;
			END IF;
			/* Recreate "tt_tab_names_with_sess_to_keep" if "TEMP_TAB_NAME" is not unique */
		END;
    END LOOP;

	DBMS_OUTPUT.put_line ('Preparation of temp tables with sessions to keep...');

    OPEN cur_keep_sess_tabs FOR 'SELECT TAB_NAME, TEMP_TAB_NAME FROM tt_tab_names_with_sess_to_keep';
    LOOP
		FETCH cur_keep_sess_tabs INTO v_tab_name, v_temp_tab_name;
		EXIT WHEN cur_keep_sess_tabs%NOTFOUND;

		arch_q_p_prep_sess_to_keep_tab(
			p_old_partition => p_old_id_partition,
			p_table_name => v_tab_name,
			table_with_sess_to_keep => v_temp_tab_name );

		EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_temp_tab_name INTO kept_row_count;
		EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_name || ' PARTITION (P' || p_old_id_partition || ')' INTO old_part_row_count;

		BEGIN
			EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_name || ' PARTITION (P' || (p_old_id_partition - 1) || ')' INTO pres_part_row_count;
		EXCEPTION
		  WHEN OTHERS THEN
			/* Ignore exception "ORA-02149: Specified partition does not exist" */
			IF SQLCODE != -2149 THEN
				RAISE;
			END IF;
		END;

    DBMS_OUTPUT.ENABLE(1000000);
		rows_to_archive := (old_part_row_count + pres_part_row_count) - kept_row_count;
		DBMS_OUTPUT.put_line ('<' || rows_to_archive || '> rows should be archived from "' || v_tab_name || '" table.');

    END LOOP;
	CLOSE cur_keep_sess_tabs;

	DBMS_OUTPUT.put_line ('All temp tables with sessions to keep prepared.');
END;
/

ALTER PROCEDURE pausepipelineprocessing COMPILE ;

ALTER PROCEDURE arch_q_p_drop_temp_tables COMPILE ;

ALTER PROCEDURE arch_q_p_get_id_sess_to_keep COMPILE ;

ALTER PROCEDURE arch_q_p_get_status COMPILE ;

ALTER PROCEDURE arch_q_p_switch_out_part_all COMPILE ;

ALTER FUNCTION prtn_getmeterpartfilegroupname COMPILE ;

ALTER PROCEDURE prtn_get_next_allow_run_date COMPILE ;

CREATE OR REPLACE PROCEDURE archive_queue_partition(
    p_update_stats		VARCHAR2 DEFAULT 'N',
    p_sampling_ratio	VARCHAR2 DEFAULT '30',
    p_current_time		DATE DEFAULT NULL,
    p_result		OUT VARCHAR2
)
AUTHID CURRENT_USER
AS
    /* This SP is called from from basic SP - [archive_queue] if DB is partitioned */

    /*
    How to run this stored procedure:   
	DECLARE
		v_result VARCHAR2(2000);
	BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
		archive_queue_partition ( p_result => v_result );
		DBMS_OUTPUT.put_line (v_result);
	END;
    
    Or if we want to update statistics and change current date/time also:   
    DECLARE 
        v_result            VARCHAR2(2000),
        v_current_time  DATE
    BEGIN
        v_current_time := SYSDATE;
        archive_queue_partition (
             p_update_stats => 'Y',
             p_sampling_ratio => 30,
             p_current_time => v_current_time,
             p_result => v_result
             );
        DBMS_OUTPUT.put_line (v_result);
    END;
    */
    
    v_is_part_enabled			VARCHAR2(1);
    v_current_time				DATE;
    v_next_allow_run_time		DATE;
    v_current_id_partition		INT;
    v_new_current_id_partition	INT;
    v_old_id_partition			INT;
    v_no_need_to_run			INT;
    v_meter_tablespace_name		VARCHAR2(50);
    v_count_records				INT;
	v_time_count				NUMBER;
	
BEGIN
    
    /* Force using single processor's core */
	EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DDL';
	EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
	EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL QUERY';
	
    SELECT UPPER(b_partitioning_enabled) INTO v_is_part_enabled FROM t_usage_server;
    /* Nothing to do if system isn't enabled for partitioning */
    IF v_is_part_enabled <> 'Y' THEN
        dbms_output.put_line('Partitioning is not enabled, so can not execute archive_queue_partition sp.');
        RETURN;
    END IF;
    
    DBMS_OUTPUT.put_line ('Starting archive queue process for partitioned Meter tables ');
    
    IF p_current_time IS NULL THEN
         v_current_time := SYSDATE;
    ELSE
         v_current_time := p_current_time;
    END IF;
    
    arch_q_p_get_status(
		p_current_time => v_current_time,
		p_next_allow_run_time => v_next_allow_run_time,
		p_current_id_partition => v_current_id_partition,
		p_new_current_id_partition  => v_new_current_id_partition,
		p_old_id_partition => v_old_id_partition,
		p_no_need_to_run => v_no_need_to_run );
    
    IF v_no_need_to_run = 1 THEN
        dbms_output.put_line('No need to run archive operation.');
        RETURN;
    END IF;
    
    IF v_next_allow_run_time IS NULL THEN
         dbms_output.put_line('Partition Schema and Default "id_partition" had already been updated. Skipping this step...');
    ELSE
        v_meter_tablespace_name := prtn_GetMeterPartFileGroupName();

        /* Adding a commit before calling the proc again to fix ORA-00054: resource busy and acquire with NOWAIT specified or timeout expired */
        COMMIT;
        
        arch_q_p_apply_next_partition(
            p_new_current_id_partition => v_new_current_id_partition,
            p_current_time => v_current_time,
            p_meter_tablespace_name => v_meter_tablespace_name,
            p_meter_partition_field_name =>  'id_partition' );
	END IF;
	
	/* If it is the 1-st time of running [archive_queue_partition] there are only 2 partitions.
	* It is early to archive data.
	* When 3-rd partition is created the oldest one is archiving.
	* So, meter tables always have 2 partition.*/
	SELECT COUNT(current_id_partition)
	INTO v_count_records
	FROM   t_archive_queue_partition;

	IF ( v_count_records  > 2 ) THEN

		/* Append temp table tt_id_sess_to_keep with IDs of sessions from the 'oldest' partition that should not be archived */
		arch_q_p_get_id_sess_to_keep( p_old_id_partition => v_old_id_partition );

		arch_q_p_prep_all_keep_ses_tab( p_old_id_partition => v_old_id_partition );
		
		BEGIN
      DBMS_OUTPUT.ENABLE(1000000);
			dbms_output.put_line('Pausing pipeline...');
			v_time_count := dbms_utility.get_time;
			PausePipelineProcessing( p_state => 1 );
			dbms_output.put_line('Pipeline was paused after ' || ((dbms_utility.get_time-v_time_count)/100) || ' seconds.');
			v_time_count := dbms_utility.get_time;

			/* Switch out old data, switch in preserved sessions for alll Meter tables. */
			arch_q_p_switch_out_part_all( p_old_id_partition => v_old_id_partition );

			PausePipelineProcessing( p_state => 0 );
			dbms_output.put_line('Pipeline was resumed after ' || ((dbms_utility.get_time-v_time_count)/100) || ' seconds.');
		EXCEPTION
		  WHEN OTHERS THEN
			PausePipelineProcessing( p_state => 0);
			dbms_output.put_line('Pipeline was resumed after exception! "Paused" period: ' || ((dbms_utility.get_time-v_time_count)/100) || ' seconds.');
			RAISE;
		END;

		/* Drop all old data of Meter tables. */
		arch_q_p_drop_temp_tables( p_old_id_partition => v_old_id_partition );

		/*	Rebuild GLOBAL indexes, that became UNUSABLE after EXCHANGE PARTITION operation.
			They can appear if unique constraint was added to any Service Definition*/
		dbms_output.put_line('Check for UNUSABLE indexes...');
		FOR x IN (  SELECT INDEX_NAME
					FROM   USER_INDEXES
					WHERE  TABLE_NAME IN (	SELECT UPPER(nm_table_name)
											FROM   t_service_def_log)
						AND STATUS = 'UNUSABLE' )
		LOOP
			dbms_output.put_line('Rebuilding UNUSABLE index: "' || x.INDEX_NAME || '"');
			EXECUTE IMMEDIATE 'ALTER INDEX ' || x.INDEX_NAME || ' REBUILD ONLINE';
		END LOOP;

		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE tt_tab_names_with_sess_to_keep';
		EXCEPTION
		  WHEN OTHERS THEN
			IF SQLCODE != -942 THEN
				RAISE;
			END IF;
		END;

		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE tt_id_sess_to_keep';
		EXCEPTION
		  WHEN OTHERS THEN
			IF SQLCODE != -942 THEN
				RAISE;
			END IF;
		END;

	END IF;

	/* Update next_allow_run value in [t_archive_queue_partition] table.
	* This is an indicator of successful archivation*/
	prtn_get_next_allow_run_date(
			current_datetime => v_current_time,
			next_allow_run_date => v_next_allow_run_time );

	UPDATE t_archive_queue_partition
	SET next_allow_run = v_next_allow_run_time
	WHERE current_id_partition = v_new_current_id_partition;

	COMMIT;

/* [TBD] Remove specification of sampling_ratio for update stats.
5 and 1 % can be hardly too big percent for some meter table and for some - very small */

/* Use the same update stats approach as in archive_queue_nonpartition */

  IF(p_update_stats = 'Y') THEN
  dbms_output.put_line(' update stats - started');
  
  DECLARE
	v_nu_varstatpercentchar	INT;
	v_tab1					VARCHAR2 (30);
	v_user_name				VARCHAR2 (30);
	v_sql1					VARCHAR2 (4000);
	c1						sys_refcursor;
  BEGIN
		SELECT sys_context('USERENV', 'SESSION_USER') into v_user_name FROM dual;
		OPEN c1 FOR
			SELECT nm_table_name
			FROM t_service_def_log;
			LOOP
			FETCH c1 INTO v_tab1;
			EXIT WHEN c1 % NOTFOUND;
      IF(p_sampling_ratio < 5)
				THEN v_nu_varstatpercentchar := 5;
				ELSIF(p_sampling_ratio >= 100) THEN v_nu_varstatpercentchar := 100;
				ELSE v_nu_varstatpercentchar := p_sampling_ratio;
      END IF;
      dbms_output.put_line(' executing gather_table_stats for table -> ' || UPPER(v_tab1) );
			v_sql1 := 'begin dbms_stats.gather_table_stats(ownname=> ''' || v_user_name || ''',
                 tabname=> ''' || v_tab1 || ''', estimate_percent=> ' || v_nu_varstatpercentchar || ',
                 cascade=> TRUE); end;';
      BEGIN
	      EXECUTE IMMEDIATE v_sql1;
        EXCEPTION
        WHEN others THEN
					p_result := '7000022-archive_queues operation failed->Error in update stats';
					ROLLBACK;
					RETURN;
       END;
       END LOOP;
       CLOSE c1;
       
       dbms_output.put_line(' executing gather_table_stats for table t_session' );
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_SESSION'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000023-archive_queues operation failed->Error in t_session update stats';
             ROLLBACK;
             RETURN;
       END;
       
       dbms_output.put_line(' executing gather_table_stats for table t_session_set' );
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_SESSION_SET'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000024-archive_queues operation failed->Error in t_session_set update stats';
             ROLLBACK;
             RETURN;
       END;
       
       dbms_output.put_line(' executing gather_table_stats for table t_session_state' );
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_SESSION_STATE'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000025-archive_queues operation failed->Error in t_session_state update stats';
             ROLLBACK;
             RETURN;
       END;
       
       dbms_output.put_line(' executing gather_table_stats for table t_message' );
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_MESSAGE'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000026-archive_queues operation failed->Error in t_message update stats';
             ROLLBACK;
             RETURN;
       END;
  END;
  
  dbms_output.put_line(' update stats - completed');
  END IF;

	dbms_output.put_line('Archive Process - completed');
    p_result := '0-archive_queue_partition operation successful';
END;
/

CREATE OR REPLACE PROCEDURE archive_queue(
    p_update_stats		VARCHAR2	DEFAULT 'N',
    p_sampling_ratio	VARCHAR2	DEFAULT '30',
    p_current_time		DATE		DEFAULT NULL,
    p_result		OUT VARCHAR2
)
AUTHID CURRENT_USER
AS
    /*
    How to run this stored procedure:   
    DECLARE 
		v_result VARCHAR2(2000);
    BEGIN
		archive_queue ( p_result => v_result );
    DBMS_OUTPUT.ENABLE(1000000);
		DBMS_OUTPUT.put_line (v_result);
    END;
    
    Or if we want to update statistics and change current date/time also:   
    DECLARE 
        v_result		VARCHAR2(2000),
        v_current_time	DATE
    BEGIN
        v_current_time := SYSDATE;
        archive_queue_partition (
             p_update_stats => 'Y',
             p_sampling_ratio => 30,
             p_current_time => v_current_time,
             p_result => v_result
             );
        DBMS_OUTPUT.put_line (v_result);
    END;
    */
    v_is_part_enabled			VARCHAR2(1);
    pipeline_processing   NUMBER;
BEGIN

  SELECT UPPER(b_partitioning_enabled) INTO v_is_part_enabled FROM t_usage_server;
  /* Nothing to do if system isn't enabled for partitioning */
  IF v_is_part_enabled <> 'Y' THEN
    dbms_output.put_line('Partitioning is not enabled, so can not execute archive_queue sp.');
    RETURN;
  END IF;

  /* Adding a commit before calling the proc again to fix ORA-00054: resource busy and acquire with NOWAIT specified or timeout expired */
  COMMIT;

  BEGIN
    SELECT b_processing into pipeline_processing FROM t_pipeline;
    IF pipeline_processing > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Pipeline is processing usage, so can not execute archive_queue sp.');
      RETURN;
    ELSE
      PausePipelineProcessing( p_state => 1 );
    END IF;
  END;

  archive_queue_partition(
    P_UPDATE_STATS => p_update_stats,
    P_SAMPLING_RATIO => p_sampling_ratio,
    P_CURRENT_TIME => p_current_time,
    P_RESULT => p_result);

  PausePipelineProcessing( p_state => 0 );
END;
/

CREATE OR REPLACE PROCEDURE prtn_deploy_table(
    p_tab                       VARCHAR2,       /* Table to convert */
    p_tab_type                  VARCHAR2        /* Takes only 2 values: "USAGE" or "METER" */
)
authid current_user
AS
    partn_tab                   VARCHAR2 (30);  /* temp name for new partitioned table */
    def_partn_name              VARCHAR2 (30);  /* default partition name */
    partn_ddl                   VARCHAR2 (4000);
    exchg_ddl                   VARCHAR2 (4000);
    partition_by_clause         VARCHAR2 (100); /* Example: 'partition by LIST (id_partition)' */
    def_prtn_condition          VARCHAR2 (100); /* Condition for default partition */
    is_part_enabled     		VARCHAR2(1);
    current_id_part             INT;
    idx_ddl                     str_tab;
    cons_ddl                    str_tab;
    cons_ddl1                   str_tab;
    idx_drop                    str_tab;
    cons_drop                   str_tab;
    cons_drop1                  str_tab;
    cnt                         INT;
    ix                          INT;
    nl                          CHAR (1) := CHR (10);
    tab                         CHAR (2) := '  ';
    nlt                         CHAR (3) := nl || tab;
BEGIN

    DBMS_OUTPUT.put_line ('prtn_deploy_table: ' || p_tab);
    
    SELECT UPPER(b_partitioning_enabled) INTO is_part_enabled FROM t_usage_server;
    /* Nothing to do if system isn't enabled for partitioning */
    IF is_part_enabled <> 'Y' THEN
        dbms_output.put_line('System not enabled for partitioning.');
        RETURN;
    END IF;

    /* Make sure this table isn't already partitioned */
    SELECT COUNT(1) INTO cnt
    FROM   DUAL
    WHERE  EXISTS ( SELECT 1
                    FROM   user_part_tables
                    WHERE  UPPER(table_name) = UPPER(p_tab));

    IF cnt > 0 THEN
        DBMS_OUTPUT.put_line ('prtn_deploy_table: ' || p_tab || ' is already partitioned.');
        RETURN;
    END IF;

   /* Temp name for new table, expecting name with form 't_whatever' */
   partn_tab := 'p' || SUBSTR (p_tab, 2);
   
    /* Initialize Default Partition info (tablespace, parition values) for Usage or Meter table tablespace name */
    IF p_tab_type = 'USAGE' THEN
        BEGIN
            partition_by_clause := 'partition by RANGE (id_usage_interval)';
            def_prtn_condition := 'less than (9999999999)';
			def_partn_name := 'd' || SUBSTR (p_tab, 2);
        END;
    ELSE
    	IF p_tab_type = 'METER' THEN
			BEGIN
			partition_by_clause := 'partition by LIST (id_partition)';

			SELECT MAX(current_id_partition) INTO current_id_part FROM t_archive_queue_partition;
			def_prtn_condition := '(' || current_id_part || ')';
			def_partn_name := 'p' || current_id_part;
			END;
		ELSE
			raise_application_error (-20000, '"p_tab_type" input parameter may take only 2 values: "USAGE" or "METER"');
		END IF;
    END IF;

    /* 1. Gather ddl commands for partition table conversion      2. Execute ddl   */
    /* For Usage Partitioning:
    * Get the 'create table' ddl         Create DDL:         create table p_acc_usage           partition by range (id_usage_interval) (             partition d_acc_usage values less than (9999999999)             )                  Oracle defines range partitions using:            VALUES LESS THAN (<rangespec>)            The <rangespec> is one more than the value in id_interval_end        in t_partition for that partition and 9999999999 if it's the
    default partition.
    */

   /* ddl for partitioned table with default partition only */
   partn_ddl :=
         '  create table '
      || partn_tab
      || nlt
      || partition_by_clause || ' ('
      || nlt
      || '    partition '
      || def_partn_name
      || ' values ' || def_prtn_condition || ')'
      || nlt
      || '  as select * from '
      || p_tab
      || ' where 1=0';
   /* ddl for exchange partition operation. the real convert step. */
   exchg_ddl :=
         'alter table '
      || partn_tab
      || ' exchange partition '
      || def_partn_name
      || ' with table '
      || p_tab;

   /* Get primary key constraint ddl from source table */
   SELECT      'alter table '
            || partn_tab
            || ' add constraint '
            || constraint_name
            || ' primary key ('
			|| LISTAGG (column_name, ',') WITHIN GROUP (ORDER BY POSITION)
            || ')'
            || ' using index (create index '
            || constraint_name
            || ' on '
            || partn_tab
            || ' ('
			|| LISTAGG (column_name, ',') WITHIN GROUP (ORDER BY POSITION)
            || ') local)',                  /* todo: logging or nologging ? */
               'alter table '
            || table_name
            || ' drop constraint '
            || constraint_name
   BULK COLLECT INTO cons_ddl,
            cons_drop
       FROM (SELECT   uc.table_name, uc.constraint_name, uc.constraint_type,
                      column_name, POSITION
                 FROM user_cons_columns ucc JOIN user_constraints uc
                      ON uc.constraint_name = ucc.constraint_name
                WHERE constraint_type = 'P'
                  AND LOWER (uc.table_name) = LOWER (p_tab)
             ORDER BY POSITION)
   GROUP BY table_name, constraint_name;

   /* Get unique constraint ddl from source table */
   SELECT      'alter table '
            || partn_tab
            || ' add constraint '
            || constraint_name
            || ' unique ('
			|| LISTAGG (column_name, ',') WITHIN GROUP (ORDER BY POSITION)
            || ')'
            || ' disable',                  /* todo: logging or nologging ? */
               'alter table '
            || table_name
            || ' drop constraint '
            || constraint_name
   BULK COLLECT INTO cons_ddl1,
            cons_drop1
       FROM (SELECT   uc.table_name, uc.constraint_name, uc.constraint_type,
                      column_name, POSITION
                 FROM user_cons_columns ucc JOIN user_constraints uc
                      ON uc.constraint_name = ucc.constraint_name
                WHERE constraint_type = 'U'
                  AND LOWER (uc.table_name) = LOWER (p_tab)
             ORDER BY POSITION)
   GROUP BY table_name, constraint_name;

   /* Get ddl for non-unique indexes on source table. */
   SELECT      'create index '
            || index_name
            || ' on '
            || partn_tab
            || ' ('
			|| LISTAGG (column_name, ',') WITHIN GROUP (ORDER BY column_position)
            || ') local ',                  /* todo: logging or nologging ? */
            'drop index ' || index_name
   BULK COLLECT INTO idx_ddl,
            idx_drop
       FROM (SELECT   uic.table_name, uic.index_name, column_name,
                      column_position
                 FROM user_ind_columns uic JOIN user_indexes ui
                      ON uic.index_name = ui.index_name
                    AND ui.uniqueness = 'NONUNIQUE'
                WHERE LOWER (uic.table_name) = LOWER (p_tab)
             ORDER BY uic.table_name, uic.column_position, uic.index_name)
   GROUP BY table_name, index_name;

   /* CORE-6638. Some workaround about this issue. */
   /* Get default constraint ddl from source table */
   /*
   SELECT      'ALTER TABLE '
            || partn_tab
            || ' MODIFY '
            || COLUMN_NAME
            || ' DEFAULT '
            || DATA_DEFAULT  -- an error here. Long should be converted to varchar
   BULK COLLECT INTO def_cons_ddl1
       FROM (
            SELECT COLUMN_NAME,
                    DATA_DEFAULT
            FROM   USER_TAB_COLUMNS
            WHERE  LOWER(TABLE_NAME) = LOWER(p_tab)
       );
    */


   /* Collected all the ddl statements we need, time to exec.

       1. Create new partitioned table with default partition only.
       2. Drop constraints from old table.
       3. Add constraints to new table (disabled)
       4. Exchange old table with the default partition
       5. Drop old table, rename new to old

   */

   /* Create new partitioned table with default partition only. */
   DBMS_OUTPUT.put_line ( 'prtn_deploy_table: Creating partitioned table '
                         || partn_tab );
   DBMS_OUTPUT.put_line (partn_ddl);

   EXECUTE IMMEDIATE partn_ddl;

   /* Drop constraints from old table. */
   DBMS_OUTPUT.put_line
               ('prtn_deploy_table: Dropping primary key/unique constraints');

   IF cons_drop.FIRST IS NOT NULL
   THEN
      FOR ix IN cons_drop.FIRST .. cons_drop.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || cons_drop (ix));

         EXECUTE IMMEDIATE cons_drop (ix);
      END LOOP;
   END IF;

   IF cons_drop1.FIRST IS NOT NULL
   THEN
      FOR ix IN cons_drop1.FIRST .. cons_drop1.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || cons_drop1 (ix));

         EXECUTE IMMEDIATE cons_drop1 (ix);
      END LOOP;
   END IF;

   DBMS_OUTPUT.put_line ('prtn_deploy_table: Dropping non-unique indexes');

   IF idx_drop.FIRST IS NOT NULL
   THEN
      FOR ix IN idx_drop.FIRST .. idx_drop.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || idx_drop (ix));

         EXECUTE IMMEDIATE idx_drop (ix);
      END LOOP;
   END IF;

   /* Add primary key/unqiue constraints  in disabled mode to avoid
      validation during exchange operation.  No need to build the
      underlying indexes at this moment. */
   DBMS_OUTPUT.put_line
      ('prtn_deploy_table: Adding primary key/unique constraints (disabled)');

   IF cons_ddl.FIRST IS NOT NULL
   THEN
      FOR ix IN cons_ddl.FIRST .. cons_ddl.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || cons_ddl (ix));

         EXECUTE IMMEDIATE cons_ddl (ix);
      END LOOP;
   END IF;

   IF cons_ddl1.FIRST IS NOT NULL
   THEN
      FOR ix IN cons_ddl1.FIRST .. cons_ddl1.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || cons_ddl1 (ix));

         EXECUTE IMMEDIATE cons_ddl1 (ix);
      END LOOP;
   END IF;

   /* Add non-unique local indexes
   */
   DBMS_OUTPUT.put_line
                     ('prtn_deploy_table: Creating non-unique local indexes');

   IF idx_ddl.FIRST IS NOT NULL
   THEN
      FOR ix IN idx_ddl.FIRST .. idx_ddl.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || idx_ddl (ix));

         EXECUTE IMMEDIATE idx_ddl (ix);
      END LOOP;
   END IF;

	IF p_tab_type = 'METER' THEN
		/* Add DEFAULT constraint 'id_partition' column for METER tables
		*/
		DBMS_OUTPUT.put_line('prtn_deploy_table: Apply DEFAULT constraint "id_partition" column');

		EXECUTE IMMEDIATE 'ALTER TABLE ' || partn_tab
						|| ' MODIFY id_partition'
						|| ' DEFAULT ' || current_id_part;
	END IF;

   DBMS_OUTPUT.put_line (   'prtn_deploy_table: Exchanging '
                         || p_tab
                         || ' and default partition'
                        );
   DBMS_OUTPUT.put_line ('  ' || exchg_ddl);

   EXECUTE IMMEDIATE exchg_ddl;

   /* Partiton table is created and loaded. Drop the old and rename new.
   */
   DBMS_OUTPUT.put_line ('prtn_deploy_table: Dropping table ' || p_tab);

   EXECUTE IMMEDIATE 'drop table ' || p_tab || ' cascade constraints purge';

   DBMS_OUTPUT.put_line ( 'prtn_deploy_table: Renaming ' || partn_tab
                         || ' to ' || p_tab );

   EXECUTE IMMEDIATE 'alter table ' || partn_tab || ' rename to ' || p_tab;

END prtn_deploy_table;
/

ALTER PROCEDURE rebuildglobalindexes COMPILE ;

ALTER PROCEDURE rebuildlocalindexparts COMPILE ;

ALTER PROCEDURE altertableuniqueconstraints COMPILE ;

CREATE OR REPLACE PROCEDURE prtn_deploy_serv_def_table(
    p_tab               VARCHAR2
)
authid CURRENT_USER
AS
    is_not_partitioned  INT;  /* is table not partitioned yet? */
    current_id_part     INT;
    is_part_enabled     VARCHAR2(1);
BEGIN

    SELECT UPPER(b_partitioning_enabled) INTO is_part_enabled FROM t_usage_server;
    /* Nothing to do if system isn't enabled for partitioning */
    IF is_part_enabled <> 'Y' THEN
        dbms_output.put_line('System not enabled for partitioning.');
        RETURN;
    END IF;

    /* If the table is not yet parititoned, then this a conversion */
    SELECT COUNT(1) INTO is_not_partitioned
    FROM   dual
    WHERE  NOT EXISTS (
               SELECT 1
               FROM   user_part_tables
               WHERE  UPPER(table_name) = UPPER(p_tab)
           );

    IF is_not_partitioned = 1 THEN

        /* Do the converstion.  Only once per table.
        When this call completes the table will be partitioned with
        a default paritions only.  The split op still has to be done. */
        prtn_deploy_table(
            p_tab => p_tab,
            p_tab_type => 'METER');

        /* Rebuild UNUSABLE global indexes */
        RebuildGlobalIndexes(p_tab);

        /* Rebuild UNUSABLE local index partitions. */
        RebuildLocalIndexParts(p_tab);

        /* Enable all unique constraints (that are DISABLED) */
        AlterTableUniqueConstraints(p_tab, 'enable');

        dbms_output.put_line('First partition was created for "' || p_tab || '" with current id_partition = ' || current_id_part);

    END IF;

END prtn_deploy_serv_def_table;
/

ALTER PROCEDURE extendpartitionedtable COMPILE ;

CREATE OR REPLACE PROCEDURE prtn_deploy_usage_table(
	p_tab		VARCHAR2
)
authid current_user
AS
	cnt			INT;
	rowcnt		INT;
	defdb		VARCHAR2(30);	/* default part info */
	defstart	INT;
	defend		INT;
	isconv		INT;			/* Is table corrently not under partition? (Should be converted) */
BEGIN

	/* Nothing to do if system isn't enabled for partitioning */
	IF dbo.isSystemPartitioned() = 0 THEN
		dbms_output.put_line('System not enabled for partitioning.');
		RETURN;
	END IF;

	/* Count active partitions. */
	SELECT COUNT(1) INTO cnt
	FROM   t_partition
	WHERE  b_active = 'Y';

	IF (cnt < 2) THEN
		raise_application_error(-20000, 'Found '|| cnt ||' active partitions. Expected at least 2 (including default).');
	END IF;
  
	/* Make sure there's only one default partition. */
	SELECT COUNT(1) INTO cnt
	FROM   t_partition
	WHERE  b_default = 'Y' AND b_active = 'Y';

	IF (cnt != 1) THEN
		raise_application_error(-20000,'Found ' || cnt || ' default partitions. Expected one.');
	END IF;

	/* If the table is not yet parititoned, then this a conversion */
	SELECT COUNT(1) INTO isconv
	FROM   dual
	WHERE  NOT EXISTS (
				SELECT 1
				FROM   user_part_tables
				WHERE  UPPER(table_name) = UPPER(p_tab));

	IF isconv = 1 THEN
		/* Do the converstion.  Only once per table.
		When this call completes the table will be partitioned with
		a default paritions only.  The split op still has to be done. */
		prtn_deploy_table(
			p_tab => p_tab,
			p_tab_type => 'USAGE');
	END IF;

	/* Add as many partitions as needed. */
	ExtendPartitionedTable(p_tab);

	/* Rebuild UNUSABLE global indexes */
	RebuildGlobalIndexes(p_tab);

	/* Rebuild UNUSABLE local index partitions. */
	RebuildLocalIndexParts(p_tab);

	/* Enable all unique constraints (that are DISABLED) */
	AlterTableUniqueConstraints(p_tab, 'enable');

END prtn_deploy_usage_table;
/

CREATE PROCEDURE CREATE_PARTITIONS_NAMESPACE(
	 v_namespace 		VARCHAR2
	,v_namespaceDescription 	VARCHAR2
	,v_method       		VARCHAR2
	,v_namespaceType 	VARCHAR2
	,v_invoicePrefix 	VARCHAR2
	,v_invoiceSuffix     	VARCHAR2
	,v_invoiceNumDigits 	int
	,v_invoiceDueDateOffset	int
	,v_invoiceNumLast 	int
	,v_accountNamespace 		VARCHAR2
	,v_namespaceInsertCount OUT int
	,v_invoiceNamespaceInsertCount OUT int
    ,v_errorNumber OUT int
	,v_errorMessage OUT VARCHAR2)
AS
v_total_rows_t_namespace INT;
v_total_rows_t_invoice_n INT;
v_total_rows_t_account_mapper INT;
BEGIN

 v_errorNumber := 0;
 v_errorMessage := '';
 v_namespaceInsertCount := 0;
 v_invoiceNamespaceInsertCount := 0;

 -- check that namespace of partition account corresponds to namespace of root account
SELECT count(*) INTO v_total_rows_t_account_mapper  FROM t_account_mapper WHERE id_acc = 1 AND nm_space = v_accountNamespace;

IF (v_total_rows_t_account_mapper=0) THEN
  v_namespaceInsertCount := -1;
  v_invoiceNamespaceInsertCount := -1;
  v_errorNumber := -486604800;
  v_errorMessage := 'Branded Site of partition account should be MetraTech Sample Site';
ELSE
 select count(*) INTO v_total_rows_t_namespace from t_namespace where nm_space = v_namespace;

  if (v_total_rows_t_namespace=0) THEN
    BEGIN
      insert into t_namespace (nm_space, tx_desc, nm_method, tx_typ_space)
      values (LOWER(v_namespace), v_namespaceDescription, v_method, v_namespaceType);
    
      v_namespaceInsertCount := 1;
    EXCEPTION
    WHEN others THEN
      v_namespaceInsertCount := -1;
      v_errorNumber := SQLCODE;
      v_errorMessage := SUBSTR(SQLERRM, 1, 200);
    END;
  END IF;

 select count(*) INTO v_total_rows_t_invoice_n  from t_invoice_namespace t_in where t_in.namespace = v_namespace;
 
  if (v_total_rows_t_invoice_n=0) THEN
    BEGIN
      insert into t_invoice_namespace
             (namespace,  invoice_prefix, invoice_suffix, invoice_num_digits, invoice_due_date_offset, id_invoice_num_last)
      values (LOWER(v_namespace), v_invoicePrefix, v_invoiceSuffix, v_invoiceNumDigits,  v_invoiceDueDateOffset, v_invoiceNumLast);
  
      v_invoiceNamespaceInsertCount := 1;
    EXCEPTION
    WHEN others THEN
      v_invoiceNamespaceInsertCount := -1;
      v_errorNumber := SQLCODE;
      v_errorMessage := SUBSTR(SQLERRM, 1, 200);
    END;
  END IF;
END IF;
END;
/

CREATE OR REPLACE procedure GetICBMappingForSub
					(p_id_paramtable int,
					 p_id_pi_instance int,
					 p_id_sub int,
					 p_p_systemdate timestamp,
					 p_status out int,
					 p_id_pricelist out int )
				as
					l_id_pi_type int;
					l_id_pi_template int;
					l_id_pi_instance_parent int;
					l_currency varchar2(10);
					l_id_po int;
					l_id_defaultpl int;
					l_id_partition int;
				BEGIN
					p_status := 0;
					
					select id_pi_type, id_pi_template, id_pi_instance_parent
					into l_id_pi_type, l_id_pi_template, l_id_pi_instance_parent
					from
					t_pl_map where id_pi_instance = p_id_pi_instance AND id_paramtable is NULL;

					/*CR 10884 fix: get the price list currency from product catalog, not
					  corporation. This will take care of the case when gsubs are generated "globally".
					  Also, this seems to be correct for all other cases as well */
					
					select pl.nm_currency_code, po.id_po, po.c_POPartitionId
					into l_currency, l_id_po, l_id_partition
					from
						t_po po
						inner join
						t_pricelist pl on po.id_nonshared_pl = pl.id_pricelist
						inner join
						t_sub s on po.id_po = s.id_po
					where s.id_sub = p_id_sub;

					BEGIN
						/* Select to see if a pricelist mapping exists */
						select id_pricelist into p_id_pricelist from t_pl_map
								where id_sub = p_id_sub and id_pi_instance = p_id_pi_instance and
										id_paramtable = p_id_paramtable;
										
					EXCEPTION
						WHEN NO_DATA_FOUND THEN
						
							BEGIN
								select id_pricelist into l_id_defaultpl from t_pl_map where
									id_po = l_id_po and id_pi_instance = p_id_pi_instance and
									id_paramtable = p_id_paramtable and
									id_sub is null and id_acc is null and
									B_CANICB = 'Y';
							EXCEPTION
								WHEN NO_DATA_FOUND THEN
									p_status := -10;
									return;
							END;
							
							insert into t_base_props (id_prop, n_kind,n_name,n_display_name,n_desc)
								values (seq_t_base_props.nextval, 150,0,0,0);

							select seq_t_base_props.currval into p_id_pricelist from dual;
							
							insert into t_pricelist(id_pricelist, n_type, nm_currency_code, c_PLPartitionId)
								values (p_id_pricelist, 0, l_currency, l_id_partition);
							
							insert into t_pl_map(
							  id_paramtable,
							  id_pi_type,
							  id_pi_instance,
							  id_pi_template,
							  id_pi_instance_parent,
							  id_sub,
							  id_po,
							  id_pricelist,
							  b_canICB,
							  dt_modified
							  )
									values(
							  p_id_paramtable,
							  l_id_pi_type,
							  p_id_pi_instance,
							  l_id_pi_template,
							  l_id_pi_instance_parent,
							  p_id_sub,
							  l_id_po,
							  p_id_pricelist,
							  'N',
							  p_p_systemdate
							  );
					END;
				END;
/

CREATE OR REPLACE PROCEDURE updatebatchstatus (
   tx_batch           IN   RAW,
   tx_batch_encoded   IN   VARCHAR2,
   n_completed        IN   INT,
   sysdate_           IN   DATE
)
AS
   tx_batch_           RAW (255)      := tx_batch;
   tx_batch_encoded_   VARCHAR2 (24)  := tx_batch_encoded;
   n_completed_        NUMBER (10, 0) := n_completed;
   sysdate__           DATE           := sysdate_;
   stoo_selcnt         INTEGER;
   initialstatus       CHAR (1);
   finalstatus         CHAR (1);

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
      stoo_selcnt := 0;

      SELECT count(1)
        INTO stoo_selcnt
                    FROM t_batch
                   WHERE tx_batch =
                                           hextoraw(updatebatchstatus.tx_batch_)
                                           ;
   IF stoo_selcnt = 0
   THEN
      INSERT INTO t_batch
                  (id_batch, tx_namespace,
                   tx_name,
                   tx_batch,
                   tx_batch_encoded, tx_status, n_completed, n_failed,
                   dt_first, dt_crt
                  )
           VALUES (seq_t_batch.NEXTVAL, 'pipeline',
                   updatebatchstatus.tx_batch_encoded_,
                   updatebatchstatus.tx_batch_,
                   updatebatchstatus.tx_batch_encoded_, 'A', 0, 0,
                   updatebatchstatus.sysdate__, updatebatchstatus.sysdate__
                  );
   END IF;

   SELECT tx_status into initialstatus
                 FROM t_batch
                WHERE tx_batch= hextoraw(updatebatchstatus.tx_batch_)
                for update;

   UPDATE t_batch
      SET t_batch.n_completed =
                          t_batch.n_completed + updatebatchstatus.n_completed_,
          t_batch.tx_status =
             CASE
                WHEN (   (  t_batch.n_completed
                          + t_batch.n_failed
                          + nvl(t_batch.n_dismissed, 0)
                          + updatebatchstatus.n_completed_
                         ) = t_batch.n_expected
                      OR (    ((  t_batch.n_completed
                                + t_batch.n_failed
                                + nvl(t_batch.n_dismissed, 0)
                                + updatebatchstatus.n_completed_
                               ) = t_batch.n_metered
                              )
                          AND t_batch.n_expected = 0
                         )
                     )
                   THEN 'C'
                WHEN (   (  t_batch.n_completed
                          + t_batch.n_failed
                          + nvl(t_batch.n_dismissed, 0)
                          + updatebatchstatus.n_completed_
                         ) < t_batch.n_expected
                      OR (    ((  t_batch.n_completed
                                + t_batch.n_failed
                                + nvl(t_batch.n_dismissed, 0)
                                + updatebatchstatus.n_completed_
                               ) < t_batch.n_metered
                              )
                          AND t_batch.n_expected = 0
                         )
                     )
                   THEN 'A'
                WHEN ((  t_batch.n_completed
                       + t_batch.n_failed
                       + nvl(t_batch.n_dismissed, 0)
                       + updatebatchstatus.n_completed_
                      ) > t_batch.n_expected
                     )
                AND t_batch.n_expected > 0
                   THEN 'F'
                ELSE t_batch.tx_status
             END,
          t_batch.dt_last = updatebatchstatus.sysdate__,
          t_batch.dt_first =
             CASE
                WHEN t_batch.n_completed = 0
                   THEN updatebatchstatus.sysdate__
                ELSE t_batch.dt_first
             END
    WHERE tx_batch = hextoraw(updatebatchstatus.tx_batch_);

   SELECT tx_status into finalstatus
                 FROM t_batch
                WHERE tx_batch = hextoraw(updatebatchstatus.tx_batch_);
				 COMMIT;
END updatebatchstatus;
/

CREATE PROCEDURE CreateAnalyticsDataMart (
   p_dt_now           DATE,
   p_id_run           NUMBER,
   p_nm_currency      NVARCHAR2,
   p_nm_instance      NVARCHAR2,
   p_n_months         NUMBER,
   p_STAGINGDB_prefix VARCHAR2)
   AUTHID CURRENT_USER
AS
    /* >>>>> WORK IN PROGRESS <<<<< -- SInsero */
    /* Variables for log_details */
    v_debug_level    PLS_INTEGER := 1; /* 0=Info, 1=Debug, 2=Trace */
    v_TBD_BYPASS     BOOLEAN := TRUE;
    v_debug_hdr      VARCHAR2(31) := 'CreateAnalyticsDataMart:';
    /* General Variables */
    v_count             PLS_INTEGER;
    v_tmp_tbl           VARCHAR2(61); /* 30 plus dot plus 30 */
    v_sql               VARCHAR2(4000);
    v_tmp_tbl_options   VARCHAR2(1000);
    /* Variable for MetraTime conversion */
    v_dt_start_utc   DATE;
    v_dt_start_mt    DATE; /* MetraTime Start time */
   /* Table names in variables to make changing them easier. */
    /* Use Dynamic SQL with these tables. */
    v_tbl_Customer                 VARCHAR2(30) := UPPER('Customer');
    v_tbl_SalesRep                 VARCHAR2(30) := UPPER('SalesRep');
    v_tbl_SubscriptionByMonth      VARCHAR2(30) := UPPER('SubscriptionByMonth');
    v_tbl_Subscription             VARCHAR2(30) := UPPER('Subscription');
    v_tbl_SubscriptionPrice        VARCHAR2(30) := UPPER('SubscriptionPrice');
    v_tbl_SubscriptionUnits        VARCHAR2(30) := UPPER('SubscriptionUnits');
    v_tbl_SubscriptionSummary      VARCHAR2(30) := UPPER('SubscriptionSummary');
    v_tbl_Counters                 VARCHAR2(30) := UPPER('Counters');
    v_tbl_CurrencyExchangeMonthly  VARCHAR2(30) := UPPER('CurrencyExchangeMonthly');
    v_tbl_ProductOffering          VARCHAR2(30) := UPPER('ProductOffering');
    /* Local function for logging */
    PROCEDURE log_details (p_tx_type VARCHAR2, p_tx_detail NVARCHAR2)
    IS
     PRAGMA AUTONOMOUS_TRANSACTION;
     v_logit      BOOLEAN := TRUE;
     v_len        PLS_INTEGER;
     v_tx_detail  NVARCHAR2(2000);
     v_tx_type    t_recevent_run_details.tx_type%TYPE;
    BEGIN
     /* Trace gets stored as Debug in the DB */
     v_tx_type := p_tx_type;
     CASE
       WHEN p_id_run IS NULL THEN v_logit := FALSE;
       WHEN p_tx_type = 'Debug' AND v_debug_level <  1 THEN v_logit := FALSE;
       WHEN p_tx_type = 'Trace' AND v_debug_level <  2 THEN v_logit := FALSE;
       WHEN p_tx_type = 'Trace' AND v_debug_level >= 2 THEN v_tx_type := 'Debug';
       ELSE v_logit := TRUE;
     END CASE;
     IF (v_logit) THEN
       IF (LENGTH(v_debug_hdr || p_tx_detail) > 2000) THEN
        /* Make all 2 spaces into a single space to compact */
        v_tx_detail := REGEXP_REPLACE(v_debug_hdr || p_tx_detail,'( ){2,}', ' ');
        v_tx_detail := RTRIM(v_tx_detail, 2000);
       ELSE
        v_tx_detail := v_debug_hdr || p_tx_detail;
       END IF;
       INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
       VALUES (seq_t_recevent_run_details.NEXTVAL, p_id_run,v_tx_type,
        v_tx_detail,
        DBO.GETUTCDATE () - v_dt_start_utc + v_dt_start_mt
       );
     END IF;
     COMMIT; /* AUTONOMOUS_TRANSACTION must COMMIT/ROLLBACK before exiting */
    END log_details;
BEGIN
  /* This PROC has multiple COMMITs. It is not a single transaction. */
  /* However, the DELETE from the permanent Datamart tables,         */
  /* and the subsequent INSERT operations, will be part of one BIG   */
  /* transaction. This is basically a Full Refresh.                  */

  /* Get the DB UTC date so we can calculate the MetraTime offset */
  v_dt_start_utc := DBO.GETUTCDATE ();
  /* Default to now if MetraTime (p_dt_now) is not passed in */
  v_dt_start_mt := COALESCE (p_dt_now, v_dt_start_utc);
  /* Above vt_dt variables need to be set before log_details is called. */
  log_details('Debug', 'Proc started');
  log_details('Debug', '>>>>> WORK IN PROGRESS <<<<< -- SInsero'); /* TBD: Remove when finished */

 /* ===== Generating Customers DataMart ===== */
  log_details('Info',  'Generating Customers DataMart started');

  v_tmp_tbl_options := 'NOLOGGING PCTFREE 0';

  /* TBD: tmp tables should have PK, indexes, and statistics generated. */

  /* Generate tmp_adm_corps */
  v_tmp_tbl := UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_corps');
  IF (TABLE_EXISTS(v_tmp_tbl)) THEN
    EXEC_DDL('TRUNCATE TABLE ' || v_tmp_tbl);
    log_details('Debug', 'Truncated tmp table : ' || v_tmp_tbl);
  ELSE
    v_sql :=
      'CREATE TABLE ' || v_tmp_tbl || ' ('        || CHR(10) ||
      ' ID_ANCESTOR      NUMBER(10)    NOT NULL,' || CHR(10) ||
      ' ID_DESCENDENT    NUMBER(10)    NOT NULL,' || CHR(10) ||
      ' NUM_GENERATIONS  NUMBER(10)    NOT NULL ' || CHR(10) ||
      ') ' || v_tmp_tbl_options
      ;
    log_details('Trace', v_sql);
    EXECUTE IMMEDIATE v_sql;
    log_details('Info', 'Created tmp table : ' || v_tmp_tbl);
  END IF;

  v_sql :=
  'INSERT /*+ APPEND */ INTO ' || v_tmp_tbl                                             || CHR(10) ||
  '      (ID_ANCESTOR, ID_DESCENDENT, NUM_GENERATIONS)                                ' || CHR(10) ||
  'SELECT ID_ANCESTOR, ID_DESCENDENT, NUM_GENERATIONS                                 ' || CHR(10) ||
  'FROM (                                                                             ' || CHR(10) ||
  '  with root_accts as                                                               ' || CHR(10) ||
  '  (                                                                                ' || CHR(10) ||
  '    select /* corporate accounts */                                                ' || CHR(10) ||
  '    a.id_acc                                                                       ' || CHR(10) ||
  '    from t_account a                                                               ' || CHR(10) ||
  '    inner join t_account_type t on t.id_type = a.id_type                           ' || CHR(10) ||
  '    where 1=1                                                                      ' || CHR(10) ||
  '    and t.b_iscorporate = 1                                                        ' || CHR(10) ||
  '    and t.b_isvisibleinhierarchy = 1                                               ' || CHR(10) ||
  '  )                                                                                ' || CHR(10) ||
  '  select /*+ ORDERED */                                                            ' || CHR(10) ||
  '  r.id_acc id_ancestor, aa.id_descendent, aa.num_generations                       ' || CHR(10) ||
  '  from root_accts r                                                                ' || CHR(10) ||
  '  inner join t_account_ancestor aa on aa.id_ancestor = r.id_acc                    ' || CHR(10) ||
  '        and :B1 between aa.vt_start and aa.vt_end                                  ' || CHR(10) ||
  '  where 1=1                                                                        ' || CHR(10) ||
  ')                                                                                  '
  ;

  log_details('Trace', v_sql);
  EXECUTE IMMEDIATE v_sql USING v_dt_start_mt;
  v_count := SQL%ROWCOUNT;

  log_details('Debug', 'Found Corporate Accounts : ' || v_count);
  COMMIT;

  /* Generate tmp_adm_accs */
  v_tmp_tbl := UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_accs');
  IF (TABLE_EXISTS(v_tmp_tbl)) THEN
    EXEC_DDL('TRUNCATE TABLE ' || v_tmp_tbl);
    log_details('Debug', 'Truncated tmp table : ' || v_tmp_tbl);
  ELSE
    v_sql :=
      'CREATE TABLE ' || v_tmp_tbl || ' ('        || CHR(10) ||
      ' ID_ANCESTOR      NUMBER(10)    NOT NULL,' || CHR(10) ||
      ' ID_DESCENDENT    NUMBER(10)    NOT NULL ' || CHR(10) ||
      ') ' || v_tmp_tbl_options
      ;
    log_details('Trace', v_sql);
    EXECUTE IMMEDIATE v_sql;
    log_details('Info', 'Created tmp table : ' || v_tmp_tbl);
  END IF;

  v_sql :=
  'INSERT /*+ APPEND */ INTO ' || v_tmp_tbl                                             || CHR(10) ||
  '      (ID_ANCESTOR, ID_DESCENDENT)                                                 ' || CHR(10) ||
  'SELECT ID_ANCESTOR, ID_DESCENDENT                                                  ' || CHR(10) ||
  'FROM (                                                                             ' || CHR(10) ||
  'with my_gens as                                                                    ' || CHR(10) ||
  '(                                                                                  ' || CHR(10) ||
  '  select                                                                           ' || CHR(10) ||
  '  id_descendent, max(num_generations) num_generations                              ' || CHR(10) ||
  '  from ' || UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_corps')  || '        ' || CHR(10) ||
  '  group by id_descendent                                                           ' || CHR(10) ||
  ')                                                                                  ' || CHR(10) ||
  'select                                                                             ' || CHR(10) ||
  'max(a.id_ancestor) id_ancestor, a.id_descendent                                    ' || CHR(10) ||
  'from ' || UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_corps')  || ' a        ' || CHR(10) ||
  'inner join my_gens g on a.id_descendent = g.id_descendent                          ' || CHR(10) ||
  'and a.num_generations = g.num_generations                                          ' || CHR(10) ||
  'where 1=1                                                                          ' || CHR(10) ||
  'group by a.id_descendent                                                           ' || CHR(10) ||
  ')                                                                                  '
  ;

  log_details('Trace', v_sql);
  EXECUTE IMMEDIATE v_sql;
  v_count := SQL%ROWCOUNT;

  log_details('Debug', 'Found Corporate Hierarchy Accounts : ' || v_count);
  COMMIT;

  v_sql :=
  'INSERT /*+ APPEND */ INTO ' || v_tmp_tbl                                             || CHR(10) ||
  '      (ID_ANCESTOR, ID_DESCENDENT)                                                 ' || CHR(10) ||
  'SELECT ID_ANCESTOR, ID_DESCENDENT                                                  ' || CHR(10) ||
  'FROM (                                                                             ' || CHR(10) ||
  'with root_accts as                                                                 ' || CHR(10) ||
  '(                                                                                  ' || CHR(10) ||
  '  select /*+ ORDERED */                                                            ' || CHR(10) ||
  '  aa.id_descendent id_acc                                                          ' || CHR(10) ||
  '  from t_account_ancestor aa                                                       ' || CHR(10) ||
  '  inner join t_account a  on a.id_acc = aa.id_descendent                           ' || CHR(10) ||
  '  inner join t_account_type t  on t.id_type = a.id_type                            ' || CHR(10) ||
  '  and (t.b_iscorporate = 0 or t.b_isvisibleinhierarchy = 0)                        ' || CHR(10) ||
  '  where 1=1                                                                        ' || CHR(10) ||
  '  and :B1 between aa.vt_start and aa.vt_end                                        ' || CHR(10) ||
  '  and aa.id_ancestor = 1                                                           ' || CHR(10) ||
  '  and aa.num_generations = 1                                                       ' || CHR(10) ||
  '  and aa.b_children = ''Y''                                                        ' || CHR(10) ||
  ')                                                                                  ' || CHR(10) ||
  'select                                                                             ' || CHR(10) ||
  'r.id_acc id_ancestor, aa.id_descendent                                             ' || CHR(10) ||
  'from root_accts r                                                                  ' || CHR(10) ||
  'inner join t_account_ancestor aa  on aa.id_ancestor = r.id_acc                     ' || CHR(10) ||
  'and :B2 between aa.vt_start and aa.vt_end                                          ' || CHR(10) ||
  'left outer join                                                                    ' || CHR(10) ||
  ' ' || UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_accs') || ' a              ' || CHR(10) ||
  'on aa.id_descendent = a.id_descendent                                              ' || CHR(10) ||
  'where 1=1                                                                          ' || CHR(10) ||
  'and a.id_descendent is null                                                        ' || CHR(10) ||
  ')                                                                                  '
  ;

  log_details('Trace', v_sql);
  EXECUTE IMMEDIATE v_sql USING v_dt_start_mt, v_dt_start_mt;
  v_count := SQL%ROWCOUNT;

  log_details('Debug', 'Added Non-Corporate Hierarchy Accounts : ' || v_count);
  COMMIT;

  v_sql :=
  'INSERT /*+ APPEND */ INTO ' || v_tmp_tbl                                 || CHR(10) ||
  '      (ID_ANCESTOR, ID_DESCENDENT)                                     ' || CHR(10) ||
  'select a.id_acc,    a.id_acc                                           ' || CHR(10) ||
  'from t_account a                                                       ' || CHR(10) ||
  'left outer join ' || v_tmp_tbl || ' b on a.id_acc = b.id_descendent    ' || CHR(10) ||
  'inner join t_account_ancestor aa  on aa.id_descendent = a.id_acc       ' || CHR(10) ||
  'and :B1 between aa.vt_start and aa.vt_end                              ' || CHR(10) ||
  'and aa.id_ancestor = 1 and aa.num_generations > 0                      ' || CHR(10) ||
  'where 1=1                                                              ' || CHR(10) ||
  'and b.id_descendent is null                                            '
  ;

  log_details('Trace', v_sql);
  EXECUTE IMMEDIATE v_sql USING v_dt_start_mt;
  v_count := SQL%ROWCOUNT;

  log_details('Debug', 'Added Non-Corporate Non-Hierarchy Accounts : ' || v_count);
  COMMIT;

  /* Generate tmp_adm_unrooted */
  v_tmp_tbl := UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_unrooted');
  IF (TABLE_EXISTS(v_tmp_tbl)) THEN
    EXEC_DDL('TRUNCATE TABLE ' || v_tmp_tbl);
    log_details('Debug', 'Truncated tmp table : ' || v_tmp_tbl);
  ELSE
    v_sql :=
      'CREATE TABLE ' || v_tmp_tbl || ' ('        || CHR(10) ||
      ' ID_ANCESTOR      NUMBER(10)    NOT NULL,' || CHR(10) ||
      ' ID_DESCENDENT    NUMBER(10)    NOT NULL,' || CHR(10) ||
      ' NUM_GENERATIONS  NUMBER(10)    NOT NULL ' || CHR(10) ||
      ') ' || v_tmp_tbl_options
      ;
    log_details('Trace', v_sql);
    EXECUTE IMMEDIATE v_sql;
    log_details('Info', 'Created tmp table : ' || v_tmp_tbl);
  END IF;

  v_sql :=
  'INSERT /*+ APPEND */ INTO ' || v_tmp_tbl                                 || CHR(10) ||
  '      (ID_ANCESTOR, ID_DESCENDENT, NUM_GENERATIONS)                    ' || CHR(10) ||
  'SELECT ID_ANCESTOR, ID_DESCENDENT, NUM_GENERATIONS                     ' || CHR(10) ||
  'FROM (                                                                 ' || CHR(10) ||
  'select                                                                 ' || CHR(10) ||
  'aa.id_ancestor, aa.id_descendent, aa.num_generations                   ' || CHR(10) ||
  'from t_account a                                                       ' || CHR(10) ||
  'left outer join                                                        ' || CHR(10) ||
   UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_accs') || ' b        ' || CHR(10) ||
  'on a.id_acc = b.id_descendent                                          ' || CHR(10) ||
  'inner join t_account_ancestor aa on aa.id_descendent = a.id_acc        ' || CHR(10) ||
  'and :B1 between aa.vt_start and aa.vt_end                              ' || CHR(10) ||
  'where 1=1                                                              ' || CHR(10) ||
  'and b.id_descendent is null                                            ' || CHR(10) ||
  ')                                                                      '
  ;

  log_details('Trace', v_sql);
  EXECUTE IMMEDIATE v_sql USING v_dt_start_mt;
  v_count := SQL%ROWCOUNT;

  log_details('Debug', 'Unrooted Accounts : ' || v_count);
  COMMIT;

  v_tmp_tbl := UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_accs');
  v_sql :=
  'INSERT /*+ APPEND */ INTO ' || v_tmp_tbl                                             || CHR(10) ||
  '      (ID_ANCESTOR, ID_DESCENDENT)                                                 ' || CHR(10) ||
  'SELECT ID_ANCESTOR, ID_DESCENDENT                                                  ' || CHR(10) ||
  'FROM (                                                                             ' || CHR(10) ||
  'with my_unrooted as                                                                ' || CHR(10) ||
  '(                                                                                  ' || CHR(10) ||
  '  select id_descendent, max(num_generations) num_generations                       ' || CHR(10) ||
  '  from ' || UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_unrooted') || '      ' || CHR(10) ||
  '  group by id_descendent                                                           ' || CHR(10) ||
  ')                                                                                  ' || CHR(10) ||
  'select                                                                             ' || CHR(10) ||
  'b.id_ancestor, b.id_descendent                                                     ' || CHR(10) ||
  'from my_unrooted a                                                                 ' || CHR(10) ||
  'inner join ' || UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_unrooted') || ' b' || CHR(10) ||
  'on a.id_descendent = b.id_descendent                                               ' || CHR(10) ||
  'and a.num_generations = b.num_generations                                          ' || CHR(10) ||
  'where 1=1                                                                          ' || CHR(10) ||
  ')                                                                                  '
  ;

  log_details('Trace', v_sql);
  EXECUTE IMMEDIATE v_sql;
  v_count := SQL%ROWCOUNT;

  log_details('Debug', 'Added Non-Rooted Accounts : ' || v_count);
  COMMIT;

  log_details('Info', 'Generating Customers DataMart ended');

 /* ===== Flush ===== */
 /* Flushing old DataMart, and refreshing with the new one, needs to be */
 /* one big transaction, for now. */

  log_details('Debug', 'Flush started');

  /* TRUNCATE commits, so must use DELETE here. */
  IF (NOT v_TBD_BYPASS) THEN
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_Customer;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_SalesRep;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_SubscriptionByMonth;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_Subscription;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_SubscriptionPrice;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_SubscriptionUnits;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_SubscriptionSummary;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_Counters;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_CurrencyExchangeMonthly;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_ProductOffering;
  END IF; /* v_TBD_BYPASS */

  log_details('Debug', 'Flush ended');

   /* ===== End ===== */

  log_details('Debug', 'Proc ended');
  COMMIT;

EXCEPTION
WHEN OTHERS THEN
  log_details('Info', 'Failed : ' || SQLCODE || ' : ' || SQLERRM);
  log_details('Info', DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
  ROLLBACK;
  RAISE;
END;
/

CREATE OR REPLACE PROCEDURE FILTERSORTQUERY_v3 (
             p_InnerQuery          NCLOB,
             p_OrderByText         VARCHAR2,
             p_StartRow            NUMBER,
             p_NumRows             NUMBER,
             p_TotalRows     OUT   sys_refcursor,
             p_Rows          OUT   sys_refcursor
          )
          AUTHID CURRENT_USER
	          AS
	             v_Sql                 VARCHAR2 (32767) := '';
	             v_InnerQueryString    VARCHAR2 (32767) := '';
	             v_offset                NUMBER := 1;
	             v_query_length          NUMBER;
	             v_buffer                VARCHAR2 (8191) := null;
	             v_block_length          NUMBER  := 8191;
	             v_EndRow                NUMBER;
	             v_OrderByText           VARCHAR2(4096);
	              
	          BEGIN
	             v_query_length := dbms_lob.getlength(p_InnerQuery);
	              
	             IF v_query_length > v_block_length
	             THEN
 
	                 while v_offset < v_query_length loop
	                       dbms_lob.read(p_InnerQuery, v_block_length, v_offset, v_buffer);
	                       v_InnerQueryString := v_InnerQueryString || v_buffer;
	                       v_offset := v_offset + v_block_length;
	                 end loop;
 
	             ELSE
 
	                 v_InnerQueryString := v_InnerQueryString || p_InnerQuery;
 
	             END IF;
	              
	             IF (p_OrderByText IS NULL) OR (LENGTH(p_OrderByText) = 0)
	             THEN
	                 v_OrderByText := 'ORDER BY 1'; /* Must have an ORDER BY for deterministic pagination results */
	             ELSE
	                 v_OrderByText := p_OrderByText;
	             END IF;
	              
	             /* Limit counting to the first 1000 rows for performance */
             /* Build like a paginated query, but for rows 1 to 1000, */
             /* and then wrap in the COUNT.                           */
             v_EndRow := 1000;
             v_Sql :=
                    'SELECT * FROM ( SELECT /*+ FIRST_ROWS('
                 || v_EndRow
                 || ') */ userquery.*, ROWNUM row_num FROM ('
                 || v_InnerQueryString
                 || ' '
                 || v_OrderByText
                 || ' ) userquery WHERE ROWNUM <= ' /* Must use the PSEUDOCOLUMN name here for STOPKEY optimization */
                 || v_EndRow
                 || ') abc WHERE row_num >= 1'      /* Must use the renamed PSEUDOCOLUMN here for > or >= operations */
                 ;
                 
             v_Sql := 'SELECT /*+ FIRST_ROWS(' || v_EndRow || ') */ COUNT(1) TotalRows FROM (' || CHR(10) ||
                      v_Sql                                                                    || CHR(10) ||
					            ') WHERE ROWNUM <= ' || v_EndRow;   /* Must use the PSEUDOCOLUMN name here */
 
	               
	             OPEN p_TotalRows FOR v_Sql;
	 
	             IF p_NumRows > 0
	             THEN
	               v_EndRow := p_StartRow + p_NumRows - 1;
	 
	               v_Sql :=
	                      'SELECT * FROM ( SELECT /*+ FIRST_ROWS('
	                   || v_EndRow
	                   || ') */ userquery.*, ROWNUM row_num FROM ('
	                   || v_InnerQueryString
	                   || ' '
	                   || v_OrderByText
	                   || ' ) userquery WHERE ROWNUM <= ' /* Must use the PSEUDOCOLUMN name here for STOPKEY optimization */
	                   || v_EndRow
	                   || ') abc WHERE row_num >= '       /* Must use the renamed PSEUDOCOLUMN here for > or >= operations */
	                   || p_StartRow;
	               ELSE
                  v_EndRow := 1000; /* Limit when selecting data for all rows */
	                v_Sql :=
	                      'SELECT * FROM ( SELECT userquery.*, ROWNUM row_num FROM ('
	                   || v_InnerQueryString
	                   || ' '
	                   || v_OrderByText
	                   || ' ) userquery WHERE ROWNUM <= '
                     || v_EndRow
                     || ') abc';
	             END IF;
	 
	             OPEN p_Rows FOR v_Sql;
	          END;
/

ALTER PROCEDURE updatepaymentrecord COMPILE ;

ALTER PROCEDURE moveaccount2 COMPILE ;

CREATE OR REPLACE procedure updateaccount (
p_loginname IN nvarchar2,
p_namespace IN nvarchar2,
p_id_acc IN int,
p_acc_state in varchar2,
p_acc_state_ext in int,
p_acc_statestart in date,
p_tx_password IN nvarchar2,
p_ID_CYCLE_TYPE IN integer,
p_DAY_OF_MONTH IN integer,
p_DAY_OF_WEEK IN integer,
p_FIRST_DAY_OF_MONTH IN integer,
p_SECOND_DAY_OF_MONTH IN integer,
p_START_DAY IN integer,
p_START_MONTH IN integer,
p_START_YEAR IN integer,
p_id_payer IN integer,
p_payer_login IN nvarchar2,
p_payer_namespace IN nvarchar2,
p_payer_startdate IN date,
p_payer_enddate IN date,
p_id_ancestor IN int,
p_ancestor_name IN nvarchar2,
p_ancestor_namespace IN nvarchar2,
p_hierarchy_movedate IN date,
p_systemdate IN date,
p_billable IN varchar2,
p_enforce_same_corporation varchar2,
p_account_currency nvarchar2,
p_status OUT int,
p_cyclechanged OUT int,
p_newcycle OUT int,
p_accountID OUT int,
p_hierarchy_path OUT varchar2,
p_old_id_ancestor_out OUT int ,
p_id_ancestor_out OUT int ,
p_corporate_account_id OUT int,
p_ancestor_type OUT varchar2,
p_acc_type out varchar2
)
as
accountID integer;
oldcycleID integer;
usagecycleID integer;
intervalenddate date;
intervalID integer;
pc_start date;
pc_end date;
oldpayerstart date;
oldpayerend date;
oldpayer integer;
payerenddate date;
payerID integer;
AncestorID integer;
payerbillable varchar2(1);
p_count integer;
begin
 accountID  := -1;
 oldcycleID := 0;
 p_status   := 0;

 p_ancestor_type := ' ';

 p_old_id_ancestor_out := p_id_ancestor;

 /* step : resolve the account if necessary*/
 if p_id_acc is NULL then
  if p_loginname is not NULL and p_namespace is not NULL then
    accountID := dbo.lookupaccount(p_loginname, p_namespace);
    if accountID < 0 then
        /* MTACCOUNT_RESOLUTION_FAILED*/
     p_status := -509673460;
    end if;
  else
   /* MTACCOUNT_RESOLUTION_FAILED*/
   p_status := -509673460;
  end if;
else
  accountID := p_id_acc;
end if;

if p_status < 0 then
  return;
end if;

 /* step : update the account password if necessary.  catch error
  if the account does not exist or the login name is not valid.  The system
  should check that both the login name, namespace, and password are 
  required to change the password.*/
 if p_loginname is not NULL and p_namespace is not NULL and p_tx_password is not NULL then
  begin
   update t_user_credentials set tx_password = p_tx_password
         where upper(nm_login) = upper(p_loginname) and upper(nm_space) =
         upper(p_namespace);
  exception when NO_DATA_FOUND then
   /* MTACCOUNT_FAILED_PASSWORD_UPDATE*/
   p_status :=  -509673461;
  end;
 end if;
 
 /* step : figure out if we need to update the account's billing cycle.  this
  may fail because the usage cycle information may not be present.*/
  begin
   for i in (
   select id_usage_cycle
   from t_usage_cycle cycle where
   cycle.id_cycle_type = p_ID_CYCLE_TYPE
   AND (p_DAY_OF_MONTH = cycle.day_of_month or p_DAY_OF_MONTH is NULL)
   AND (p_DAY_OF_WEEK = cycle.day_of_week or p_DAY_OF_WEEK is NULL)
   AND (p_FIRST_DAY_OF_MONTH= cycle.FIRST_DAY_OF_MONTH  or p_FIRST_DAY_OF_MONTH is NULL)
   AND (p_SECOND_DAY_OF_MONTH = cycle.SECOND_DAY_OF_MONTH or p_SECOND_DAY_OF_MONTH is NULL)
   AND (p_START_DAY= cycle.START_DAY or p_START_DAY is NULL)
   AND (p_START_MONTH= cycle.START_MONTH or p_START_MONTH is NULL)
   AND (p_START_YEAR = cycle.START_YEAR or p_START_YEAR is NULL))
   loop
       usagecycleID := i.id_usage_cycle ;
   end loop;
   if usagecycleID is null then
       usagecycleID := -1;
   end if;
  end;
  
  for i in (
    select id_usage_cycle from
    t_acc_usage_cycle where id_acc = accountID)
    loop
        oldcycleID := i.id_usage_cycle;
    end loop;
    
  if oldcycleID <> usagecycleID AND usagecycleID <> -1 then

      /* step : update the account's billing cycle*/
      update t_acc_usage_cycle set id_usage_cycle = usagecycleID
      where id_acc = accountID;

      /* post-operation business rule check (relies on rollback of work done up until this point)
       CR9906: checks to make sure the account's new billing cycle matches all of it's and/or payee's 
       group subscription BCR constraints.  TODO:  The function CheckGroupMembershipCycleConstraint is not ported yet!!!!!
       uncomment the following after it is ported */
      
      
      select  NVL(MIN(dbo.checkgroupmembershipcycleconst(p_systemdate, groups.id_group)), 1) into p_status
      from
      (
        select distinct gsm.id_group id_group
        from t_gsubmember gsm
        inner join t_payment_redirection pay
        on pay.id_payee = gsm.id_acc
        where pay.id_payer = accountID or pay.id_payee = accountID
      ) groups;
      

      IF p_status <> 1 then
        RETURN;
      end if;

      /* step : delete any records in t_acc_usage_interval that
       exist in the future with the old interval*/
       
      delete from t_acc_usage_interval aui
      where aui.id_acc = AccountID AND id_usage_interval IN
      (
       select id_interval from t_usage_interval ui
       INNER JOIN t_acc_usage_interval aui on aui.id_acc = accountID AND
       aui.id_usage_interval = ui.id_interval
       where
       dt_start > p_systemdate
      );
      
      /* step : delete any previous updates in t_acc_usage_interval 
         (only one can have dt-effective set) and the effective date is in 
         the future.*/
         
         
      delete from t_acc_usage_interval where dt_effective is not null
      and id_acc = accountID AND dt_effective >= p_systemdate;
  
      /* step : figure out the interval that we should be modifying*/
      for i in
        (select ui.dt_end dt_end
        from t_acc_usage_interval aui
        INNER JOIN t_usage_interval ui on ui.id_interval = aui.id_usage_interval
        AND p_systemdate between ui.dt_start AND ui.dt_end
        where
        aui.id_acc = AccountID)
      loop
        intervalenddate := i.dt_end;
      end loop;

      /* step : figure out the new interval ID based on the end date
       of the existing interval  */
      IF intervalenddate IS NOT NULL then
          for i in
            (select id_interval,dt_start,dt_end
            from
            t_pc_interval where
            id_cycle = usagecycleID AND
            dbo.addsecond(intervalenddate) between dt_start AND dt_end)
          loop
            intervalID := i.id_interval;
            pc_start   := i.dt_start;
            pc_end     := i.dt_end;
          end loop;
          
          /* step : create new usage interval if it is missing.  Make sure we use
           the end date of the existing interval plus one second AND the new 
           interval id.  populate the usage interval if necessary*/
           
          insert into t_usage_interval
          select
          intervalID,usagecycleID,pc_start,pc_end,'O'
          from dual
          where
          intervalID not in (select id_interval from t_usage_interval);
          
          /* step : create the t_acc_usage_interval mappings.  the new one is effective
           at the end of the interval.  We also must make sure to 
           populate t_acc_usage_interval with any other intervals in the future that
           may have been created by USM*/
           
           insert into t_acc_usage_interval (id_acc,id_usage_interval,tx_status,dt_effective)
              SELECT accountID,
                     intervalID,
                     nvl(tx_interval_status, 'O'),
                     intervalenddate
              FROM t_usage_interval
              WHERE id_interval = intervalID AND
                    tx_interval_status != 'B' ;
                    
          /* this check is necessary if we are creating an association with an interval that begins
          in the past.  This could happen if you create a daily account on tuesday and then
          change to a weekly account (starting on monday) on Thursday.  not that the end date check is 
          only greater than because we want to avoid any intervals that have the same end date as
          @intervalenddate.  The second part of the condition is to pick up intervals that are in the future.
          and ((intervalenddate >= dt_start AND intervalenddate < dt_end) OR
          dt_start > intervalenddate);*/
                  
      END IF;
 
      /* indicate that the cycle changed*/
      p_newcycle := UsageCycleID;
      p_cyclechanged := 1;

  else
      /* indicate that the cycle did not change*/
      p_newcycle := UsageCycleID;
      p_cyclechanged := 0;
  end if;

 /* step : update the payment redirection information.  Only update
  the payment information if the payer and payer_startdate is specified*/
  
 if (p_id_payer is NOT NULL OR (p_payer_login is not NULL AND
  p_payer_namespace is not NULL)) AND p_payer_startdate is NOT NULL then
  
  /* resolve the paying account id if necessary*/
  if p_payer_login is not null and p_payer_namespace is not null then
   payerID := dbo.LookupAccount(p_payer_login,p_payer_namespace) ;
   if payerID = -1 then
    /* MT_CANNOT_RESOLVE_PAYING_ACCOUNT*/
    p_status := -486604792;
    return;
   end if;
  else
   /* Fix CORE-762: Check that payerid exists */
   begin
     select count(*) into p_count
     from t_account
     where id_acc = p_id_payer;
     
     if p_count = 0 then
       p_status := -486604792;
       return;
     end if;
   end;
   payerID := p_id_payer;
  end if;
  
  /* default the payer end date to the end of the account*/
  if p_payer_enddate is NULL then
   payerenddate := dbo.mtmaxdate;
  else
   payerenddate := p_payer_enddate;
  end if;
  
  /* find the old payment information*/
  for i in (
    select vt_start,vt_end ,id_payer
    from t_payment_redirection
    where id_payee = AccountID and
    dbo.overlappingdaterange(vt_start,vt_end,p_payer_startdate,dbo.mtmaxdate)=1)
    loop
        oldpayerstart := i.vt_start;
        oldpayerend   := i.vt_end;
        oldpayer      := i.id_payer;
    end loop;
    
  /* if the new record is in range of the old record and the payer is the same as the older payer,
     update the record*/
     
  if (payerID = oldpayer) then
    UpdatePaymentRecord(payerID,accountID,oldpayerstart,oldpayerend,
                        p_payer_startdate,payerenddate,p_systemdate,
                        p_enforce_same_corporation,p_account_currency,p_status);
    if (p_status <> 1) then
      return;
    end if;
  else
    select case when payerID = accountID then p_billable else null end into payerbillable from dual;
    CreatePaymentRecord(payerID,accountID,p_payer_startdate,payerenddate,payerbillable,
                        p_systemdate,'N',p_enforce_same_corporation,p_account_currency,p_status);
    if (p_status <> 1) then
      return;
    end if;
  end if;
 end if;
 
 /* check if the account has any payees before setting the account as Non-billable.  It is important
    that this check take place after creating any payment redirection records   */
    
 if dbo.IsAccountBillable(AccountID) = '1' AND p_billable = 'N' then
    if dbo.DoesAccountHavePayees(AccountID,p_systemdate) = 'Y' then
          /* MT_ACCOUNT_NON_BILLABLE_AND_HAS_NON_PAYING_SUBSCRIBERS*/
          p_status := -486604767;
          return;
    end if;
 end if;
 /* payer update done */
 
 /* ancestor update begin */
 if ((p_ancestor_name is not null AND p_ancestor_namespace is not NULL)
 or p_id_ancestor is not null) AND p_hierarchy_movedate is not null then
 
  if p_ancestor_name is not NULL and p_ancestor_namespace is not NULL then
   ancestorID := dbo.LookupAccount(p_ancestor_name,p_ancestor_namespace) ;
   p_id_ancestor_out := ancestorID;
   if ancestorID = -1 then
    /* MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT*/
    p_status := -486604791;
    return;
   end if;
  else
   ancestorID := p_id_ancestor;
  end if;
  MoveAccount2(ancestorID,AccountID,p_hierarchy_movedate,p_enforce_same_corporation,p_systemdate,p_status,p_old_id_ancestor_out,p_ancestor_type,p_acc_type,'N');
  if p_status <> 1 then
   return;
  end if;
 end if;
 /* ancestor update done */
 
  if (p_old_id_ancestor_out is null) then
      p_old_id_ancestor_out := -1;
  end if;

  if (p_id_ancestor_out is null) then
      p_id_ancestor_out := -1;
  end if;
 
 /* step : resolve the hierarchy path based on the current time*/
 begin
  select tx_path into p_hierarchy_path from t_account_ancestor
  where id_ancestor =1  and id_descendent = AccountID and
  p_systemdate between vt_start and vt_end;
  exception when NO_DATA_FOUND then
  p_hierarchy_path := '/';
 end;
 
 /* resolve account's corporate account */
 
 begin
    select max(ancestor.id_ancestor) into p_corporate_account_id from t_account_ancestor ancestor
    inner join t_account acc on ancestor.id_ancestor = acc.id_acc
    inner join t_account_type atype on atype.id_type = acc.id_type
    where
      ancestor.id_descendent = AccountID
      AND atype.b_iscorporate = '1'
      AND p_systemdate  BETWEEN ancestor.vt_start and ancestor.vt_end;
    exception when NO_DATA_FOUND then
        null;
 end;

 /* done*/

 p_accountID := AccountID;
 p_status := 1;
end;
/

CREATE OR REPLACE PROCEDURE ADDICBMAPPING (
   temp_id_paramtable    t_pl_map.id_paramtable%TYPE,
   temp_id_pi_instance   t_pl_map.id_pi_instance%TYPE,
   temp_id_sub           t_pl_map.id_sub%TYPE,
   temp_id_acc           t_pl_map.id_acc%TYPE,
   temp_id_po            t_pl_map.id_po%TYPE,
   p_systemdate          DATE
)
AS
   temp_id_pi_type              INT;
   temp_currency                NVARCHAR2 (10);
   temp_id_pricelist            INT;
   temp_id_pi_template          INT;
   temp_id_pi_instance_parent   INT;
   temp_id_partition		    INT;
BEGIN
   BEGIN
      SELECT id_pi_type, id_pi_template, id_pi_instance_parent
        INTO temp_id_pi_type, temp_id_pi_template, temp_id_pi_instance_parent
        FROM t_pl_map
       WHERE id_pi_instance = temp_id_pi_instance AND id_paramtable IS NULL;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   BEGIN
      SELECT pl.nm_currency_code
        INTO temp_currency
        FROM t_po po INNER JOIN t_pricelist pl
             ON po.id_nonshared_pl = pl.id_pricelist
       WHERE po.id_po = temp_id_po;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;
   
   BEGIN
      SELECT po.c_POPartitionId
        INTO temp_id_partition
        FROM t_po po
       WHERE po.id_po = temp_id_po;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   INSERT INTO t_base_props
               (id_prop, n_kind, n_name, n_display_name, n_desc)
        VALUES (seq_t_base_props.NEXTVAL, 150, 0, 0, 0);

   SELECT seq_t_base_props.CURRVAL
     INTO temp_id_pricelist
     FROM DUAL;

   INSERT INTO t_pricelist
			   (id_pricelist,n_type,nm_currency_code,c_PLPartitionId)
        VALUES (temp_id_pricelist, 0, temp_currency, temp_id_partition);

   INSERT INTO t_pl_map
               (id_paramtable, id_pi_type, id_pi_instance,
                id_pi_template, id_pi_instance_parent, id_sub,
                id_po, id_pricelist, b_canicb, dt_modified
               )
        VALUES (temp_id_paramtable, temp_id_pi_type, temp_id_pi_instance,
                temp_id_pi_template, temp_id_pi_instance_parent, temp_id_sub,
                temp_id_po, temp_id_pricelist, 'N', p_systemdate
               );
END;
/

CREATE type ActiveBillRunWidgetTblType as object(
RowNumber int,
Adapter nvarchar2(200),
Duration int,
Average int
)
/

CREATE package active_bill_run_pkg as
TYPE ActiveBillRunWidgetTable is table of ActiveBillRunWidgetTblType;
function GetActvCurAverage(v_id_interval int) return ActiveBillRunWidgetTable
  pipelined;
end;
/

DROP TRIGGER trg_ttt_tmp_aggregate;

CREATE OR REPLACE PACKAGE mt_ttt
 AS
   FUNCTION get_tx_id (p_create_transaction BOOLEAN := FALSE)
      RETURN VARCHAR2;

   g_tx_id   dba_2pc_pending.global_tran_id%TYPE DEFAULT NULL;
END mt_ttt;
/

CREATE package body active_bill_run_pkg as
FUNCTION GetActvCurAverage(v_id_interval int)
  return ActiveBillRunWidgetTable PIPELINED IS
  p_returnTable ActiveBillRunWidgetTblType := ActiveBillRunWidgetTblType(null, null, null, null);
  
  p_result sys_refcursor;
  l_tbl_count NUMBER;  
  l_interval_id int;  /* t_usage_interval.id_interval%TYPE := 1073086497;*/
  
  v_sql VARCHAR2(4000);
  
  v_1 int;
  v_2 nvarchar2(200);
  v_3 int;
  v_4 int;
   pragma autonomous_transaction;
BEGIN
  l_interval_id :=v_id_interval; 
  SELECT COUNT(1)
  INTO l_tbl_count
  FROM user_tables
  WHERE  table_name  = UPPER('NM_DASHBOARD__INTERVAL_DATA');
  
  /*pragma autonomous_transaction;*/
  begin
	  IF (l_tbl_count > 0) THEN
		EXECUTE IMMEDIATE 'DROP TABLE NM_Dashboard__Interval_Data';
	   /* EXECUTE IMMEDIATE 'commit';*/
	   /*commit;*/
	  END IF;
	  
	  EXECUTE IMMEDIATE 'CREATE TABLE NM_Dashboard__Interval_Data AS ' ||
						'    SELECT 
							  rei.id_arg_interval, 
							  re.tx_display_name, 
							  min(rer.dt_start) dt_start, 
							  floor((max(rer.dt_end) - min(rer.dt_start)) * 24 * 60) duration, 
							  0 as three_month_avg
							  FROM t_recevent_inst rei
							  join t_recevent re on re.id_event = rei.id_event
							  left join t_recevent_run rer on rer.id_instance = rei.id_instance
							  --right join t_recevent_inst_audit rea on rea.id_instance = rei.id_instance
							Where id_arg_interval in (select ' || l_interval_id || ' id_interval from dual 
														union
													  select ui.id_interval id_interval
													  from t_usage_interval ui
													  where ui.tx_interval_status = ''H''
													  and ui.dt_end > add_months(getutcdate(), -3) 
													 and floor(dt_end - dt_start) > 7)
							and rer.tx_type = ''Execute''
							and tx_detail not like ''Manually changed status%''
							group by rei.id_arg_interval, tx_display_name,  rer.dt_start
							order by   rer.dt_start';
  end;
                  
 EXECUTE IMMEDIATE 'MERGE into NM_Dashboard__Interval_Data ca
  USING
  (
    SELECT tx_display_name, avg(duration) field2Sum
    FROM NM_Dashboard__Interval_Data sft
    WHERE id_arg_interval <> ' || l_interval_id ||'
    GROUP BY tx_display_name
  ) sft ON (ca.tx_display_name = sft.tx_display_name)
  WHEN MATCHED THEN UPDATE 
  SET ca.three_month_avg = field2Sum'; 
  
  v_sql := ' SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1 FROM dual)) RowNumber, tx_display_name Adapter, duration Duration, three_month_avg Average
    FROM NM_Dashboard__Interval_Data
    WHERE id_arg_interval = :1'; 
     
    OPEN p_result FOR v_sql USING l_interval_id;
    commit;  
    LOOP
      FETCH p_result INTO v_1, v_2, v_3, v_4;
      EXIT WHEN p_result%NOTFOUND;
      p_returnTable.RowNumber := v_1;
      p_returnTable.Adapter := v_2;
      p_returnTable.Duration := v_3;
      p_returnTable.Average := v_4;
      PIPE ROW (p_returnTable);
    END LOOP      
    return;     
END GetActvCurAverage;
end active_bill_run_pkg;

/

ALTER PROCEDURE getcurrentid COMPILE ;

ALTER PACKAGE mt_acc_template COMPILE ;

ALTER PACKAGE mt_rate_pkg COMPILE ;

ALTER TYPE string_table COMPILE ;

ALTER FUNCTION splitstringbychar COMPILE ;

ALTER PROCEDURE inserttmplsessiondetail COMPILE ;

CREATE OR REPLACE PACKAGE BODY mt_acc_template
AS
    detailtypesubs      INT;
    detailresultfailure INT;

    PROCEDURE subscribe_account(
       id_acc              INT,
       id_po               INT,
       id_group            INT,
       sub_start           DATE,
       sub_end             DATE,
       systemdate          DATE,
       doCommit            CHAR DEFAULT 'Y'
    )
    AS
        v_guid                RAW(16);
        curr_id_sub           INT;
    BEGIN
        IF (id_group IS NOT NULL) THEN
            INSERT INTO tmp_gsubmember (id_group, id_acc, vt_start, vt_end)
                VALUES (id_group, id_acc, sub_start, sub_end);
        ELSE
            getcurrentid('id_subscription', curr_id_sub);
            SELECT SYS_GUID() INTO v_guid FROM dual;
            INSERT INTO tmp_sub (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end)
                VALUES (curr_id_sub, v_guid, id_acc, NULL, id_po, systemdate, sub_start, sub_end);
        END IF;

    END;

    PROCEDURE apply_subscriptions (
       template_id                INT,
       sub_start                  DATE,
       sub_end                    DATE,
       next_cycle_after_startdate CHAR, /* Y or N */
       next_cycle_after_enddate   CHAR, /* Y or N */
       user_id                    INT,
       id_audit                   INT,
       id_event_success           INT,
       id_event_failure           INT,
       systemdate                 DATE,
       id_template_session        INT,
       retrycount                 INT,
       doCommit                   CHAR DEFAULT 'Y'
    )
    AS
       my_id_audit           INT;
       my_error              VARCHAR2(1024);
       my_id_acc             INT;
       maxdate               DATE;
       audit_msg             VARCHAR2(256);
    BEGIN
        IF (my_id_audit IS NULL)
        THEN
           IF (apply_subscriptions.id_audit IS NOT NULL)
           THEN
              my_id_audit := apply_subscriptions.id_audit;
           ELSE
              getcurrentid ('id_audit', my_id_audit);
              INSERT INTO t_audit (
                    id_audit,
                    id_event,
                    id_userid,
                    id_entitytype,
                    id_entity,
                    dt_crt
                 )
              VALUES (
                    my_id_audit,
                    apply_subscriptions.id_event_failure,
                    apply_subscriptions.user_id,
                    1,
                    my_id_acc,
                    getutcdate ()
                 );
           END IF;
        END IF;

        IF detailtypesubs IS NULL THEN
            SELECT id_enum_data
            INTO   detailtypesubs
            FROM   t_enum_data
            WHERE  nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription';

            SELECT id_enum_data
            INTO   detailresultfailure
            FROM   t_enum_data
            WHERE  nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure';
         END IF;

      DELETE FROM t_acc_template_valid_subs WHERE id_acc_template_session = apply_subscriptions.id_template_session;
      /* Detect conflicting subscriptions in the template and choice first available of them and without conflicts */
      INSERT INTO t_acc_template_valid_subs (id_acc_template_session, id_po, id_group, sub_start, sub_end, po_start, po_end)
      SELECT DISTINCT
           apply_subscriptions.id_template_session,
           subs.id_po,
           subs.id_group,
           subs.sub_start,
           subs.sub_end,
           subs.sub_start,
           subs.sub_end
      FROM
        (
            SELECT t1.id_po, MAX(t1.id_group) AS id_group, GREATEST(MAX(ed.dt_start), t1.vt_start) AS sub_start, LEAST(NVL(MAX(ed.dt_end), mtmaxdate()), t1.vt_end) AS sub_end
                FROM (
                    SELECT NVL(ts.id_po,s.id_po) AS id_po, s.id_group, ts.vt_start, ts.vt_end
                        FROM t_acc_template_subs ts
                        LEFT JOIN t_sub s ON s.id_group = ts.id_group
                        WHERE ts.id_acc_template = apply_subscriptions.template_id
                ) t1
                JOIN t_po po ON po.id_po = t1.id_po
                JOIN t_effectivedate ed ON po.id_eff_date = ed.id_eff_date
                GROUP BY t1.id_po, t1.vt_start, t1.vt_end
        ) subs;

       /* Applying subscriptions to accounts */
      FOR rec IN (
         SELECT id_descendent AS id_acc
         FROM   t_vw_get_accounts_by_tmpl_id v
         WHERE  v.id_template = apply_subscriptions.template_id)
      LOOP
           my_id_acc := rec.id_acc;
           apply_subscriptions_to_acc (
               id_acc                     => rec.id_acc,
               id_acc_template            => apply_subscriptions.template_id,
               next_cycle_after_startdate => apply_subscriptions.next_cycle_after_startdate,
               next_cycle_after_enddate   => apply_subscriptions.next_cycle_after_enddate,
               user_id                    => apply_subscriptions.user_id,
               id_audit                   => my_id_audit,
               id_event_success           => apply_subscriptions.id_event_success,
               systemdate                 => apply_subscriptions.systemdate,
               id_template_session        => apply_subscriptions.id_template_session,
               retrycount                 => apply_subscriptions.retrycount
           );
      END LOOP;

      maxdate := mtmaxdate();

      mt_rate_pkg.current_id_audit := apply_subscriptions.id_audit;

      INSERT INTO t_gsubmember_historical (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
      SELECT id_group, id_acc, vt_start, NVL(vt_end, maxdate), apply_subscriptions.systemdate, maxdate
      FROM   tmp_gsubmember;

      INSERT INTO t_gsubmember (id_group, id_acc, vt_start, vt_end)
      SELECT tmp.id_group, tmp.id_acc, tmp.vt_start, NVL(tmp.vt_end, maxdate)
      FROM   tmp_gsubmember tmp;

      INSERT INTO t_sub_history (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end, tt_start, tt_end)
      SELECT id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, NVL(vt_end, maxdate), apply_subscriptions.systemdate, maxdate
      FROM   tmp_sub;

      INSERT INTO t_sub (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end)
      SELECT id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, NVL(vt_end, maxdate)
      FROM   tmp_sub;

      INSERT INTO t_audit_details (id_auditdetails, id_audit, tx_details)
      SELECT seq_t_audit_details.NEXTVAL, tmp.my_id_audit, tmp.tx_details
      FROM   (
              SELECT my_id_audit AS my_id_audit,
                     'Added subscription to id_groupsub ' || id_group ||
                     ' for account ' || id_acc ||
                     ' from ' || vt_start ||
                     ' to ' || NVL(vt_end, maxdate) ||
                     ' on ' || systemdate AS tx_details
              FROM   tmp_gsubmember
              UNION ALL
              SELECT my_id_audit AS my_id_audit,
                     'Added subscription to product offering ' || id_po ||
                     ' for account ' || id_acc ||
                     ' from ' || vt_start ||
                     ' to ' || NVL(vt_end, maxdate) ||
                     ' on ' || apply_subscriptions.systemdate AS tx_details
              FROM   tmp_sub
             ) tmp;
      IF (doCommit = 'Y')
      THEN
      COMMIT;
      END IF;

      mt_rate_pkg.current_id_audit := NULL;
      DELETE FROM t_acc_template_valid_subs WHERE id_acc_template_session = apply_subscriptions.id_template_session;
    END;

    PROCEDURE apply_subscriptions_to_acc (
       id_acc                     INT,
       id_acc_template            INT,
       next_cycle_after_startdate CHAR, /* Y or N */
       next_cycle_after_enddate   CHAR, /* Y or N */
       user_id                    INT,
       id_audit                   INT,
       id_event_success           INT,
       systemdate                 DATE,
       id_template_session        INT,
       retrycount                 INT,
       doCommit                   CHAR DEFAULT 'Y'
    )
    AS
       v_acc_start       DATE;
       v_vt_start        DATE;
       v_vt_end          DATE;
       v_sub_start       DATE;
       v_sub_end         DATE;
       curr_id_sub       INT;
       my_id_audit       INT;
       my_user_id        INT;
       id_acc_type       INT;
       v_prev_start DATE;
       v_prev_end   DATE;

    BEGIN
       my_user_id := apply_subscriptions_to_acc.user_id;

       IF (my_user_id IS NULL)
       THEN
          my_user_id := 1;
       END IF;
       my_id_audit := apply_subscriptions_to_acc.id_audit;

       IF (my_id_audit IS NULL)
       THEN
          getcurrentid ('id_audit', my_id_audit);
          
          INSERT INTO t_audit
                      (id_audit, id_event, id_userid, id_entitytype, id_entity,
                       dt_crt
                      )
               VALUES (my_id_audit, apply_subscriptions_to_acc.id_event_success, apply_subscriptions_to_acc.user_id, 1, apply_subscriptions_to_acc.id_acc,
                       getutcdate ()
                      );
       END IF;

       SELECT vt_start
       INTO   v_acc_start
       FROM   t_account_state
       WHERE  id_acc = apply_subscriptions_to_acc.id_acc;

       SELECT id_type
       INTO   id_acc_type
       FROM   t_account
       WHERE  id_acc = apply_subscriptions_to_acc.id_acc;
       /* Create new subscriptions */
       FOR sub IN (
        SELECT
            id_po,
            id_group,
            CASE
                WHEN apply_subscriptions_to_acc.next_cycle_after_startdate = 'Y'
                THEN
                    (
                        SELECT GREATEST(tpc.dt_end + numtodsinterval(1, 'second'), tvs.po_start)
                            FROM   t_pc_interval tpc
                            INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
                            WHERE  tauc.id_acc = apply_subscriptions_to_acc.id_acc
                            AND tvs.sub_start BETWEEN tpc.dt_start AND tpc.dt_end
                    )
                ELSE tvs.sub_start
            END AS v_sub_start,
            CASE
                WHEN apply_subscriptions_to_acc.next_cycle_after_enddate = 'Y'
                THEN
                    (
                        SELECT LEAST(LEAST(tpc.dt_end + numtodsinterval(1, 'second'), mtmaxdate()), tvs.po_end)
                            FROM   t_pc_interval tpc
                            INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
                            WHERE  tauc.id_acc = apply_subscriptions_to_acc.id_acc
                            AND tvs.sub_end BETWEEN tpc.dt_start AND tpc.dt_end
                    )
                ELSE tvs.sub_end
            END AS v_sub_end
            FROM t_acc_template_valid_subs tvs
            WHERE tvs.id_acc_template_session = apply_subscriptions_to_acc.id_template_session
       )
       LOOP
            v_prev_end := sub.v_sub_start - 1;
            FOR c_sub IN (
                SELECT S.*
                    FROM t_sub s
                    WHERE s.vt_end >= sub.v_sub_start
                        AND s.vt_start <= sub.v_sub_end
                        AND s.id_acc = apply_subscriptions_to_acc.id_acc
                        AND s.id_po = sub.id_po
                    ORDER BY s.vt_start
            )
            LOOP
                IF c_sub.vt_start > v_prev_end THEN
                    v_vt_start := v_prev_end + 1;
                    v_vt_end := c_sub.vt_start - 1;
                END IF;
                IF v_vt_start <= v_vt_end THEN
                    subscribe_account(apply_subscriptions_to_acc.id_acc, sub.id_po, sub.id_group, v_vt_start, v_vt_end, apply_subscriptions_to_acc.systemdate, doCommit);
                END IF;
                v_prev_end := c_sub.vt_end;
            END LOOP;
            IF (v_prev_end < sub.v_sub_end) THEN
                v_vt_start := v_prev_end + 1;
                v_vt_end := sub.v_sub_end;
                subscribe_account(apply_subscriptions_to_acc.id_acc, sub.id_po, sub.id_group, v_vt_start, v_vt_end, apply_subscriptions_to_acc.systemdate, doCommit);
            END IF;
       END LOOP;
    END;

    PROCEDURE UpdateAccPropsFromTemplate (
      idAccountTemplate INT,
      systemDate DATE,
      idAcc INT DEFAULT NULL
    )
    AS
        vals VARCHAR2(32767);
        dSql VARCHAR2(32767);
        conditionStatement VARCHAR2(32767);
        enumValue VARCHAR2(256);
        val1 VARCHAR2(256);
        val2 VARCHAR2(256);
    BEGIN
        FOR rec IN (
            SELECT
                DISTINCT(v.account_view_name) AS viewName,
                't_av_'|| SUBSTR(td.nm_enum_data, INSTR (td.nm_enum_data, '/') + 1, LENGTH(td.nm_enum_data)) AS tableName,
                CASE WHEN INSTR(tp.nm_prop, ']') <> 0
                THEN SUBSTR(tp.nm_prop, INSTR(tp.nm_prop, '[') + 1, INSTR(tp.nm_prop, ']') - INSTR(tp.nm_prop, '[') - 1)
                ELSE NULL
                END AS additionalOptionString
            FROM t_enum_data td JOIN t_account_type_view_map v ON v.id_account_view = td.id_enum_data
            JOIN t_account_view_prop p ON v.id_type = p.id_account_view
            JOIN t_acc_template_props tp ON tp.nm_prop LIKE v.account_view_name || '%' AND tp.nm_prop LIKE '%' || p.nm_name
            WHERE tp.id_acc_template = idAccountTemplate)
        LOOP
            vals := NULL;
            FOR val IN (
                SELECT
                    --"Magic numbers" were took FROM MetraTech.Interop.MTYAAC.PropValType enumeration.
                    CASE WHEN ROWNUM = 1 THEN NULL ELSE ',' END ||
                    nm_column_name || ' ' ||
                        CASE
                            WHEN nm_prop_class IN(0, 1, 4, 5, 6, 8, 9, 12, 13)
                            THEN ' = ''' || REPLACE(TO_CHAR(nm_value), '''', '''''') || ''' '
                            WHEN nm_prop_class IN(2, 3, 10, 11, 14)
                            THEN ' = ' || REPLACE(TO_CHAR(nm_value), '''', '''''') || ' '
                            WHEN nm_prop_class = 7
                            THEN
                                CASE
                                    WHEN UPPER(nm_value) = 'TRUE'
                                    THEN ' = 1 '
                                    ELSE ' = 0 '
                                END
                            ELSE ''''' '
                        END AS colVal

                FROM t_account_type_view_map v
                JOIN t_account_view_prop p ON v.id_type = p.id_account_view
                JOIN t_acc_template_props tp ON tp.nm_prop LIKE v.account_view_name || '%' AND tp.nm_prop LIKE '%.' || REPLACE(REPLACE(REPLACE(p.nm_name, N'\', N'\\'), N'_', N'\_'), N'%', N'\%') ESCAPE N'\'
                WHERE tp.id_acc_template = idAccountTemplate AND tp.nm_prop LIKE rec.viewName || '%')
            LOOP
                vals := vals || val.colVal;
            END LOOP;

            conditionStatement := NULL;
            IF(rec.additionalOptionString IS NOT NULL) THEN
                -- Processing enum values
                FOR item IN (SELECT items AS conditionItem FROM TABLE(SplitStringByChar(rec.additionalOptionString,',')))
                LOOP

                    val1 := SUBSTR(item.conditionItem, 0, INSTR(item.conditionItem, '=') - 1);

                    val2 := SUBSTR(item.conditionItem, INSTR(item.conditionItem, '=') + 1, LENGTH(item.conditionItem) - INSTR(item.conditionItem, '=') + 1);
                    val2 := REPLACE(val2, '_', '-');

                    --Select value fot additional condition by namespace and name of enum.
                    SELECT id_enum_data
                      INTO enumValue
                      FROM t_enum_data
                     WHERE UPPER(nm_enum_data) =
                        (SELECT UPPER(nm_space || '/' || nm_enum || '/' || val2)
                        FROM t_account_type_view_map v JOIN t_account_view_prop p ON v.id_type = p.id_account_view
                        WHERE UPPER(account_view_name) = UPPER(rec.viewName) AND UPPER(nm_name) = UPPER(val1));

                    --Creation additional condition for update account view properties for each account view.
                    conditionStatement := conditionStatement || 'c_' || val1 || ' = ' || TO_CHAR(enumValue) || ' AND ';
                END LOOP;
            END IF;

            --Completion to creation dynamic sql-string for update account view.
            IF (idAcc IS NOT NULL) THEN
                conditionStatement := conditionStatement || 'id_acc = ' || TO_CHAR(idAcc) || ' ';
            ELSE
                conditionStatement := conditionStatement || 'id_acc in (SELECT id_descendent FROM t_vw_get_accounts_by_tmpl_id WHERE id_template = ' || TO_CHAR(idAccountTemplate) || '  AND CAST(''' || TO_CHAR(systemDate) || ''' AS DATE) BETWEEN COALESCE(vt_start, CAST(''' || TO_CHAR(systemDate) || ''' AS DATE)) AND COALESCE(vt_end, CAST(''' || TO_CHAR(systemDate) || ''' AS DATE)))';
            END IF;
            dSql := 'UPDATE ' || rec.tableName || ' SET ' || vals || ' WHERE ' || conditionStatement;
            EXECUTE IMMEDIATE dSql;
        END LOOP;
    END;

    PROCEDURE UpdateUsageCycleFromTemplate (
        IdAcc INT
        ,UsageCycleId INT
        ,OldUsageCycle INT
        ,systemDate DATE
    )
    AS
        p_status INT;
        intervalenddate DATE;
        intervalID INT;
        pc_start DATE;
        pc_end DATE;
    BEGIN
        IF OldUsageCycle <> UsageCycleId AND UsageCycleId <> -1 THEN
            p_status := dbo.ISBILLINGCYCLEUPDPROHIBITEDBYG(systemDate, IdAcc);
            IF p_status = 1 THEN
                p_status := 0;
                UPDATE t_acc_usage_cycle
                   SET id_usage_cycle = UsageCycleId
                 WHERE id_acc = IdAcc;

                  -- post-operation business rule check (relies on rollback of work done up until this point)
                  -- CR9906: checks to make sure the account's new billing cycle matches all of it's and/or payee's
                  -- group subscription BCR constraints
                SELECT NVL(MIN(dbo.CHECKGROUPMEMBERSHIPCYCLECONST(systemDate, "groups".id_group)), 1)
                  INTO p_status
                  FROM (
                        -- gets all of the payer's payee's and/or the payee's group subscriptions
                        SELECT DISTINCT gsm.id_group id_group
                            FROM t_gsubmember gsm
                            INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc
                            WHERE pay.id_payer = IdAcc OR pay.id_payee = IdAcc
                      ) "groups";

                IF p_status = 1 THEN
                    p_status := 0;
                    -- deletes any mappings to intervals in the future from the old cycle
                    DELETE FROM t_acc_usage_interval
                        WHERE t_acc_usage_interval.id_acc = IdAcc
                        AND id_usage_interval IN (
                            SELECT id_interval
                                FROM t_usage_interval ui
                                INNER JOIN t_acc_usage_interval aui ON aui.id_acc = IdAcc AND aui.id_usage_interval = ui.id_interval
                                WHERE dt_start > systemDate
                        );

                    -- only one pending update is allowed at a time
                    -- deletes any previous update mappings which have not yet
                    -- transitioned (dt_effective is still in the future)
                    DELETE FROM t_acc_usage_interval
                        WHERE dt_effective IS NOT NULL
                            AND id_acc = IdAcc
                            AND dt_effective >= systemDate;

                    -- gets the current interval's end date
                    SELECT MAX(ui.dt_end)
                      INTO intervalenddate
                      FROM t_acc_usage_interval aui
                      INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval AND systemDate BETWEEN ui.dt_start AND ui.dt_end
                    WHERE aui.id_acc = IdAcc;

                    -- future dated accounts may not yet be associated with an interval (CR11047)
                    IF intervalenddate IS NOT NULL THEN
                        -- figures out the new interval ID based on the end date of the current interval
                        SELECT id_interval, dt_start, dt_end
                          INTO intervalID, pc_start, pc_end
                          FROM t_pc_interval
                        WHERE id_cycle = UsageCycleId
                          AND addsecond(intervalenddate) BETWEEN dt_start AND dt_end;

                        -- inserts the new usage interval if it doesn't already exist
                        -- (needed for foreign key relationship in t_acc_usage_interval)
                        INSERT INTO t_usage_interval
                            SELECT intervalID
                                    ,UsageCycleId
                                    ,pc_start
                                    ,pc_end
                                    ,'O'
                              FROM DUAL
                             WHERE NOT EXISTS (SELECT 1 FROM t_usage_interval WHERE id_interval = intervalID);

                        -- creates the special t_acc_usage_interval mapping to the interval of
                        -- new cycle. dt_effective is set to the end of the old interval.
                        INSERT INTO t_acc_usage_interval
                            SELECT IdAcc
                                    ,intervalID
                                    ,NVL(tx_interval_status, 'O')
                                    ,intervalenddate
                                FROM t_usage_interval
                                WHERE id_interval = intervalID
                                    AND tx_interval_status <> 'B';
                    END IF;
                END IF;
            END IF;
        END IF;
    END;

    PROCEDURE UpdatePayerFromTemplate (
        IdAcc INT
        ,PayerId INT
        ,systemDate DATE
        ,p_account_currency VARCHAR2
        ,sessionId INT
        ,DetailTypeSubscription INT
        ,DetailResultInformation INT
        ,nRetryCount INT
    )
    AS
        p_status INT;
        oldpayerstart DATE;
        oldpayerend DATE;
        oldpayer INT;
        payerenddate DATE;

        payerbillable VARCHAR2(1);
        accExists INT;
    BEGIN
        SELECT COUNT(1) INTO accExists FROM t_account WHERE id_acc = PayerID;
        IF accExists > 0 THEN
            payerenddate := dbo.MTMaxDate();
            -- find the old payment information
            SELECT MAX(vt_start), MAX(vt_end), MAX(id_payer)
              INTO oldpayerstart, oldpayerend, oldpayer
              FROM t_payment_redirection
             WHERE id_payee = IdAcc
               AND dbo.OverlappingDateRange(vt_start, vt_end, systemDate, dbo.mtmaxdate()) = 1;

            -- if the new record is in range of the old record and the payer is the same as the older payer,
            -- update the record
            IF (PayerID <> -1) THEN
                IF (PayerID = oldpayer) THEN
                    UpdatePaymentRecord (payerID, IdAcc, oldpayerstart, oldpayerend, systemDate, payerenddate, systemDate, 1, p_account_currency, p_status);

                    IF (p_status <> 1) THEN
                        InsertTmplSessionDetail
                        (
                            sessionId,
                            DetailTypeSubscription,
                            DetailResultInformation,
                            'No payment record changed. Return code is ' || TO_CHAR(p_status),
                            nRetryCount,
                            'N'
                        );
                        p_status := 0;
                    END IF;
                ELSE
                    payerbillable := dbo.IsAccountBillable(PayerID);
                    CreatePaymentRecord(payerID, IdAcc, systemDate, payerenddate, payerbillable, systemDate, 'N', 1, p_account_currency, p_status);
                    IF (p_status <> 1) THEN
                        InsertTmplSessionDetail
                        (
                            sessionId,
                            DetailTypeSubscription,
                            DetailResultInformation,
                            'No payment record created. Return code is ' || TO_CHAR(p_status),
                            nRetryCount,
                            'N'
                        );
                        p_status := 0;
                    END IF;
                END IF;
            END IF;
        END IF;
    END;

END mt_acc_template;
/

CREATE OR REPLACE PACKAGE BODY dbo
IS

   FUNCTION mtmaxdate
      RETURN DATE
   IS
      temp_time   DATE;
   BEGIN
		TEMP_time := to_date('01/01/2038 00:00','dd/mm/yyyy hh24:mi');
    return (temp_time);
   END;

   FUNCTION mtmindate
      RETURN DATE
   AS
      temp_time   DATE;
   BEGIN
		temp_time := to_date('01/01/1753 00:00','dd/mm/yyyy hh24:mi');
    RETURN (temp_time);
   END;

   FUNCTION getutcdate
      RETURN DATE
   AS
      v_utcdate   DATE;
   BEGIN
      SELECT SYS_EXTRACT_UTC (SYSTIMESTAMP)
        INTO v_utcdate
        FROM DUAL;

      RETURN v_utcdate;
   END;

   FUNCTION addsecond (refdate DATE)
      RETURN DATE
   AS
   BEGIN
      RETURN   refdate + numtodsinterval(1,'second');
   END;

   FUNCTION subtractsecond (refdate DATE)
      RETURN DATE
   AS
   BEGIN
      RETURN   refdate + numtodsinterval(-1,'second');
   END;

  function addday(dt date) return date as
  begin
    return dt + numtodsinterval(1, 'day');
  end;

  function subtractday(dt date) return date as
  begin
    return dt + numtodsinterval(-1, 'day');
  end;
  
  
   function diffhour (dt_start date, dt_end date)
      return number
   as
   begin
      /* this expression is equivalent to sql server's datediff(hour, a, b).
         the fractional part of the result is discarded */
      return floor ((dt_end - dt_start) * 24);
   end;

  function isaccountbillable(p_id_acc IN integer)
	return varchar2
	as
	 billableFlag char(1);
	begin
	 begin
		select c_billable into billableFlag from t_av_internal where
		id_acc = p_id_acc;
		exception when NO_DATA_FOUND then
		 billableFlag := '0';
	 end;
	 if billableFlag is NULL then
			billableFlag := '0';
	 end if;
	 return billableFlag;
	end;

	FUNCTION IsAccountFolder(p_id_acc IN integer)
		return varchar2
	AS
		folderFlag char(1);
		BEGIN
		 BEGIN
			SELECT c_folder INTO folderFlag FROM t_av_internal
			WHERE id_acc = p_id_acc;

			exception when NO_DATA_FOUND then
				folderFlag := 'N';
		 END;
 	 	IF folderFlag IS NULL then
			folderFlag := 'N';
		END IF;

		RETURN folderFlag;
		END;

   FUNCTION encloseddaterange (
      temp_dt_start        DATE,
      temp_dt_end          DATE,
      temp_dt_checkstart   DATE,
      temp_dt_checkend     DATE
   )
      RETURN INTEGER
   AS
   BEGIN
      /* check if the range specified by temp_dt_checkstart and */
      /* temp_dt_checkend is completely inside the range specified */
      /* by temp_dt_start, temp_dt_end */
			if temp_dt_checkend = MTMaxDate() and temp_dt_end = MTMaxDate() then
				if temp_dt_checkstart >= temp_dt_start then
					return 1;
				else
					return 0;
				end if;
			end if;

      IF      temp_dt_checkstart >= temp_dt_start
          AND temp_dt_checkend <= temp_dt_end
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

   FUNCTION overlappingdaterange (
      temp_dt_start        DATE,
      temp_dt_end          DATE,
      temp_dt_checkstart   DATE,
      temp_dt_checkend     DATE
   )
      RETURN INTEGER
   AS
   BEGIN
      IF    (temp_dt_start IS NOT NULL AND temp_dt_start > temp_dt_checkend)
         OR (    temp_dt_checkstart IS NOT NULL
             AND temp_dt_checkstart > temp_dt_end
            )
      THEN
         RETURN 0;
      END IF;

      RETURN 1;
   END;

   FUNCTION mtcomputeeffectivebegindate (
      TYPE                  INT,
      offset                INT,
      base                  DATE,
      sub_begin             DATE,
      temp_id_usage_cycle   INT
   )
      RETURN DATE
   AS
      next_interval_begin   DATE;
   BEGIN
      IF (TYPE = 1)
      THEN
         RETURN (base);
      ELSIF (TYPE = 2)
      THEN
         RETURN (  sub_begin
                 + offset
                );
      ELSIF (TYPE = 3)
      THEN
         for i in (SELECT (  dt_end + numtodsinterval(1,'second')
                ) next_interval_begin
           FROM t_pc_interval
          WHERE base BETWEEN dt_start AND dt_end
            AND id_cycle = temp_id_usage_cycle)
            loop
                next_interval_begin := i.next_interval_begin;
            end loop;

         RETURN (next_interval_begin);
      ELSE
         RETURN (NULL);
      END IF;
   END;

   FUNCTION mtrateschedulescore (TYPE INT, begindate DATE)
      RETURN INT
   AS
      datescore   INT;
      typescore   INT;
   BEGIN
      SELECT DECODE (
                TYPE,
                4, 0,
                0, 0,
                  (  TO_DATE ('1970-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                   - begindate
                  )
                * 86400
             )
        INTO datescore
        FROM DUAL;

      SELECT DECODE (TYPE, 2, 2, 4, 0, 0, 0, 1)
        INTO typescore
        FROM DUAL;

      RETURN (  (typescore * 4294967296)
              + datescore
             );
   END;

   FUNCTION mtdateinrange (startdate DATE, enddate DATE, comparedate DATE)
      RETURN INTEGER
   AS
   BEGIN
      IF  startdate <= comparedate AND comparedate < enddate
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

   /* Function returns the minimum of two dates.  A null date is considered */
   /* to be infinitely large. */
   FUNCTION mtminoftwodates (chargeintervalleft DATE, subintervalleft DATE)
      RETURN DATE
   AS
   BEGIN
      IF (   subintervalleft IS NULL
          OR chargeintervalleft < subintervalleft
         )
      THEN
         RETURN (chargeintervalleft);
      ELSE
         RETURN (subintervalleft);
      END IF;
		END;

   /* Function returns the maximum of two dates.  A null date is considered */
   /* to be infinitely small. */
   FUNCTION mtmaxoftwodates (chargeintervalleft DATE, subintervalleft DATE)
      RETURN DATE
   AS
   BEGIN
      IF (   subintervalleft IS NULL
          OR chargeintervalleft > subintervalleft
         )
      THEN
         RETURN (chargeintervalleft);
      ELSE
         RETURN (subintervalleft);
      END IF;
   END;

   FUNCTION nextdateafterbillingcycle (temp_id_acc INT, temp_datecheck DATE)
      RETURN DATE
   AS
      temp_dt   DATE;
   BEGIN
      for i in (SELECT (  tpc.dt_end + numtodsinterval(1,'second')
             ) temp_dt
        from t_payment_redirection redir
	      inner join t_acc_usage_cycle auc
	      on auc.id_acc = redir.id_payer
	      inner join t_pc_interval tpc
	      on tpc.id_cycle = auc.id_usage_cycle
	      where redir.id_payee = temp_id_acc
	      AND
	      tpc.dt_start <= temp_datecheck AND temp_datecheck <= tpc.dt_end
	      AND
	      redir.vt_start <= temp_datecheck AND temp_datecheck <= redir.vt_end)
         loop
            temp_dt := i.temp_dt;
         end loop;

      RETURN (temp_dt);
   END;

FUNCTION checksubscriptionconflicts (
      temp_id_acc            INT,
      temp_id_po             INT,
      temp_real_begin_date   DATE,
      temp_real_end_date     DATE,
      temp_id_sub            INT,
      p_allow_acc_po_curr_mismatch  INT,
      p_allow_multiple_pi_sub_rcnrc INT
   )
      RETURN INT
   AS
      temp_status   INTEGER;
      v_count             number := 0;
	  conflicting_usagepi_count INTEGER;
	  
   BEGIN
      SELECT COUNT (t_sub.id_sub)
        INTO temp_status
        FROM t_sub
       WHERE t_sub.id_acc = temp_id_acc
         AND t_sub.id_po = temp_id_po
         AND t_sub.id_sub <> temp_id_sub
         AND dbo.overlappingdaterange (
                t_sub.vt_start,
                t_sub.vt_end,
                temp_real_begin_date,
                temp_real_end_date
             ) = 1;

      IF (temp_status > 0 AND p_allow_multiple_pi_sub_rcnrc <> 1)
      THEN
         /* MTPCUSER_CONFLICTING_PO_SUBSCRIPTION */
         RETURN (-289472485);
      END IF;

	  IF (temp_status > 0 AND p_allow_multiple_pi_sub_rcnrc = 1)
      THEN
	-- Check whether conflicting subscription has any Non RC/NRC PIs in it
	SELECT COUNT (id_pi_template) INTO conflicting_usagepi_count
	FROM t_pl_map JOIN t_base_props bp1 on t_pl_map.id_pi_template = bp1.id_prop
	WHERE
	t_pl_map.id_po = temp_id_po AND
	t_pl_map.id_paramtable IS NULL AND
	bp1.n_kind in (10,40) AND
	t_pl_map.id_pi_template IN
           (SELECT id_pi_template
            FROM t_pl_map
            WHERE
              id_paramtable IS NULL AND
              id_po IN
                         (SELECT id_po
                            FROM t_vw_effective_subs subs
                            WHERE subs.id_sub <> temp_id_sub
                            AND subs.id_acc = temp_id_acc
                             AND dbo.overlappingdaterange (
                                    subs.dt_start,
                                    subs.dt_end,
                                    temp_real_begin_date,
                                    temp_real_end_date
                                 ) = 1));
	IF conflicting_usagepi_count > 0
		THEN
			return (-289472484);
		END IF;
	END IF;
      for i in (
      select dbo.overlappingdaterange(temp_real_begin_date,temp_real_end_date,te.dt_start,te.dt_end) temp_status
      from t_po
      INNER JOIN t_effectivedate te on te.id_eff_date = t_po.id_eff_date
      where id_po = temp_id_po) loop
        temp_status := i.temp_status;
      end loop;
      if temp_status <> 1 then
      /* MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE */
      return (-289472472);
      end if;

      SELECT COUNT (id_pi_template)
        INTO temp_status
        FROM t_pl_map
				WHERE t_pl_map.id_po = temp_id_po
				AND t_pl_map.id_paramtable IS NULL
         AND t_pl_map.id_pi_template IN
                   (SELECT id_pi_template
                      FROM t_pl_map
                     WHERE id_paramtable IS NULL AND
                     id_po IN
                                 (SELECT id_po
                                    FROM t_vw_effective_subs subs
                                     WHERE subs.id_sub <> temp_id_sub
														         AND subs.id_acc = temp_id_acc
                                     AND dbo.overlappingdaterange (
                                            subs.dt_start,
                                            subs.dt_end,
                                            temp_real_begin_date,
                                            temp_real_end_date
                                         ) = 1));

      IF (temp_status > 0 AND p_allow_multiple_pi_sub_rcnrc <> 1)
      THEN
         /* MTPCUSER_CONFLICTING_PO_SUB_PRICEABLEITEM; */
         return (-289472484);
      END IF;

/* CR 10872: make sure account and po have the same currency

 BP - actually we need to check if a payer has different currency
 In Kona we allow non billable accounts to be created with no currency
if (dbo.IsAccountAndPOSameCurrency(p_id_acc, p_id_po) = '0') */
if p_allow_acc_po_curr_mismatch <> 1 then
	SELECT count(*) into v_count
	FROM t_payment_redirection pr
	INNER JOIN t_av_internal avi on avi.id_acc = pr.id_payer
	INNER JOIN t_po po on  po.id_po = temp_id_po
	INNER JOIN t_pricelist pl ON po.id_nonshared_pl = pl.id_pricelist
	WHERE pr.id_payee = temp_id_acc
	AND avi.c_currency <>  pl.nm_currency_code
	AND (pr.vt_start <= temp_real_end_date AND pr.vt_end >= temp_real_begin_date);
		 
	if (v_count > 0)
	then
		/* MT_ACCOUNT_PO_CURRENCY_MISMATCH */
		return (-486604729);
	end if;
end if;
/* Check for MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE 0xEEBF004EL -289472434
 BR violation */
   SELECT count(*) into v_count
    FROM  t_account tacc
    INNER JOIN t_account_type tacctype on tacc.id_type = tacctype.id_type
    WHERE tacc.id_acc = temp_id_acc AND tacctype.b_CanSubscribe = '0';
if (v_count > 0)
then
  return(-289472434); /* MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE */
end if;

/* check that account type of the account is compatible with the product offering
 since the absense of ANY mappings for the product offering means that PO is "wide open"
 we need to do 2 EXISTS queries */
SELECT count(*) into v_count
FROM t_po_account_type_map atmap
WHERE atmap.id_po = temp_id_po
AND
not exists (
SELECT 1
FROM  t_account tacc
INNER JOIN t_po_account_type_map atmap on atmap.id_po = temp_id_po AND atmap.id_account_type = tacc.id_type
 WHERE  tacc.id_acc = temp_id_acc);
if (v_count > 0)
then
 return (-289472435); /* MTPCUSER_CONFLICTING_PO_ACCOUNT_TYPE */
end if;

      RETURN (1);
   END;

   /* rounds up to the end of a day */
   FUNCTION mtendofday (indate DATE)
      RETURN DATE
   AS
      retval   DATE;
   BEGIN
		retval := TRUNC (indate);
    
		/* ESR-3933 any year < MTMaxDate (i.e 2038-01-01 00:00:00.000) then return the end of the day for indate (i.e 23:59:59 for the time) */
    if (retval < MTMaxDate) then
        retval := retval
             + numtodsinterval(1,'day')
             + numtodsinterval(-1,'second');
    else
    /* ESR-3933 when year > 2037 return 2038-01-01 00:00:00.000 */
    			retval := MTMaxDate;
		end if;
	
    RETURN (retval);
   END;

  FUNCTION mtstartofday (indate DATE)
  return DATE
  as
   retval DATE;
  begin
   select trunc(indate) into retval from dual;
   return (retval);
  end;


function POContainsDiscount
(p_id_po IN integer) return integer
as
retval integer;
begin
select case when count(id_pi_template) > 0 then 1 else 0 end into retval
from t_pl_map
INNER JOIN t_base_props tb on tb.id_prop = t_pl_map.id_pi_template
where t_pl_map.id_po = p_id_po AND tb.n_kind = 40; /* discount */
 return retval;
end;

FUNCTION IsCorporateAccount(p_id_acc IN integer,RefDate IN Date) return INTEGER
as
retval integer;
begin
  for i in (select b_IsCorporate
	          from t_account_type atype
     	      inner join t_account acc on acc.id_type = atype.id_type
	          where acc.id_acc = p_id_acc
						)
  loop
    retval := i.b_IsCorporate;
  end loop;
 return retval;
end;


FUNCTION IsActive(state varchar2) return integer
as
retval integer;
begin
	if state = 'AC' then
		retval := 1;
	else
		retval := 0;
	end if;
	return retval;
end;

FUNCTION IsSuspended(state varchar2) return integer
as
retval integer;
begin
	if state = 'SU' then
		retval := 1;
	else
		retval := 0;
	end if;
	return retval;
end;

FUNCTION IsPendingFinalBill(state varchar2) return integer
as
retval integer;
begin
	if state = 'PF' then
		retval := 1;
	else
		retval := 0;
	end if;
	return retval;
end;

FUNCTION IsClosed(state varchar2) return integer
as
retval integer;
begin
	if state = 'CL' then
		retval := 1;
	else
		retval := 0;
	end if;
	return retval;
end;

FUNCTION IsArchived(state varchar2) return integer
as
retval integer;
begin
	if state = 'AR' then
		retval := 1;
	else
		retval := 0;
	end if;
	return retval;
end;

FUNCTION IsInVisableState(state varchar2) return integer
as
retval integer;
begin
	/* if the account is closed or archived */
	if state <> 'CL' AND state <> 'AR' then
		retval := 1;
	else
		retval := 0;
	end if;
	return retval;
end;


function mtconcat(str1 nvarchar2,str2 nvarchar2) return nvarchar2
as
retval nvarchar2(4000);
begin
  select concat(str1,str2) into retval from dual;
  return retval;
end;

function poConstrainedCycleType(offeringID integer) return integer
as
retval integer;
begin
    select max(result.id_cycle_type) into retval
    from (
    select
      case when t_recur.id_cycle_type is NOT NULL AND
				t_recur.tx_cycle_mode = 'BCR Constrained' then
			t_recur.id_cycle_type
	  else
		case when t_discount.id_cycle_type IS NOT NULL then
			t_discount.id_cycle_type
		else
			case when t_aggregate.id_cycle_type IS NOT NULL THEN
				t_aggregate.id_cycle_type
			else
				NULL
			end
		end
      end as id_cycle_type
	FROM t_pl_map
    LEFT OUTER JOIN t_recur on t_recur.id_prop = t_pl_map.id_pi_template OR t_recur.id_prop = t_pl_map.id_pi_instance
    LEFT OUTER JOIN t_discount on t_discount.id_prop = t_pl_map.id_pi_template  OR t_discount.id_prop = t_pl_map.id_pi_instance
    LEFT OUTER JOIN t_aggregate on t_aggregate.id_prop = t_pl_map.id_pi_template  OR t_aggregate.id_prop = t_pl_map.id_pi_instance
		WHERE
    t_pl_map.id_po = offeringID
    and t_pl_map.id_paramtable is null
    ) result;
    if retval is NULL then
      retval := 0;
    end if;
  return retval;
end;

function IsInSameCorporateAccount(
acc1 IN integer,
acc2 IN integer,
refdate date
) return integer
as
  retval integer;
  v_id_corp1 int;
  v_id_corp2 int;
begin
  retval := 0;
  
  begin

  for x in (select id_ancestor
  from t_account_ancestor anc
  inner join t_account acc
  on anc.id_ancestor = acc.id_acc
  inner join t_account_type atype
  on acc.id_type = atype.id_type
  where anc.id_descendent = acc1
  and refdate between anc.vt_start AND anc.vt_end
  and atype.b_iscorporate = '1')
  loop
		v_id_corp1 := x.id_ancestor;
	end loop;

  for x in (select id_ancestor
  from t_account_ancestor anc
  inner join t_account acc
  on anc.id_ancestor = acc.id_acc
  inner join t_account_type atype
  on acc.id_type = atype.id_type
  where anc.id_descendent = acc2
  and refdate between anc.vt_start AND anc.vt_end
  and atype.b_iscorporate = '1')
  loop
		v_id_corp2 := x.id_ancestor;
	end loop;

		if (v_id_corp1 = v_id_corp2) then
			retval := 1;
		else
			if (v_id_corp1 is null AND v_id_corp2 is null) then
				retval := 1;
			else
				retval := 0;
			end if;
		end if;
  exception when NO_DATA_FOUND then
      retval := 0;
  end;
  return retval;
end;

function POContainsOnlyAbsoluteRates(
p_id_po IN integer
) return integer
as
  retval integer;
begin
	select count(te.id_eff_date) into retval
FROM t_po po
INNER JOIN t_pl_map map ON
	map.id_po = po.id_po
	AND map.id_paramtable IS NOT NULL
	AND map.id_sub IS NULL
LEFT OUTER JOIN t_rsched sched ON
	sched.id_pt = map.id_paramtable
	AND sched.id_pricelist = map.id_pricelist
	AND sched.id_pi_template = map.id_pi_template
INNER JOIN t_effectivedate te ON
	te.id_eff_date = sched.id_eff_date
	/* only absolute or NULL dates */
	AND (te.n_begintype in (2,3) OR te.n_endtype in (2,3))
WHERE po.id_po = p_id_po;
	if(retval > 0) then
		return 0;
  else
    return 1;
	end if;
  return 0;
end;

FUNCTION CheckEBCRCycleTypeCompatible
  (p_EBCRCycleType INT, p_OtherCycleType INT)
RETURN INT is
BEGIN
  /* checks weekly based cycle types */
  IF (((p_EBCRCycleType = 4) OR (p_EBCRCycleType = 5)) AND
      ((p_OtherCycleType = 4) OR (p_OtherCycleType = 5))) then
    RETURN 1;   /* success */
  END IF;
  /* checks monthly based cycle types */
  IF ((p_EBCRCycleType in (1,7,8,9)) AND
      (p_OtherCycleType in (1,7,8,9))) THEN
    RETURN 1;   /* success */
  END IF;
  RETURN 0;     /* failure */
END;

FUNCTION POCONTAINSBILLINGCYCLERELATIVE(
id_po 	IN NUMBER  DEFAULT NULL)
RETURN NUMBER
AS
id_po_ 	NUMBER(10,0) := id_po;
found 	NUMBER(10,0);
/*  product offering ID */
/*  1 if the PO contains BCR PIs, otherwise 0 */
/*  checks for billing cycle relative discounts */

BEGIN
	BEGIN
		SELECT  CASE
		WHEN COUNT(*)>0 THEN 1
		ELSE 0
		END tmpAlias1
		into found
		FROM t_pl_map plm INNER JOIN t_base_props bp
		ON bp.id_prop = plm.id_pi_template INNER JOIN t_discount
		disc
		ON disc.id_prop = bp.id_prop
		WHERE plm.id_po = POCONTAINSBILLINGCYCLERELATIVE.id_po_
		 AND disc.id_usage_cycle IS NULL;
		IF  found = 1 THEN
/*  checks for billing cycle relative recurring charges */
			RETURN found;
		END IF;
		
		SELECT  CASE
		WHEN COUNT(*)>0 THEN 1
		ELSE 0
		END tmpAlias1
		into found
		FROM t_pl_map plm INNER JOIN t_base_props bp
		ON bp.id_prop = plm.id_pi_template INNER JOIN t_recur
		rc
		ON rc.id_prop = bp.id_prop
			WHERE plm.id_po = POCONTAINSBILLINGCYCLERELATIVE.id_po_
			 AND
			(rc.tx_cycle_mode = 'BCR'
			 OR rc.tx_cycle_mode = 'BCR Constrained');
		IF  found = 1 THEN
/*  checks for billing cycle relative aggregate charges */
			RETURN found;
		END IF;
		SELECT  CASE
		WHEN COUNT(*)>0 THEN 1
		ELSE 0
		END tmpAlias1
		into found
		FROM t_pl_map plm INNER JOIN t_base_props bp
		ON bp.id_prop = plm.id_pi_template INNER JOIN t_aggregate
		agg
		ON agg.id_prop = bp.id_prop
			WHERE plm.id_po = POCONTAINSBILLINGCYCLERELATIVE.id_po_
			 AND agg.id_usage_cycle IS NULL;
		RETURN found;
	END;
END POCONTAINSBILLINGCYCLERELATIVE;

FUNCTION CHECKGROUPMEMBERSHIPCYCLECONST(
dt_now 	IN DATE  DEFAULT NULL,
id_group 	IN NUMBER  DEFAULT NULL)
RETURN NUMBER
AS
dt_now_ 	DATE := dt_now;
id_group_ 	NUMBER(10,0) := id_group;
StoO_rowcnt	INTEGER;
id_po 	NUMBER(10,0);
violator 	NUMBER(10,0);
/*  system date */
/*  group ID to check */
/*  1 for success, otherwise negative decimal error code  */
/*  this function enforces the business rule given in CR9906 */
/*  a group subscription to a PO containing a BCR priceable item */
/*  should only have member's with payers that have a usage cycle */
/*  that matches the one specified by the group subscription. */
/*  at any point in time, this cycle consistency should hold true.  */
/*  looks up the PO the group is subscribed to */
BEGIN
	BEGIN
		FOR rec IN ( SELECT   sub.id_po
								 FROM t_group_sub gs INNER JOIN t_sub sub
								ON sub.id_group = gs.id_group
									WHERE gs.id_group = CHECKGROUPMEMBERSHIPCYCLECONST.id_group_)
		LOOP
		   id_po := rec.id_po ;
		
		END LOOP;
/*  this check only applies to PO's that contain a BCR priceable item */
		/*[SPCONV-ERR(48)]:Manual conversion required POContainsBillingCycleRelative()*/

		IF  dbo.POContainsBillingCycleRelative(CHECKGROUPMEMBERSHIPCYCLECONST.id_po) = 1 THEN
		BEGIN
/*  true */
/*  attempts to find a usage cycle mismatch for the member's payers of the group sub */
/*  ideally there should be none */

			FOR rec IN ( SELECT   gsm.id_acc
											 FROM t_gsubmember gsm INNER JOIN t_group_sub gs
												ON gs.id_group = gsm.id_group INNER JOIN t_sub sub
												ON sub.id_group = gs.id_group INNER JOIN t_payment_redirection
									payer
												ON payer.id_payee = gsm.id_acc AND payer.vt_end >=
									sub.vt_start AND payer.vt_start <= sub.vt_end INNER JOIN
									t_acc_usage_cycle auc
												ON auc.id_acc = payer.id_payer AND auc.id_usage_cycle
									<> gs.id_usage_cycle
													WHERE gs.id_group = CHECKGROUPMEMBERSHIPCYCLECONST.id_group_
									 
													 AND
													(
													(CHECKGROUPMEMBERSHIPCYCLECONST.dt_now_  BETWEEN
									sub.vt_start AND sub.vt_end)
													 OR
													(sub.vt_start > CHECKGROUPMEMBERSHIPCYCLECONST.dt_now_)))
			LOOP
			   violator := rec.id_acc ;
			   StoO_rowcnt := nvl(StoO_rowcnt,0)+1;
			END LOOP;
/*  checks all payer's who overlap with the group sub */
/*  cycle mismatch */
/*  checks only the requested group */
/*  only consider current or future group subs */
/*  don't worry about group subs in the past */
/*  MT_GROUP_SUB_MEMBER_CYCLE_MISMATCH */

			IF  StoO_rowcnt > 0 THEN
				RETURN -486604730;
			END IF;
/*  success */


		END;
		END IF;
		RETURN 1;
	END;
END CHECKGROUPMEMBERSHIPCYCLECONST;

FUNCTION CheckGroupMembershipEBCRConstr
(
  p_dt_now DATE, /* system date */
  p_id_group INT     /* group ID to check */
)
RETURN INT  /* 1 for success, negative HRESULT for failure */
AS
TYPE REC IS RECORD
          (
            id_acc INT, /* member account (payee) */
            id_usage_cycle INT, /* payer's cycle */
            b_compatible INT /* EBCR compatibility: 1 or 0 */
          );
TYPE TAB_REC IS TABLE OF REC INDEX by binary_integer;
v_results TAB_REC;

BEGIN

  /* checks to see if a group subscription and all of its */
  /* members comply with EBCR payer cycle constraints: */
  /*   1) that for a member, all of its payers have the same billing cycle */
  /*   2) that this billing cycle is EBCR compatible. */
  /* checks group member's payers */

  SELECT
    pay.id_payee,
    payercycle.id_usage_cycle,
    dbo.CheckEBCRCycleTypeCompatible(payercycle.id_cycle_type, rc.id_cycle_type)
    bulk collect into v_results
  FROM t_gsubmember gsm
  INNER JOIN t_group_sub gs ON gs.id_group = gsm.id_group
  INNER JOIN t_sub sub ON sub.id_group = gs.id_group   INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po
  INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
  INNER JOIN t_payment_redirection pay ON
    pay.id_payee = gsm.id_acc AND
    /* checks all payer's who overlap with the group sub */
    pay.vt_end >= sub.vt_start AND
    pay.vt_start <= sub.vt_end
  INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = pay.id_payer
  INNER JOIN t_usage_cycle payercycle ON payercycle.id_usage_cycle = auc.id_usage_cycle
  WHERE
    rc.tx_cycle_mode = 'EBCR' AND
    rc.b_charge_per_participant = 'Y' AND
    gs.id_group = p_id_group AND
    plmap.id_paramtable IS NULL AND
    /* TODO: it would be better if we didn't consider subscriptions that ended */
    /*       in a hard closed interval so that retroactive changes would be properly guarded. */
    /* only consider current or future group subs */
    /* don't worry about group subs in the past */
    ((p_dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
     (sub.vt_start > p_dt_now));

	/* no results means on EBCR's to check */
	if v_results is not null and v_results.count < 1 then
		return 1;
	end if;

  /* checks that members' payers are compatible with the EBCR cycle type */
  FOR i in v_results.FIRST .. v_results.last
  LOOP
    IF v_results(i).b_compatible =0 THEN
        RETURN -289472443; /* MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_MEMBER */
    END IF;
  END LOOP;


  /* checks for each member there is only one payer cycle across all payers */
  FOR i in v_results.FIRST .. v_results.last
  LOOP
      FOR j in v_results.FIRST .. v_results.last
      LOOP
        IF v_results(i).id_acc = v_results(j).id_acc AND
           v_results(i).id_usage_cycle <> v_results(j).id_usage_cycle THEN
            RETURN -289472442; /* MTPCUSER_EBCR_MEMBERS_CONFLICT_WITH_EACH_OTHER */
        END IF;
      END LOOP;
  END LOOP;

  RETURN 1; /* success */
END;

FUNCTION CHECKGROUPRECEIVEREBCRCONS
(
  p_dt_now DATE, /* system date */
  p_id_group INT     /* group ID to check */
)
RETURN INT  /* 1 for success, negative HRESULT for failure */
AS
    TYPE REC IS RECORD
      (
        id_acc INT, /* receiver account */
        id_usage_cycle INT, /* payer's cycle */
        b_compatible INT /* EBCR compatibility: 1 or 0 */
      );
    TYPE TAB_REC IS TABLE OF REC INDEX BY BINARY_INTEGER;
    v_results TAB_REC;
BEGIN
  /* checks to see if a group subscription and all of its' */
  /* receivers' payers comply with the EBCR payer cycle constraints: */
  /* 1) that all receivers' payers must have the same billing cycle */
  /* 2) that billing cycle must be EBCR compatible. */


  /* store intermediate results away for later use since different groupings will need to be made */

  SELECT DISTINCT gsrm.id_acc, payercycle.id_usage_cycle, dbo.CheckEBCRCycleTypeCompatible(payercycle.id_cycle_type, rc.id_cycle_type)
  BULK COLLECT INTO v_results
  FROM t_gsub_recur_map gsrm
  INNER JOIN t_group_sub gs ON gs.id_group = gsrm.id_group
  INNER JOIN t_sub sub ON sub.id_group = gs.id_group
  INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po AND
                               plmap.id_pi_instance = gsrm.id_prop
  INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
  INNER JOIN t_payment_redirection payer ON
    payer.id_payee = gsrm.id_acc AND
    /* checks all payer's who overlap with the group sub */
    payer.vt_end >= sub.vt_start AND
    payer.vt_start <= sub.vt_end
  INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = payer.id_payer
  INNER JOIN t_usage_cycle payercycle ON payercycle.id_usage_cycle = auc.id_usage_cycle
  WHERE
    rc.tx_cycle_mode = 'EBCR' AND
    rc.b_charge_per_participant = 'N' AND
    /* checks only the requested group */
    gs.id_group = p_id_group AND
    plmap.id_paramtable IS NULL AND
    /* only consider receivers based on wall-clock transaction time */
    p_dt_now BETWEEN gsrm.tt_start AND gsrm.tt_end AND
    /* TODO: it would be better if we didn't consider subscriptions that ended */
    /*       in a hard closed interval so that retroactive changes would be properly guarded. */
    /* only consider current or future group subs     don't worry about group subs in the past */
    ((p_dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
     (sub.vt_start > p_dt_now));

  /* checks that receivers' payers are compatible with the EBCR cycle type */
  IF v_results.EXISTS(1) THEN
      FOR I IN v_results.first .. v_results.last
      LOOP
        IF v_results(i).b_compatible = 0 THEN
            RETURN -289472441; /* MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_RECEIVER */
        END IF;
      END LOOP;
      IF v_results.COUNT > 1 THEN
         RETURN -289472440;
      END IF;
  END IF;

  RETURN 1; /* success */
END;

    function csvtoint (p_id_instances varchar2)return tab_id_instance is
        v_tab_id_instance tab_id_instance:=tab_id_instance();
    begin
        if instr(p_id_instances,',',1) = 0 then
            v_tab_id_instance.extend(1);
            v_tab_id_instance(1) := to_number(p_id_instances);
            return v_tab_id_instance;
        elsif instr(p_id_instances,',',1) > 1 then
            v_tab_id_instance.extend(1);
            v_tab_id_instance(1) := to_number(substr(p_id_instances,1,instr(p_id_instances,',',1)-1));
            for i in 2..4000
            loop
                v_tab_id_instance.extend(1);
                if (instr(p_id_instances,',',1,i) > 0) then
                    v_tab_id_instance(i):= to_number( substr(p_id_instances,(instr(p_id_instances,',',1,i-1)+1),((instr(p_id_instances,',',1,i))-(instr(p_id_instances,',',1,i-1))-1)) );
                else
                    v_tab_id_instance(i):= to_number(substr(p_id_instances,(instr(p_id_instances,',',1,i-1)+1),length(p_id_instances)- instr(p_id_instances,',',1,i-1)));
                    exit;
                end if;
            end loop;
            return v_tab_id_instance;
        end if;
    end csvtoint;

    function String2Table(p_str in clob, p_delim in varchar2 default '.')
  	  return  str_tab
    as
  	   l_str long default p_str || p_delim;
  	   l_n number;
  	   l_data str_tab := str_tab();
    begin
  	 loop
  	     l_n := instr( l_str, p_delim );
  	     exit when (nvl(l_n,0) = 0);
  	     l_data.extend;
   	     l_data( l_data.count ) := ltrim(rtrim(substr(l_str,1,l_n-1)));
  	     l_str := substr( l_str, l_n+length(p_delim) );
     end loop;
     return l_data;
    end String2Table;

    function csvtostrtab(csv varchar2)
    return str_tab
    is
      tab str_tab := str_tab();
      str varchar2(4000) := csv;
      tok varchar2(4000);
      apos int := 1;
      zpos int := 1;
      i int := 0;
    begin

      str := str || ',';
      while zpos < length(str)
      loop
        zpos := instr(str, ',', apos);
        tok := substr(str, apos, zpos-apos);
        apos := zpos + 1;

        i := i + 1;
        tab.extend;
        tab(i) := tok;
        
      end loop;
      
      return tab;

    end csvtostrtab;


    function strtabtocsv(
      tab str_tab)
    return varchar2
    as
      csv varchar2(4000) := '';
      i   number;

    begin

      i := tab.first;
      while i is not null
      loop

        csv := csv || tab(i)
          || case when i < tab.last then ', ' else '' end;

        i := tab.next(i);
      end loop;

      return csv;
      
    end strtabtocsv;

   
FUNCTION DERIVEEBCRCYCLE(
    usageCycle    IN NUMBER DEFAULT NULL,
    subStart      IN DATE DEFAULT NULL,
    ebcrCycleType IN NUMBER DEFAULT NULL)
  RETURN NUMBER
AS
  usageCycle_ NUMBER(10,0)    := usageCycle;
  subStart_ DATE              := subStart;
  ebcrCycleType_   NUMBER(10,0) := ebcrCycleType;
  StoO_rowcnt      INTEGER;
  usageCycleType   NUMBER(10,0);
  derivedEBCRCycle NUMBER(10,0);
  startDay         NUMBER(10,0);
  startMonth       NUMBER(10,0);
  endDay           NUMBER(10,0);
  endOfMonth       NUMBER(10,0);
  /*  billing cycle of the account (context-sensitive) */
  /*  start date of the subscription/membership (context-sensitive) */
  /*  cycle type of the EBCR PI  */
  /*  looks up the usage cycle's cycle type */
BEGIN
  BEGIN
    FOR rec IN
    (SELECT id_cycle_type
    FROM t_usage_cycle
    WHERE id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
    )
    LOOP
      usageCycleType := rec.id_cycle_type ;
      StoO_rowcnt    := NVL(StoO_rowcnt,0)+1;
    END LOOP;
    IF ( StoO_rowcnt != 1) THEN
      /*  ERROR: Exactly one usage cycle type was not found for given usage cycle ID */
      /*  if  cycle types are identical then EBCR reduces to a trivial BCR case */
      RETURN -1;
    END IF;
    IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = DERIVEEBCRCYCLE.usageCycleType) THEN
      /*  Case map: */
      /*    -Weekly EBCR */
      /*       -Bi-weekly BC */
      /*    - Bi-weekly EBCR */
      /*       -Weekly BC */
      /*    -Monthly EBCR */
      /*       -Quarterly BC */
      /*       -Annual BC */
      /*    -Quarterly EBCR */
      /*       -Monthly BC */
      /*       -Annual BC */
      /*    -Annual EBCR */
      /*       -Monthly BC */
      /*       -Quarterly BC */
      /*  Weekly EBCR */
      RETURN DERIVEEBCRCYCLE.usageCycle_;
    END IF;
    IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = 4) THEN
      BEGIN
        /*  only Bi-weekly cycle type is permitted */
        IF ( DERIVEEBCRCYCLE.usageCycleType != 5) THEN
          /*  ERROR: unsupported EBCR cycle combination */
          RETURN -3;
        END IF;
        /*  retrieves the Bi-weekly start day */
        FOR rec IN
        (SELECT start_day
        FROM t_usage_cycle uc
        WHERE uc.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
        )
        LOOP
          startDay := rec.start_day ;
        END LOOP;
        /*  reduces the start day [1,14] to a start day between [1,7] */
        DERIVEEBCRCYCLE.startDay     := MOD(DERIVEEBCRCYCLE.startDay, 7);
        IF ( DERIVEEBCRCYCLE.startDay = 0) THEN
          /*    January 2000     */
          /*  Su Mo Tu We Th Fr Sa */
          /*                     1 */
          /*   2  3  4  5  6  7  8 */
          /*   9 10 11 12 13 14 15 */
          /*  16 17 18 19 20 21 22 */
          /*  23 24 25 26 27 28 29 */
          /*  30 31  */
          /*  Bi-weekly      Weekly */
          /*  start day  --> end day of week */
          /*  1, 8              6 */
          /*  2, 9              7 */
          /*  3, 10             1 */
          /*  4, 11             2 */
          /*  5, 12             3 */
          /*  6, 13             4 */
          /*  7, 14             5 */
          /*  translates the start day to an end day of week for use with Weekly  */
          DERIVEEBCRCYCLE.startDay := 7;
        END IF;
        DERIVEEBCRCYCLE.endDay     := DERIVEEBCRCYCLE.startDay - 2;
        IF ( DERIVEEBCRCYCLE.endDay < 1) THEN
          /*  handles wrap around */
          DERIVEEBCRCYCLE.endDay := DERIVEEBCRCYCLE.endDay + 7;
        END IF;
        FOR rec IN
        (SELECT ebcr.id_usage_cycle
        FROM t_usage_cycle ebcr
        WHERE ebcr.id_cycle_type = DERIVEEBCRCYCLE.ebcrCycleType_
        AND ebcr.day_of_week     = DERIVEEBCRCYCLE.endDay
        )
        LOOP
          derivedEBCRCycle := rec.id_usage_cycle ;
        END LOOP;
      END;
    ELSE
      /*  Bi-weekly EBCR */
      IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = 5) THEN
        BEGIN
          /*  only a Weekly cycle type is permitted */
          IF ( DERIVEEBCRCYCLE.usageCycleType != 4) THEN
            /*  ERROR: unsupported EBCR cycle combination */
            RETURN -3;
          END IF;
          /*  retrieves the Weekly end day */
          FOR rec IN
          (SELECT day_of_week
          FROM t_usage_cycle uc
          WHERE uc.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
          )
          LOOP
            endDay := rec.day_of_week ;
          END LOOP;
          /*  performs the reverse translation described in the Weekly EBCR case */
          /*  NOTE: subscription information is ignored */
          DERIVEEBCRCYCLE.startDay     := DERIVEEBCRCYCLE.endDay + 2;
          IF ( DERIVEEBCRCYCLE.startDay > 7) THEN
            /*  handles wrap around */
            DERIVEEBCRCYCLE.startDay := DERIVEEBCRCYCLE.startDay - 7;
          END IF;
          FOR rec IN
          (SELECT ebcr.id_usage_cycle
          FROM t_usage_cycle ebcr
          WHERE ebcr.id_cycle_type = DERIVEEBCRCYCLE.ebcrCycleType_
          AND ebcr.start_day       = DERIVEEBCRCYCLE.startDay
          AND ebcr.start_month     = 1
          AND ebcr.start_year      = 2000
          )
          LOOP
            derivedEBCRCycle := rec.id_usage_cycle ;
          END LOOP;
        END;
      ELSE
        /*  Monthly EBCR */
        IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = 1) THEN
          BEGIN
            /*  only Quarterly, SemiAnnual, and Annual billing cycle types are legal for this case */
            IF ( DERIVEEBCRCYCLE.usageCycleType NOT IN(7, 8, 9)) THEN
              /*  ERROR: unsupported EBCR cycle combination */
              /*  the usage cycle type is Quarterly, Semiannual, or Annual */
              /*  all of which use the same start_day property */
              RETURN -3;
            END IF;
            FOR rec IN
            (SELECT start_day
            FROM t_usage_cycle uc
            WHERE uc.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
            )
            LOOP
              startDay := rec.start_day ;
            END LOOP;
            /*  translates the start day to an end day since Monthly cycle types */
            /*  use end days and Quarterly and Annual cycle types use start days */
            BEGIN
              DERIVEEBCRCYCLE.endDay     := DERIVEEBCRCYCLE.startDay - 1;
              IF ( DERIVEEBCRCYCLE.endDay < 1) THEN
                /*  wraps around to EOM */
                DERIVEEBCRCYCLE.endDay := 31;
              END IF;
            END;
            FOR rec IN
            (SELECT ebcr.id_usage_cycle
            FROM t_usage_cycle ebcr
            WHERE ebcr.id_cycle_type = DERIVEEBCRCYCLE.ebcrCycleType_
            AND ebcr.day_of_month    = DERIVEEBCRCYCLE.endDay
            )
            LOOP
              derivedEBCRCycle := rec.id_usage_cycle ;
            END LOOP;
          END;
        ELSE
          /*  Quarterly EBCR */
          IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = 7) THEN
            BEGIN
              /*  Monthly billing cycle type */
              IF ( DERIVEEBCRCYCLE.usageCycleType = 1) THEN
                BEGIN
                  /*  infers the start month from the subscription start date    */
                  /* CORE-8006 */
                  For rec in
                    (
                        select TO_NUMBER(TO_CHAR( tui.dt_start, 'DD')) tui_start_day,
							TO_NUMBER(TO_CHAR( tui.dt_start, 'MM')) tui_start_month
                          from t_usage_interval tui
                          join t_usage_cycle tuc on tuc.id_usage_cycle = tui.id_usage_cycle
                          where tui.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
                            and tui.dt_start <= DERIVEEBCRCYCLE.subStart_
                            and tui.dt_end > DERIVEEBCRCYCLE.subStart_
                    )
                  LOOP
					  DERIVEEBCRCYCLE.startDay := rec.tui_start_day;
                      DERIVEEBCRCYCLE.startMonth := rec.tui_start_month;
                  END LOOP;
					
				  /* Leap years are a problem.  If the last day of the month is the 29th, it's really the 28th for this purpose */
				  IF (DERIVEEBCRCYCLE.startMonth = 2 AND DERIVEEBCRCYCLE.startDay = 29) THEN
					  DERIVEEBCRCYCLE.startDay := 28;
				  END IF;
				  
                  DERIVEEBCRCYCLE.startMonth     := MOD(DERIVEEBCRCYCLE.startMonth, 3);
                  IF ( DERIVEEBCRCYCLE.startMonth = 0) THEN
                    DERIVEEBCRCYCLE.startMonth   := 3;
                  END IF;
                END;
              ELSE
                /*  Annual or semiannual billing cycle type */
                IF ( DERIVEEBCRCYCLE.usageCycleType IN (8,9)) THEN
                  BEGIN
                    FOR rec IN
                    (SELECT start_day,
                      start_month
                    FROM t_usage_cycle uc
                    WHERE uc.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
                    )
                    LOOP
                      startDay   := rec.start_day ;
                      startMonth := rec.start_month ;
                    END LOOP;
                  END;
                ELSE
                  /*  ERROR: unsupported EBCR cycle combination */
                  RETURN -3;
                END IF;
              END IF;
              /*  translates the Annual start month [1 - 12] to a Quarterly start month [1 - 3] */
              DERIVEEBCRCYCLE.startMonth     := MOD(DERIVEEBCRCYCLE.startMonth, 3);
              IF ( DERIVEEBCRCYCLE.startMonth = 0) THEN
                DERIVEEBCRCYCLE.startMonth   := 3;
              END IF;
              FOR rec IN
              (SELECT ebcr.id_usage_cycle
              FROM t_usage_cycle ebcr
              WHERE ebcr.id_cycle_type = DERIVEEBCRCYCLE.ebcrCycleType_
              AND ebcr.start_day       = DERIVEEBCRCYCLE.startDay
              AND ebcr.start_month     = DERIVEEBCRCYCLE.startMonth
              )
              LOOP
                derivedEBCRCycle := rec.id_usage_cycle ;
              END LOOP;
            END;
          ELSE
            /*  Annual EBCR */
            IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = 8) THEN
              BEGIN
                /*  Monthly billing cycle type */
                IF ( DERIVEEBCRCYCLE.usageCycleType = 1) THEN
                  BEGIN
                    /*  infers the start month from the subscription start date    */
                    /* CORE-8006 */
                   For rec in
                    (
                        select TO_NUMBER(TO_CHAR( tui.dt_start, 'DD')) tui_start_day,
							TO_NUMBER(TO_CHAR( tui.dt_start, 'MM')) tui_start_month
                          from t_usage_interval tui
                          join t_usage_cycle tuc on tuc.id_usage_cycle = tui.id_usage_cycle
                          where tui.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
                            and tui.dt_start <= DERIVEEBCRCYCLE.subStart_
                            and tui.dt_end > DERIVEEBCRCYCLE.subStart_
                    )
                    LOOP
					  DERIVEEBCRCYCLE.startDay := rec.tui_start_day;
                      DERIVEEBCRCYCLE.startMonth := rec.tui_start_month;
                    END LOOP;
					
					/* Leap years are a problem.  If the last day of the month is the 29th, it's really the 28th for this purpose */
					IF (DERIVEEBCRCYCLE.startMonth = 2 AND DERIVEEBCRCYCLE.startDay = 29) THEN
						DERIVEEBCRCYCLE.startDay := 28;
					END IF;
                  END;
                ELSE
                  /*  Quarterly or semiannual billing cycle type */
                  IF ( DERIVEEBCRCYCLE.usageCycleType IN (7,9)) THEN
                    BEGIN
                      FOR rec IN
                      (SELECT start_day,
                        start_month
                      FROM t_usage_cycle uc
                      WHERE uc.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
                      )
                      LOOP
                        startDay   := rec.start_day ;
                        startMonth := rec.start_month ;
                      END LOOP;
                      endOfMonth  := TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(TO_CHAR(startMonth,'09')||'1999','MMYYYY')),'DD') );
                      IF (startDay > endOfMonth) THEN
                        startDay  := endOfMonth;
                      END IF;
                    END;
                  ELSE
                    /*  ERROR: unsupported usage cycle combination */
                    RETURN -3;
                  END IF;
                END IF;
                FOR rec IN
                (SELECT ebcr.id_usage_cycle
                FROM t_usage_cycle ebcr
                WHERE ebcr.id_cycle_type = DERIVEEBCRCYCLE.ebcrCycleType_
                AND ebcr.start_day       = DERIVEEBCRCYCLE.startDay
                AND ebcr.start_month     = DERIVEEBCRCYCLE.startMonth
                )
                LOOP
                  derivedEBCRCycle := rec.id_usage_cycle ;
                END LOOP;
              END;
            ELSE
				/* SemiAnnual EBCR */
              IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = 9) THEN
                BEGIN
                  /*  Monthly billing cycle type */
                  IF ( DERIVEEBCRCYCLE.usageCycleType = 1) THEN
                    BEGIN
                      /*  infers the start month from the subscription start date    */
					  /* CORE-8006 */
					  For rec in
						(
							select TO_NUMBER(TO_CHAR( tui.dt_start, 'DD')) tui_start_day,
								TO_NUMBER(TO_CHAR( tui.dt_start, 'MM')) tui_start_month
							  from t_usage_interval tui
							  join t_usage_cycle tuc on tuc.id_usage_cycle = tui.id_usage_cycle
							  where tui.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
								and tui.dt_start <= DERIVEEBCRCYCLE.subStart_
								and tui.dt_end > DERIVEEBCRCYCLE.subStart_
						)
					  LOOP
						  DERIVEEBCRCYCLE.startDay := rec.tui_start_day;
						  DERIVEEBCRCYCLE.startMonth := rec.tui_start_month;
					  END LOOP;

					  /* Leap years are a problem.  If the last day of the month is the 29th, it's really the 28th for this purpose */
					  IF (DERIVEEBCRCYCLE.startMonth = 2 AND DERIVEEBCRCYCLE.startDay = 29) THEN
						DERIVEEBCRCYCLE.startDay := 28;
					  END IF;
                    END;
                  ELSE
                    /*  Quarterly or annual billing cycle type */
                    IF ( DERIVEEBCRCYCLE.usageCycleType IN (7,8)) THEN
                      BEGIN
                        FOR rec IN
                        (SELECT start_day,
                          start_month
                        FROM t_usage_cycle uc
                        WHERE uc.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
                        )
                        LOOP
                          startDay   := rec.start_day ;
                          startMonth := rec.start_month ;
                        END LOOP;
                        endOfMonth  := TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(TO_CHAR(startMonth,'09')||'1999','MMYYYY')),'DD') );
                        IF (startDay > endOfMonth) THEN
                          startDay  := endOfMonth;
                        END IF;
                      END;
                    ELSE
                      /*  ERROR: unsupported usage cycle combination */
                      RETURN -3;
                    END IF;
                  END IF;
                  FOR rec IN
                  (SELECT ebcr.id_usage_cycle
                  FROM t_usage_cycle ebcr
                  WHERE ebcr.id_cycle_type = DERIVEEBCRCYCLE.ebcrCycleType_
                  AND ebcr.start_day       = DERIVEEBCRCYCLE.startDay
                  AND ebcr.start_month     = DERIVEEBCRCYCLE.startMonth
                  )
                  LOOP
                    derivedEBCRCycle := rec.id_usage_cycle ;
                  END LOOP;
                END;
              ELSE
                /*  unsupported EBCR cycle type */
                RETURN -4;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
    IF ( DERIVEEBCRCYCLE.derivedEBCRCycle IS NULL) THEN
      /*  derivation failed */
      RETURN -5;
    END IF;
    RETURN DERIVEEBCRCYCLE.derivedEBCRCycle;
  END;
END DERIVEEBCRCYCLE;

FUNCTION DOESACCOUNTHAVEPAYEES(
id_acc 	IN NUMBER  DEFAULT NULL,
dt_ref 	IN DATE  DEFAULT NULL)
RETURN VARCHAR2
AS
id_acc_ 	NUMBER(10,0) := id_acc;
dt_ref_ 	DATE := dt_ref;
returnValue 	CHAR(1);
BEGIN
	BEGIN
		SELECT  CASE
		WHEN count(*)>0 THEN 'Y'
		ELSE 'N'
		END tmpAlias1
		into returnValue
		FROM t_payment_redirection
		WHERE id_payer = DOESACCOUNTHAVEPAYEES.id_acc_
		 and
		(
		(DOESACCOUNTHAVEPAYEES.dt_ref_  BETWEEN vt_start AND
		vt_end)
		 OR DOESACCOUNTHAVEPAYEES.dt_ref_ < vt_start);

		IF  ( DOESACCOUNTHAVEPAYEES.returnValue is NULL) THEN
		BEGIN
			
			DOESACCOUNTHAVEPAYEES.returnValue :=  'N';
		END;
		END IF;
		RETURN DOESACCOUNTHAVEPAYEES.returnValue;
	END;
END DOESACCOUNTHAVEPAYEES;

    FUNCTION GETCURRENTINTERVALID(
    aDTNow 	IN DATE  DEFAULT NULL,
    aDTSession 	IN DATE  DEFAULT NULL,
    aAccountID 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER
    AS
    aDTNow_ 	DATE := aDTNow;
    aDTSession_ 	DATE := aDTSession;
    aAccountID_ 	NUMBER(10,0) := aAccountID;
    retVal 	NUMBER(10,0);
    BEGIN
        BEGIN
            FOR rec IN ( SELECT   id_usage_interval
                                     FROM t_acc_usage_interval aui INNER JOIN t_usage_interval
                                    ui
                                    ON ui.id_interval = aui.id_usage_interval
                                        WHERE ui.tx_interval_status  <> 'H'
                                         AND GETCURRENTINTERVALID.aDTSession_  BETWEEN ui.dt_start
                                    AND ui.dt_end
                                         AND
                                        (
                                        (aui.dt_effective IS NULL)
                                         OR
                                        (aui.dt_effective <= GETCURRENTINTERVALID.aDTNow_))
                                         AND aui.id_acc = GETCURRENTINTERVALID.aAccountID_)
            LOOP
               retVal := rec.id_usage_interval ;
            
            END LOOP;
            RETURN GETCURRENTINTERVALID.retVal;
        END;
    END GETCURRENTINTERVALID;

FUNCTION ISACCOUNTANDPOSAMECURRENCY(
id_acc 	IN NUMBER  DEFAULT NULL,
id_po 	IN NUMBER  DEFAULT NULL)
RETURN VARCHAR2
AS
id_acc_ 	NUMBER(10,0) := id_acc;
id_po_ 	NUMBER(10,0) := id_po;
sameCurrency 	CHAR(1);
BEGIN
	BEGIN
		FOR rec IN ( SELECT
		 CASE
		WHEN (
				SELECT  COUNT(id_po)
				 FROM t_pricelist pl inner JOIN t_po po
		ON po.id_nonshared_pl = pl.id_pricelist AND po.id_po = ISACCOUNTANDPOSAMECURRENCY.id_po_
		inner JOIN t_av_internal av
		ON av.c_currency = pl.nm_currency_code AND av.id_acc = ISACCOUNTANDPOSAMECURRENCY.id_acc_
		 )=0 THEN '0'
		ELSE '1'
		END tmpAlias1
		 FROM DUAL )
		LOOP
		  
		 sameCurrency := rec.tmpAlias1 ;
		
		END LOOP;
		RETURN ISACCOUNTANDPOSAMECURRENCY.sameCurrency;
	END;
END ISACCOUNTANDPOSAMECURRENCY;

    FUNCTION ISACCOUNTPAYINGFOROTHERS(
    id_acc 	IN NUMBER  DEFAULT NULL,
    dt_ref 	IN DATE  DEFAULT NULL)
    RETURN VARCHAR2
    AS
    id_acc_ 	NUMBER(10,0) := id_acc;
    dt_ref_ 	DATE := dt_ref;
    returnValue 	CHAR(1);
    BEGIN
        BEGIN
            SELECT  CASE
            WHEN count(*)>0 THEN 'Y'
            ELSE 'N'
            END tmpAlias1
			into returnValue
                                     FROM t_payment_redirection
                                        WHERE id_payer = ISACCOUNTPAYINGFOROTHERS.id_acc_
                                         and id_payer <> id_payee
                                         and
                                        (
                                        (ISACCOUNTPAYINGFOROTHERS.dt_ref_  BETWEEN vt_start AND
                                    vt_end)
                                         OR ISACCOUNTPAYINGFOROTHERS.dt_ref_ < vt_start);

    /* this is the key difference between this and DoesAccountHavePayees */


            IF  ( ISACCOUNTPAYINGFOROTHERS.returnValue is NULL) THEN
            BEGIN
                
                ISACCOUNTPAYINGFOROTHERS.returnValue :=  'N';
            END;
            END IF;
            RETURN ISACCOUNTPAYINGFOROTHERS.returnValue;
        END;
    END ISACCOUNTPAYINGFOROTHERS;

    FUNCTION IsBillingCycleUpdProhibitedByG
    (
      p_dt_now DATE,
      p_id_acc INT
    )
    RETURN INT IS
    v_count number:=0;
    BEGIN

      /* checks if the account pays for a member of a group subscription */
      /* associated with a Per Participant EBCR RC */
        SELECT count(1) into v_count
        FROM t_gsubmember gsm
        INNER JOIN t_group_sub gs ON gs.id_group = gsm.id_group
        INNER JOIN t_sub sub ON sub.id_group = gs.id_group
        INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po
        INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
        INNER JOIN t_payment_redirection payer ON
        payer.id_payee = gsm.id_acc AND
        /* checks all payer's who overlap with the group sub */
        payer.vt_end >= sub.vt_start AND
        payer.vt_start <= sub.vt_end
        INNER JOIN t_acc_usage_cycle payercycle ON payercycle.id_acc = payer.id_payer
        WHERE
          rc.tx_cycle_mode = 'EBCR' AND
          rc.b_charge_per_participant = 'Y' AND
          payer.id_payer = p_id_acc AND
          plmap.id_paramtable IS NULL AND
          /* TODO: it would be better if we didn't consider subscriptions that ended */
          /*       in a hard closed interval so that retroactive changes would be properly guarded. */
          /* only consider current or future group subs */
          /* don't worry about group subs in the past */
          ((p_dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
           (sub.vt_start > p_dt_now));
        if v_count>0 then
            RETURN -289472439;  /* MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_MEMBER */
        end if;

        v_count := 0;

      /* checks if the account pays for a receiver of a group subscription */
      /* associated with a Per Subscriber EBCR RC */

        SELECT count(1) into v_count
        FROM t_gsub_recur_map gsrm
        INNER JOIN t_group_sub gs ON gs.id_group = gsrm.id_group
        INNER JOIN t_sub sub ON sub.id_group = gs.id_group
        INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po AND
                                     plmap.id_pi_instance = gsrm.id_prop
        INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
        INNER JOIN t_payment_redirection payer ON
          payer.id_payee = gsrm.id_acc AND
          /* checks all payer's who overlap with the group sub */
          payer.vt_end >= sub.vt_start AND
          payer.vt_start <= sub.vt_end     INNER JOIN t_acc_usage_cycle payercycle ON payercycle.id_acc = payer.id_payer
        WHERE
          rc.tx_cycle_mode = 'EBCR' AND
          rc.b_charge_per_participant = 'N' AND
          /* checks only the requested group */
          payer.id_payer = p_id_acc AND
          plmap.id_paramtable IS NULL AND
          /* only consider receivers based on wall-clock transaction time */
          p_dt_now BETWEEN gsrm.tt_start AND gsrm.tt_end AND
          /* TODO: it would be better if we didn't consider subscriptions that ended */
          /*       in a hard closed interval so that retroactive changes would be properly guarded. */
          /* only consider current or future group subs */
          /* don't worry about group subs in the past */
          ((p_dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
           (sub.vt_start > p_dt_now));
        IF v_count > 0 then
            RETURN -289472438;  /* MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_RECEIVER */
        end if;
        
      RETURN 1; /* success, can update the billing cycle */
    END;

    FUNCTION ISINTERVALOPEN(
    aAccountID 	IN NUMBER  DEFAULT NULL,
    aIntervalID IN NUMBER  DEFAULT NULL)
    RETURN NUMBER
    AS
    aAccountID_ NUMBER(10,0) := aAccountID;
    aIntervalID_ NUMBER(10,0) := aIntervalID;
    retVal 	NUMBER(10,0);
    BEGIN
        BEGIN
            ISINTERVALOPEN.retval := 0;
            SELECT
             CASE
            WHEN (SELECT tx_status
                  FROM t_acc_usage_interval ui
                  WHERE id_acc = ISINTERVALOPEN.aAccountID_
                  AND id_usage_interval = ISINTERVALOPEN.aIntervalID_)
                  IN ('B','O')
            THEN 1
            ELSE 0
            END tmpAlias1
			into retVal
             FROM DUAL;

			RETURN ISINTERVALOPEN.retVal;
        END;
    END ISINTERVALOPEN;

    FUNCTION LOOKUPACCOUNT(
    login 	IN VARCHAR2  DEFAULT NULL,
    namespace 	IN VARCHAR2  DEFAULT NULL)
    RETURN NUMBER
    AS
    login_ 	VARCHAR2(510) := login;
    namespace_ 	VARCHAR2(80) := namespace;
    retval 	NUMBER(10,0);
    BEGIN
        BEGIN
            SELECT   id_acc
			into retval
			FROM t_account_mapper
			WHERE UPPER(nm_login) = UPPER(LOOKUPACCOUNT.login_)
			AND UPPER(LOOKUPACCOUNT.namespace_) = upper(nm_space);

			IF  LOOKUPACCOUNT.retval is NULL THEN
                LOOKUPACCOUNT.retval := -1;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                LOOKUPACCOUNT.retval := -1;
        END;
        RETURN LOOKUPACCOUNT.retval;
    END LOOKUPACCOUNT;

    FUNCTION MTCOMPUTEEFFECTIVEENDDATE(
    type_ 	IN NUMBER  DEFAULT NULL,
    offset 	IN NUMBER  DEFAULT NULL,
    base 	IN DATE  DEFAULT NULL,
    sub_begin 	IN DATE  DEFAULT NULL,
    id_usage_cycle 	IN NUMBER  DEFAULT NULL)
    RETURN DATE
    AS
    type__ 	NUMBER(10,0) := type_;
    offset_ 	NUMBER(10,0) := offset;
    base_ 	DATE := base;
    sub_begin_ 	DATE := sub_begin;
    id_usage_cycle_ 	NUMBER(10,0) := id_usage_cycle;
    current_interval_end 	DATE;
    BEGIN
        BEGIN
            IF  ( MTCOMPUTEEFFECTIVEENDDATE.type__ = 1) THEN
            BEGIN
                RETURN MTCOMPUTEEFFECTIVEENDDATE.base_;
            END;
            ELSE
                IF  ( MTCOMPUTEEFFECTIVEENDDATE.type__ = 2) THEN
                BEGIN
                    /*[SPCONV-ERR(22)]:Manual conversion required MTEndOfDay()*/

                    RETURN MTEndOfDay(MTCOMPUTEEFFECTIVEENDDATE.sub_begin_ + MTCOMPUTEEFFECTIVEENDDATE.offset_);
                END;
                ELSE
                    IF  ( MTCOMPUTEEFFECTIVEENDDATE.type__ = 3) THEN
                    BEGIN
                        FOR rec IN ( SELECT   dt_end
                                                                 FROM t_pc_interval
                                                                        WHERE MTCOMPUTEEFFECTIVEENDDATE.base_  BETWEEN
                                                dt_start AND dt_end
                                                                         and id_cycle = MTCOMPUTEEFFECTIVEENDDATE.id_usage_cycle_)
                        LOOP
                           current_interval_end := rec.dt_end ;
                        
                        END LOOP;
                        RETURN MTCOMPUTEEFFECTIVEENDDATE.current_interval_end;
                    END;
                    END IF;
                    END IF;
                    END IF;
                RETURN NULL;
            END;
    END MTCOMPUTEEFFECTIVEENDDATE;

    FUNCTION WARNONEBCRMEMBERSTARTDATECHANG(
    id_sub 	IN NUMBER  DEFAULT NULL,
    id_acc 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER
    AS
        id_sub_ 	NUMBER(10,0) := id_sub;
        id_acc_ 	NUMBER(10,0) := id_acc;
        StoO_selcnt	INTEGER;
        StoO_rowcnt	INTEGER;
        /* subscription ID */
        /* member account ID */
        /* 1 if a warning should be raised, 0 otherwise */
        /* checks to see if the subscription is associated with an EBCR RC */
        /* and that the EBCR cycle type and the subscriber's billing cycle */
        /* are such that the start date would be used in derivations */
    BEGIN
        BEGIN
            
            BEGIN
            StoO_selcnt := 0;
            StoO_rowcnt := 0;
            SELECT 1 INTO StoO_selcnt
            FROM DUAL
            WHERE  EXISTS (
                        SELECT  *
                         FROM t_sub sub INNER JOIN t_group_sub gs
                ON gs.id_group = sub.id_group INNER JOIN t_gsubmember gsm
                ON gsm.id_group = gs.id_group INNER JOIN t_pl_map plmap
                ON plmap.id_po = sub.id_po INNER JOIN t_recur rc
                ON rc.id_prop = plmap.id_pi_instance INNER JOIN t_payment_redirection
                pay
                ON pay.id_payee = gsm.id_acc AND pay.vt_end >= sub.vt_start
                AND pay.vt_start <= sub.vt_end INNER JOIN t_acc_usage_cycle
                auc
                ON auc.id_acc = pay.id_payer INNER JOIN t_usage_cycle payercycle
                ON payercycle.id_usage_cycle = auc.id_usage_cycle
                    WHERE rc.tx_cycle_mode = 'EBCR'
                     AND rc.b_charge_per_participant = 'Y'
                     AND sub.id_sub = WARNONEBCRMEMBERSTARTDATECHANG.id_sub_
                     AND gsm.id_acc = WARNONEBCRMEMBERSTARTDATECHANG.id_acc_
                     AND plmap.id_paramtable IS NULL
                     AND payercycle.id_cycle_type = 1
                     AND rc.id_cycle_type  IN (7, 8)  );
            StoO_rowcnt := SQL%ROWCOUNT;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    StoO_rowcnt := 0;
                    StoO_selcnt := 0;
                WHEN OTHERS THEN
                    StoO_rowcnt := 0;
                    StoO_selcnt := 0;
                    raise_application_error(SQLCODE, SQLERRM,true);
            END;
            IF StoO_selcnt != 0 THEN

    /* checks all payer's who overlap with the group sub */
    /* the subscriber is Monthly */
    /* and the EBCR cycle type is either Quarterly or Annually */
    /* warn the user! */
                RETURN 1;

            END IF;
    /* don't warn */
            RETURN 0;
        END;
    END WARNONEBCRMEMBERSTARTDATECHANG;

    FUNCTION WARNONEBCRSTARTDATECHANGE(
    id_sub 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER
    AS
    id_sub_ 	NUMBER(10,0) := id_sub;
    StoO_selcnt	INTEGER;
    StoO_rowcnt	INTEGER:=0;
    isGroup 	NUMBER(10,0);
    /* subscription ID */
    /* 1 if a warning should be raised, 0 otherwise */
    BEGIN
        BEGIN
            FOR rec IN ( SELECT  CASE
            WHEN id_group IS NULL THEN 0
            ELSE 1
            END tmpAlias1
                                     FROM t_sub
                                        WHERE id_sub = WARNONEBCRSTARTDATECHANGE.id_sub_)
            LOOP
               isGroup := rec.tmpAlias1 ;
               StoO_rowcnt := nvl(StoO_rowcnt,0)+1;
            END LOOP;
            IF  StoO_rowcnt = 0 THEN
    /* checks to see if the subscription is associated with an EBCR RC */
    /* and that the EBCR cycle type and the subscriber's billing cycle */
    /* are such that the start date would be used in derivations */
                RETURN -1;
            END IF;
            
            BEGIN
            StoO_selcnt := 0;
            StoO_rowcnt := 0;
            SELECT 1 INTO StoO_selcnt
            FROM DUAL
            WHERE  WARNONEBCRSTARTDATECHANGE.isGroup = 0 AND   EXISTS (
                        SELECT  *
                             FROM t_sub sub INNER JOIN t_pl_map plmap
                        ON plmap.id_po = sub.id_po INNER JOIN t_recur rc
                        ON rc.id_prop = plmap.id_pi_instance INNER JOIN t_acc_usage_cycle
                auc
                        ON auc.id_acc = sub.id_acc INNER JOIN t_usage_cycle payeecycle
                        ON payeecycle.id_usage_cycle = auc.id_usage_cycle
                            WHERE rc.tx_cycle_mode = 'EBCR'
                             AND rc.b_charge_per_participant = 'N'
                             AND sub.id_sub = WARNONEBCRSTARTDATECHANGE.id_sub_
                             AND plmap.id_paramtable IS NULL
                             AND payeecycle.id_cycle_type = 1
                             AND rc.id_cycle_type  IN (7, 8) 		 );
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    StoO_rowcnt := 0;
                    StoO_selcnt := 0;
                WHEN OTHERS THEN
                    StoO_rowcnt := 0;
                    StoO_selcnt := 0;
                    raise_application_error(SQLCODE, SQLERRM,true);
            END;
            IF StoO_selcnt != 0 THEN
    /* the subscriber is Monthly */
    /* and the EBCR cycle type is either Quarterly or Annually */
    /* warn the user! */
    /* checks to see if the group sub is associated with an EBCR RC */
    /* and that the EBCR cycle type and the receiver's payer's billing cycle */
    /* are such that the start date would be used in derivations */
                RETURN 1;
            ELSE
                BEGIN
                BEGIN
                StoO_selcnt := 0;
                StoO_rowcnt := 0;
                SELECT 1 INTO StoO_selcnt
                FROM DUAL
                WHERE  WARNONEBCRSTARTDATECHANGE.isGroup = 1 AND   EXISTS (
                            SELECT  NULL
                                     FROM t_sub sub INNER JOIN t_gsub_recur_map gsrm
                                ON gsrm.id_group = sub.id_group INNER JOIN t_pl_map plmap
                                ON plmap.id_po = sub.id_po INNER JOIN t_recur rc
                                ON rc.id_prop = plmap.id_pi_instance INNER JOIN t_payment_redirection
                    pay
                                ON pay.id_payee = gsrm.id_acc AND pay.vt_end >= sub.vt_start
                    AND pay.vt_start <= sub.vt_end INNER JOIN t_acc_usage_cycle
                    auc
                                ON auc.id_acc = pay.id_payer INNER JOIN t_usage_cycle payercycle
                                ON payercycle.id_usage_cycle = auc.id_usage_cycle
                                    WHERE rc.tx_cycle_mode = 'EBCR'
                                     AND rc.b_charge_per_participant = 'N'
                                     AND sub.id_sub = WARNONEBCRSTARTDATECHANGE.id_sub_
                                     AND plmap.id_paramtable IS NULL
                                     AND payercycle.id_cycle_type = 1
                                     AND rc.id_cycle_type  IN (7, 8) 			 );
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        StoO_rowcnt := 0;
                        StoO_selcnt := 0;
                    WHEN OTHERS THEN
                        StoO_rowcnt := 0;
                        StoO_selcnt := 0;
                        raise_application_error(SQLCODE, SQLERRM,true);
                END;
                IF StoO_selcnt != 0 THEN
    /* checks all payer's who overlap with the group sub */
    /* the subscriber is Monthly */
    /* and the EBCR cycle type is either Quarterly or Annually */
    /* warn the user! */
                    RETURN 1;
                END IF;
                END;
            END IF;
    /* don't warn */
            RETURN 0;
        END;
    END WARNONEBCRSTARTDATECHANGE;

FUNCTION GetCompatibleConcurrentEvents
RETURN retCompatibleEvent_table
AS
v_result  retCompatibleEvent_table;
BEGIN

SELECT retCompatibleEvent(tx_compatible_eventname)
BULK COLLECT INTO v_result
FROM
(
     /* All internal events */
    select distinct evt.tx_name tx_compatible_eventname from t_recevent evt
    where evt.tx_type = 'Root'
    union
    ( /* All unique event names when there are no running adapters (no conflicts) */
    select distinct evt.tx_name  tx_compatible_eventname from t_recevent evt
    where evt.tx_type not in ('Checkpoint','Root')
        /* Intentionally not checking against active events to make sure we don't
        skip any older events that do not have rules or have been deactivated but still have instances */
        and ((select COUNT(*) from t_recevent_run evt_run2 WHERE tx_status = 'InProgress') = 0)
    )
    union
    (
      /* List of events compatible with currently running events */
	    select tx_compatible_eventname
	    from (
		      SELECT
				    evt2.tx_name
		      FROM t_recevent_run evt_run
		      INNER JOIN t_recevent_inst evt_inst2 ON evt_inst2.id_instance = evt_run.id_instance
		      INNER JOIN t_recevent evt2 ON evt2.id_event = evt_inst2.id_event
		      WHERE evt_run.tx_status = 'InProgress'
		      GROUP BY evt2.tx_name, evt2.id_event
	    ) r inner join t_recevent_concurrent c on r.tx_name = c.tx_eventname
	    group by tx_compatible_eventname
	    having COUNT(*) = (select COUNT(*)
					       from (select id_run
							     from t_recevent_run evt_run
							     where evt_run.tx_status = 'InProgress'
							     group by id_run) d
					      )
    )
);


RETURN v_result;
END GetCompatibleConcurrentEvents;

          FUNCTION GetEventExecutionDeps(
            p_dt_now date,
            p_id_instances VARCHAR2
            )
          RETURN int
          is
            deps int;
          BEGIN
          
            /* builds up a table from the comma separated list of instance IDs
                if the list is null, then add all ReadyToRun instances
              */

            IF (p_id_instances IS NOT NULL) then
              INSERT INTO tmp_args
              SELECT column_value FROM table(dbo.csvtoint(p_id_instances));
            else
              INSERT INTO tmp_args
              SELECT id_instance FROM t_recevent_inst
              WHERE tx_status = 'ReadyToRun';
            END if;
          
            /* inserts all active 'ReadyToRun' instances or the instance ID's passed in
              */
          
            INSERT INTO tmp_instances
            SELECT
              evt.id_event,
              evt.tx_type,
              evt.tx_name,
              inst.id_instance,
              inst.id_arg_interval,
              inst.id_arg_billgroup,
              inst.id_arg_root_billgroup,
              /* in the case of EOP then, use the interval's start date */
              CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_start ELSE intervals.dt_start END,
              /* in the case of EOP then, use the interval's end date */
              CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_end ELSE intervals.dt_end END
            FROM t_recevent_inst inst
            INNER JOIN tmp_args args ON args.id_instance = inst.id_instance
            INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
            LEFT OUTER JOIN t_pc_interval intervals ON intervals.id_interval = inst.id_arg_interval
            WHERE /* vent is active */
                  evt.dt_activated <= p_dt_now
              AND (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated);
          
            /* inserts EOP to EOP dependencies for interval-only adapters
              */
            INSERT INTO tmp_deps
            SELECT
              inst.id_event,
              origevent.tx_billgroup_support,
              inst.id_instance,
              inst.id_arg_billgroup,
              inst.tx_name,
              depevt.tx_name,
              depevt.id_event,
              depevt.tx_billgroup_support,
              depinst.id_instance,
              depinst.id_arg_billgroup,
              depinst.id_arg_interval,
              NULL,
              NULL,
              CASE WHEN inst.id_instance = depinst.id_instance
                THEN /* treats the identity dependency as successful */
                    'Succeeded'
                ELSE depinst.tx_status END,
              'Y' /* b_critical_dependency */
            FROM tmp_instances inst
            INNER JOIN t_recevent_dep dep
                ON dep.id_event = inst.id_event
            INNER JOIN t_recevent depevt
                ON depevt.id_event = dep.id_dependent_on_event
            INNER JOIN t_recevent_inst depinst
                ON depinst.id_event = depevt.id_event
                AND depinst.id_arg_interval = inst.id_arg_interval
            INNER JOIN t_recevent origevent
                ON origevent.id_event = inst.id_event
            WHERE /* dep event is active */
                  depevt.dt_activated <= p_dt_now
              AND (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated)
              AND /* the original instance's event is root, EOP or a checkpoint event */
                  inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint')
              AND /* the dependency instance's event is an EOP or Checkpoint event */
                  depevt.tx_type IN ('EndOfPeriod', 'Checkpoint')
             AND /* the original instance's event is 'Interval' */
                origevent.tx_billgroup_support = 'Interval';
          
             /* Inserts EOP to EOP dependencies for billing group-only and account-only adapters. 
                For a given adapter instance, the depends-on instance could
                be and interval-only instance, a billing-group-only instance or an account-only instance.
              */
            
            INSERT INTO tmp_deps
            SELECT
              inst.id_event,
              origevent.tx_billgroup_support,
              inst.id_instance,
              inst.id_arg_billgroup,
              inst.tx_name,
              depevt.tx_name,
              depevt.id_event,
              depevt.tx_billgroup_support,
              depinst.id_instance,
              depinst.id_arg_billgroup,
              depinst.id_arg_interval,
              NULL,
              NULL,
              CASE WHEN inst.id_instance = depinst.id_instance THEN
                /* treats the identity dependency as successful */
                'Succeeded'
              ELSE depinst.tx_status END,
              'Y'  /* b_critical_dependency */
            FROM tmp_instances inst
             INNER JOIN t_recevent origEvt
                ON origEvt.id_event = inst.id_event
            INNER JOIN t_recevent_dep dep
                ON dep.id_event = inst.id_event
            INNER JOIN t_recevent depevt
                ON depevt.id_event = dep.id_dependent_on_event
            INNER JOIN t_recevent_inst depinst
                ON depinst.id_event = depevt.id_event AND
                    (
                           /* when the original event or dependent event is Interval then make sure
                              that the original instance and the dependent instance have the same interval
                            */
                         (
                             (
                                 origEvt.tx_billgroup_support = 'Interval' OR
                                 depEvt.tx_billgroup_support = 'Interval'
                             )
                             AND
                             (
                                 depinst.id_arg_interval = inst.id_arg_interval
                             )
                         )
                         OR
                         /* when the original event is BillingGroup */
                         (
                             (
                                origEvt.tx_billgroup_support = 'BillingGroup'
                             )
                             AND
                             (
                                 /* and dependent event is either BillingGroup or Account then make sure
                                    that the original instance and the dependent instance have the same root billgroup
                                    (depevt.tx_billgroup_support IN ('BillingGroup', 'Account') AND
                                    */
                                    depinst.id_arg_root_billgroup = inst.id_arg_root_billgroup
                             )
                         )
                          /* when the original event is Account */
                         OR
                         (
                             (
                                 origEvt.tx_billgroup_support = 'Account'
                             )
                             AND
                             (
                                (
                                      /* and dependent event is Account then make sure
                                        that the original instance and the dependent instance have the same billgroup 
                                      */
                                      depevt.tx_billgroup_support = 'Account' AND
                                      depinst.id_arg_billgroup = inst.id_arg_billgroup
                                )
                             
                                OR
                                     /* and dependent event is BillingGroup then make sure
                                        that the original instance and the dependent instance 
                                        have the same root billgroup 
                                      */
                                (
                                    depevt.tx_billgroup_support = 'BillingGroup' AND
                                    depinst.id_arg_root_billgroup = inst.id_arg_root_billgroup
                                )
                             )  /* closes that AND dangling up there */
                         ) /*  closes that OR dangling up there - no not that OR, the other OR */
                )
            INNER JOIN t_recevent origevent
                ON origevent.id_event = inst.id_event
            WHERE
              /* dep event is active */
              depevt.dt_activated <= p_dt_now AND
              (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
              /* the original instance's event is root, EOP or a checkpoint event */
              inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
              /* the dependency instance's event is an EOP or Checkpoint event */
              depevt.tx_type IN ('EndOfPeriod', 'Checkpoint')  AND
              /* the original instance's event is 'BillingGroup' */
              origevent.tx_billgroup_support IN ('BillingGroup', 'Account');
               
          /* 
            It is possible for adapters instances which belong to pull lists to have dependencies 
            on 'BillingGroup' type adapters which exist at the parent billing group level and not at the pull list level.
            If the parent billing group is 'Open' then these BillingGroup adapter instances don't even exist in t_recvent_inst.
          
            Hence, create dummy BillingGroup type adapter instances (in a tmp table) for the parent billing groups (if necessary)
            Use the tmp table to generate dependencies specifically for BillingGroup type adapters.
          */
          
            /* select those parent billing groups which don't have any entries in t_recevent_inst */
            INSERT INTO tmp_billgroup(id_billgroup)
            SELECT id_arg_root_billgroup
            FROM t_recevent_inst ri1
            WHERE NOT EXISTS (SELECT 1
                              FROM t_recevent_inst ri2
                              WHERE ri1.id_arg_root_billgroup = ri2.id_arg_billgroup)
                  AND id_arg_root_billgroup IS NOT NULL
            GROUP BY id_arg_root_billgroup;
            
            /* create fake instance rows only for 'BillingGroup' type adapters */
            INSERT INTO  tmp_recevent_inst (
              id_event,
              id_arg_interval,
              id_arg_billgroup,
              id_arg_root_billgroup)
            SELECT evt.id_event id_event,
               bg.id_usage_interval id_arg_interval,
               tbg.id_billgroup,
               tbg.id_billgroup
            FROM tmp_billgroup tbg
              INNER JOIN t_billgroup bg ON bg.id_billgroup = tbg.id_billgroup
              INNER JOIN t_usage_interval ui ON ui.id_interval = bg.id_usage_interval
              INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle
              INNER JOIN t_recevent_eop sch ON
                           /* the schedule is not constrained in any way */
                           ((sch.id_cycle_type IS NULL AND sch.id_cycle IS NULL) OR
                           /* the schedule's cycle type is constrained */
                           (sch.id_cycle_type = uc.id_cycle_type) OR
                           /* the schedule's cycle is constrained */
                           (sch.id_cycle = uc.id_usage_cycle))
                INNER JOIN t_recevent evt ON evt.id_event = sch.id_event
            WHERE
                  /* event must be active */
                  evt.dt_activated <= p_dt_now AND
                  (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated) AND
                  /* event must be of type: end-of-period */
                  (evt.tx_type in ('EndOfPeriod')) AND
                  evt.tx_billgroup_support = 'BillingGroup';
            
             INSERT INTO tmp_deps
              SELECT
                inst.id_event,
                origevent.tx_billgroup_support,
                inst.id_instance,
                inst.id_arg_billgroup,
                inst.tx_name,
                depevt.tx_name,
                depevt.id_event,
                depevt.tx_billgroup_support,
                -1,
                depinst.id_arg_billgroup,
                depinst.id_arg_interval,
                NULL,
                NULL,
                'NotCreated',
                'Y'  /* b_critical_dependency */
              FROM tmp_instances inst
               INNER JOIN t_recevent origEvt
                  ON origEvt.id_event = inst.id_event
              INNER JOIN t_recevent_dep dep
                  ON dep.id_event = inst.id_event
              INNER JOIN t_recevent depevt
                  ON depevt.id_event = dep.id_dependent_on_event
              INNER JOIN tmp_recevent_inst depinst
                  ON depinst.id_event = depevt.id_event AND
                         /* when the original event is Account */
                         origEvt.tx_billgroup_support = 'Account' AND
                         /* and dependent event is BillingGroup then make sure
                            that the original instance and the dependent instance have the same root billgroup 
                            */
                         depevt.tx_billgroup_support = 'BillingGroup' AND
                         depinst.id_arg_root_billgroup = inst.id_arg_root_billgroup
              INNER JOIN t_recevent origevent
                  ON origevent.id_event = inst.id_event
              WHERE
                /* dep event is active */
                depevt.dt_activated <= p_dt_now AND
                (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                /* the original instance's event is EOP event */
                inst.tx_type IN ('EndOfPeriod') AND
                /* the dependency instance's event is an EOP event */
                depevt.tx_type IN ('EndOfPeriod')  AND
                /* the original instance's event is 'Account' */
                origevent.tx_billgroup_support IN ('Account');
            
            /* SELECT * FROM deps  */
            
            /* inserts EOP cross-interval dependencies */
          
              INSERT INTO tmp_deps
              SELECT
                inst.id_event,
                NULL, /* original tx_billgroup_support */
                inst.id_instance,
                inst.id_arg_billgroup,
                inst.tx_name,
                depevt.tx_name,
                depevt.id_event,
                NULL, /* tx_billgroup_support */
                depinst.id_instance,
                depinst.id_arg_billgroup,
                ui.id_interval,
                NULL,
                NULL,
                nvl(depinst.tx_status, 'Missing'),
                'N'  /* b_critical_dependency */
              FROM tmp_instances inst
              INNER JOIN t_usage_interval ui ON ui.dt_end < inst.dt_arg_end
              CROSS JOIN
              (
                /* returns the event dependencies of the end root event
                  this event depends on all EOP events */
                SELECT
                  depevt.id_event,
                  depevt.tx_name
                FROM t_recevent evt
                INNER JOIN t_recevent_dep dep ON dep.id_event = evt.id_event
                INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_dependent_on_event
                WHERE
                  evt.tx_name = '_EndRoot' AND
                  /* end root event is active */
                  evt.dt_activated <= p_dt_now AND
                  (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated) AND
                  /* dep event is active */
                  depevt.dt_activated <= p_dt_now AND
                  (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                  /* the dependency instance's event is an EOP or Checkpoint event */
                  depevt.tx_type IN ('EndOfPeriod', 'Checkpoint')
              ) depevt
              LEFT OUTER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND
                depinst.id_arg_interval = ui.id_interval
              WHERE
                /* the original instance's event is root, EOP or a checkpoint event */
                inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
                /* don't consider hard closed intervals */
                ui.tx_interval_status <> 'H';
            
              /* inserts scheduled dependencies (including complete missing instances)
                */
              INSERT INTO tmp_deps
              SELECT
                inst.id_event,
                NULL, /* original tx_billgroup_support */
                inst.id_instance,
                NULL, /* id_arg_billgroup */
                inst.tx_name,
                depevt.tx_name,
                depevt.id_event,
                depevt.tx_billgroup_support,
                depinst.id_instance,
                NULL, /* id_arg_billgroup */
                NULL, /* id_arg_interval */
                nvl(depinst.dt_arg_start, inst.dt_arg_start),
                nvl(depinst.dt_arg_end, inst.dt_arg_end),
                CASE WHEN inst.id_instance = depinst.id_instance THEN
                  /* treats the identity dependency as successful */
                  'Succeeded'
                ELSE
                  nvl(depinst.tx_status, 'Missing')
                END,
                 'N'  /* b_critical_dependency */
              FROM tmp_instances inst
              INNER JOIN t_recevent_dep dep ON dep.id_event = inst.id_event
              INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_dependent_on_event
              LEFT OUTER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND
                /* enforce that the instance's dependency's start arg and end arg
                   at least partially overlap with the original instance's start and end arguments
                  */
                depinst.dt_arg_start <= inst.dt_arg_end AND
                depinst.dt_arg_end >= inst.dt_arg_start
              WHERE
                /* dep event is active */
                depevt.dt_activated <= p_dt_now AND
                (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                depevt.tx_type = 'Scheduled';
            
            /* SELECT * FROM deps ORDER BY tx_orig_name ASC */
            
             /* inserts partially missing scheduled dependency instances (start to min)
                covers the original instance's start date to the minimum start date
                of all scheduled instances of an event
                */
          
              INSERT INTO tmp_deps
              SELECT
                inst.id_event,
                NULL, /* original tx_billgroup_support */
                inst.id_instance,
                NULL, /* id_arg_billgroup */
                inst.tx_name,
                missingdeps.tx_name,
                missingdeps.id_event,
                NULL, /* tx_billgroup_support */
                NULL, /* id_instance  */
                NULL, /* id_arg_billgroup */
                NULL, /* id_arg_interval */
                inst.dt_arg_start,
                dbo.SubtractSecond(missingdeps.dt_min_arg_start),
                'Missing', /* tx_status,  */
                 'N'  /* b_critical_dependency  */
              FROM tmp_instances inst
              INNER JOIN
              (
                /* gets the minimum arg start date per scheduled event */
                SELECT
                  deps.id_orig_instance,
                  deps.id_event,
                  deps.tx_name,
                  MIN(deps.dt_arg_start) dt_min_arg_start
                FROM tmp_deps deps
                INNER JOIN t_recevent evt ON evt.id_event = deps.id_event
                WHERE
                  evt.tx_type = 'Scheduled' AND
                  deps.tx_status <> 'Missing'
                GROUP BY
                  deps.id_orig_instance,
                  deps.id_event,
                  deps.tx_name
              ) missingdeps ON missingdeps.id_orig_instance = inst.id_instance
              WHERE
                /*  only adds a missing instance if the minimum start date is too late */
                missingdeps.dt_min_arg_start > inst.dt_arg_start ;
            
            
            /* SELECT * FROM deps ORDER BY tx_orig_name ASC */
            
              /* inserts partially missing scheduled dependency instances (max to end)
                covers the maximum end date of all scheduled instances of an event to the
                original instance's end date
                */
              INSERT INTO tmp_deps
              SELECT
                inst.id_event,
                NULL, /* original tx_billgroup_support */
                inst.id_instance,
                NULL, /* id_arg_billgroup */
                inst.tx_name,
                missingdeps.tx_name,
                missingdeps.id_event,
                NULL, /* tx_billgroup_support */
                NULL, /* id_instance, */
                NULL, /* id_arg_billgroup */
                NULL, /* id_arg_interval */
                dbo.AddSecond(missingdeps.dt_max_arg_end),
                inst.dt_arg_end,
                'Missing', /* tx_status, */
                 'N'  /* b_critical_dependency */
              FROM tmp_instances inst
              INNER JOIN
              (
                /* gets the maximum arg end date per scheduled event */
                SELECT
                  deps.id_orig_instance,
                  deps.id_event,
                  deps.tx_name,
                  MAX(deps.dt_arg_end) dt_max_arg_end
                FROM tmp_deps deps
                INNER JOIN t_recevent evt ON evt.id_event = deps.id_event
                WHERE
                  evt.tx_type = 'Scheduled' AND
                  deps.tx_status <> 'Missing'
                GROUP BY
                  deps.id_orig_instance,
                  deps.id_event,
                  deps.tx_name
              ) missingdeps ON missingdeps.id_orig_instance = inst.id_instance
              WHERE
                /* only adds a missing instance if the maximum end date is too early */
                missingdeps.dt_max_arg_end < inst.dt_arg_end;
            
              /* SELECT * FROM deps ORDER BY tx_orig_name ASC */
          
/*
select deps_rec(
            id_orig_event,
            tx_orig_billgroup_support,
            id_orig_instance,
            id_orig_billgroup,
            tx_orig_name,
            tx_name,
            id_event,
            tx_billgroup_support,
            id_instance,
            id_billgroup,
            id_arg_interval,
            dt_arg_start,
            dt_arg_end,
            tx_status,
            b_critical_dependency)
          BULK COLLECT INTO deps from tmp_deps;
*/

		 SELECT COUNT(*) INTO deps FROM tmp_deps;

		  RETURN deps;
          
          END GetEventExecutionDeps;

          function geteventreversaldeps(
            p_dt_now date,
            p_id_instances varchar2)
          return int as
            deps int;
          begin
          
            /* builds up a table from the comma separated list of instance IDs */
            /* if the list is null, then add all ReadyToReverse instances */
          
            if p_id_instances is not null then
              insert into tmp_args
              select column_value from table(dbo.csvtoint(p_id_instances));
            else
              insert into tmp_args
              select id_instance from t_recevent_inst
              where tx_status = 'ReadyToReverse';
            end if;
          
            /* inserts all active instances found in @args
              */
            INSERT INTO tmp_instances
            SELECT
              evt.id_event,
              evt.tx_type,
              evt.tx_name,
              inst.id_instance,
              inst.id_arg_interval,
              inst.id_arg_billgroup,
              inst.id_arg_root_billgroup,
              /* in the case of EOP then, use the interval's start date */
              CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_start ELSE intervals.dt_start END,
              /* in the case of EOP then, use the interval's end date */
              CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_end ELSE intervals.dt_end END
            FROM t_recevent_inst inst
            INNER JOIN tmp_args args ON args.id_instance = inst.id_instance
            INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
            LEFT OUTER JOIN t_pc_interval intervals ON intervals.id_interval = inst.id_arg_interval
            WHERE /* event is active */
                  evt.dt_activated <= p_dt_now
              AND (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated);
          
            /* inserts EOP to EOP dependencies for interval-only adapters
              */
          INSERT INTO tmp_deps
          SELECT
                  inst.id_event,
                  origevent.tx_billgroup_support,
                  inst.id_instance,
                  inst.id_arg_billgroup,
                  inst.tx_name,
                  depevt.tx_name,
                  depevt.id_event,
                  depevt.tx_billgroup_support,
                  depinst.id_instance,
                  depinst.id_arg_billgroup,
                  depinst.id_arg_interval,
                  NULL,
                  NULL,
                  CASE WHEN inst.id_instance = depinst.id_instance THEN
                         /* treats the identity dependency as NotYetRun */
                          'NotYetRun'
                  ELSE
                          depinst.tx_status
                  END,
                   'Y'   /* b_critical_dependency */
          FROM tmp_instances inst
          INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_event
          INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_event
          INNER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event
            AND depinst.id_arg_interval = inst.id_arg_interval
          INNER JOIN t_recevent origevent ON origevent.id_event = inst.id_event
          WHERE
                  /* dep event is active */
                  depevt.dt_activated <= p_dt_now AND
                  (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                  /* the original instance's event is root, EOP or a checkpoint event */
                  inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
                  /* the dependency instance's event is an EOP or Checkpoint event */
                  depevt.tx_type IN ('EndOfPeriod', 'Checkpoint') AND
                  /* the original instance's event is 'Interval' */
                  origevent.tx_billgroup_support = 'Interval';
          
            /* SELECT * FROM @deps ORDER BY tx_orig_name ASC */
           /* 
              Inserts EOP to EOP dependencies for billing group-only and account-only adapters. 
              For a given adapter instance, the depends-on instance could
              be and interval-only instance, a billing-group-only instance or an account-only instance.
            */
          
            INSERT INTO tmp_deps
            SELECT
                inst.id_event,
                origevent.tx_billgroup_support,
                inst.id_instance,
                inst.id_arg_billgroup,
                inst.tx_name,
                depevt.tx_name,
                depevt.id_event,
                depevt.tx_billgroup_support,
                depinst.id_instance,
                depinst.id_arg_billgroup,
                depinst.id_arg_interval,
                NULL,
                NULL,
                CASE WHEN inst.id_instance = depinst.id_instance THEN
                        /* treats the identity dependency as NotYetRun */
                        'NotYetRun'
                ELSE
                        depinst.tx_status
                END,
                 'Y'  /* b_critical_dependency */
            FROM tmp_instances inst
            INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_event
            INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_event
            INNER JOIN t_recevent_inst depinst
              ON depinst.id_event = depevt.id_event
              AND (
                     /* if the depends-on instance is an interval-only instance */
                     (depinst.id_arg_interval = inst.id_arg_interval AND depevt.tx_billgroup_support = 'Interval')
                     OR
                     /* if the depends-on instance is an account-only instance */
                    (depinst.id_arg_billgroup = inst.id_arg_billgroup AND depevt.tx_billgroup_support = 'Account')
                     OR
                    /* if the depends-on instance is a billing-group-only instance */
                    (depinst.id_arg_root_billgroup = inst.id_arg_root_billgroup AND depevt.tx_billgroup_support = 'BillingGroup')
                  )
            
            INNER JOIN t_recevent origevent ON origevent.id_event = inst.id_event
            WHERE
                    /* dep event is active */
                    depevt.dt_activated <= p_dt_now AND
                    (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                    /* the original instance's event is root, EOP or a checkpoint event */
                    inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
                    /* the dependency instance's event is an EOP or Checkpoint event */
                    depevt.tx_type IN ('EndOfPeriod', 'Checkpoint') AND
                    /* the original instance's event is 'BillingGroup' */
                    origevent.tx_billgroup_support IN ('BillingGroup', 'Account');
          
            /* inserts EOP cross-interval dependencies (every instance in future intervals)
              */
            INSERT INTO tmp_deps
            SELECT
                    inst.id_event,
                    NULL, /* original tx_billgroup_support */
                    inst.id_instance,
                    inst.id_arg_billgroup,
                    inst.tx_name,
                    depevt.tx_name,
                    depevt.id_event,
                    NULL, /* tx_billgroup_support */
                    depinst.id_instance,
                    depinst.id_arg_billgroup,
                    ui.id_interval,
                    NULL,
                    NULL,
                    depinst.tx_status,
                    'N' /* b_critical_dependency */
            FROM tmp_instances inst
            INNER JOIN t_usage_interval ui ON ui.dt_end > inst.dt_arg_end
            CROSS JOIN (
                    /* returns the event dependencies of the end root event
                       this event depends on all EOP events */
                    SELECT
                            depevt.id_event,
                            depevt.tx_name
                    FROM t_recevent evt
                    INNER JOIN t_recevent_dep dep ON dep.id_event = evt.id_event
                    INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_dependent_on_event
                    WHERE
                            evt.tx_name = '_EndRoot' AND
                            /* end root event is active */
                            evt.dt_activated <= p_dt_now AND
                            (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated) AND
                            /*  dep event is active */
                            depevt.dt_activated <= p_dt_now AND
                            (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                            /* the dependency instance's event is an EOP or Checkpoint event */
                            depevt.tx_type IN ('EndOfPeriod', 'Checkpoint')
            ) depevt
            INNER JOIN t_recevent_inst depinst
              ON depinst.id_event = depevt.id_event
              AND depinst.id_arg_interval = ui.id_interval
            WHERE /* the original instance's event is root, EOP or a checkpoint event */
                  inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint');
          
          
            /* inserts scheduled dependencies
            */
          
            insert INTO tmp_deps
            SELECT
                  inst.id_event,
                  NULL, /* original tx_billgroup_support */
                  inst.id_instance,
                  NULL, /* id_arg_billgroup */
                  inst.tx_name,
                  depevt.tx_name,
                  depevt.id_event,
                  depevt.tx_billgroup_support,
                  depinst.id_instance,
                  NULL, /* id_arg_billgroup */
                  NULL, /* id_arg_interval */
                  nvl(depinst.dt_arg_start, inst.dt_arg_start),
                  nvl(depinst.dt_arg_end, inst.dt_arg_end),
                  CASE WHEN inst.id_instance = depinst.id_instance THEN
                          /* treats the identity dependency as NotYetRun */
                          'NotYetRun'
                  ELSE
                          depinst.tx_status
                  END,
                  'N'  /*  b_critical_dependency */
            FROM tmp_instances inst
            INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_event
            INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_event
            INNER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND
                    /* enforce that the instance's dependency's start arg and end arg
                      at least partially overlap with the original instance's start and end arguments */
                    depinst.dt_arg_start <= inst.dt_arg_end AND
                    depinst.dt_arg_end >= inst.dt_arg_start
            WHERE
                    /* dep event is active */
                    depevt.dt_activated <= p_dt_now AND
                    (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                    depevt.tx_type = 'Scheduled';
          
            /* SELECT * FROM @deps ORDER BY tx_orig_name ASC */
/*
				select deps_rec(
                id_orig_event,
                tx_orig_billgroup_support,
                id_orig_instance,
                id_orig_billgroup,
                tx_orig_name,
                tx_name,
                id_event,
                tx_billgroup_support,
                id_instance,
                id_billgroup,
                id_arg_interval,
                dt_arg_start,
                dt_arg_end,
                tx_status,
                b_critical_dependency)
              BULK COLLECT INTO deps from tmp_deps;
*/

			SELECT COUNT(*) INTO deps FROM tmp_deps;

            return deps;
          
          end geteventreversaldeps;

function to_base( p_dec in number, p_base in number )
return varchar2
is
	l_str	varchar2(255) default NULL;
	l_num	number	default p_dec;
	l_hex	varchar2(16) default '0123456789ABCDEF';
begin
	if ( trunc(p_dec) <> p_dec OR p_dec < 0 ) then
		raise PROGRAM_ERROR;
	end if;
	loop
		l_str := substr( l_hex, mod(l_num,p_base)+1, 1 ) || l_str;
		l_num := trunc( l_num/p_base );
		exit when ( l_num = 0 );
	end loop;
	if (p_base = 2) then
		l_str := lpad(l_str,64,'0');
	end if;
	return l_str;
end to_base;

function twos_complement( in_bin_string varchar2)
return varchar2
is
bin_str char(64) := lpad(trim(in_bin_string),64,0);
str_length pls_integer := length(bin_str);
i pls_integer := 0;
begin
	/* find two's complement */
	dbms_output.put_line('init = ' || bin_str);
	/* reverse all bits */
	bin_str := replace(bin_str,'0','2');
	bin_str := replace(bin_str,'1','0');
	bin_str := replace(bin_str,'2','1');
	/*done, now add 1 to lsb */
	dbms_output.put_line( 'reverse = ' || bin_str);
	
	for i in reverse 0..64
	loop
  	    /* dbms_output.put_line( 'pos = ' || to_char(i) || 'value is ' || trim(substr(bin_str,i,1))); */
		if to_number(trim(substr(bin_str,i,1))) = 0 then
		   		   
			bin_str := substr(bin_str,1,i-1) || '1' || substr(bin_str,i+1);
			exit when true;
		else
			bin_str := substr(bin_str,1,i-1) || '0' || substr(bin_str,i+1);
		end if;
	end loop;

	dbms_output.put_line( 'final = ' || bin_str);
	return bin_str;
end twos_complement;

function to_dec( p_str in varchar2,  p_from_base in number default 16 ) return number
is
	l_num   number default 0;
	l_hex   varchar2(16) default '0123456789ABCDEF';
begin
	for i in 1 .. length(p_str) loop
		l_num := l_num * p_from_base + instr(l_hex,upper(substr(p_str,i,1)))-1;
	end loop;
	return l_num;
end to_dec;



FUNCTION MTHEXFORMAT(  value  IN NUMBER  DEFAULT NULL)
RETURN VARCHAR2  AS
ret_str varchar2(16);
bin_str varchar2(64);
BEGIN
	if (value < 0 ) then
		bin_str := dbo.twos_complement(dbo.to_base(abs(value),2));
	else
		bin_str := dbo.to_base(abs(value),2);
	end if;
	/* data is required to convert to 4 bytes , how ever can be expanded upto 8 bytes */
	ret_str := lower(lpad(dbo.to_base(dbo.to_dec(substr(bin_str,33,16),2),16),4,'0') || lpad(dbo.to_base(dbo.to_dec(substr(bin_str,49,16),2),16),4,0));
	dbms_output.put_line(ret_str);
	return ret_str;
end mthexformat;

function GetBillingGroupAncestor(
  p_id_current_billgroup int)
return int
as
  parent_bg int := null;
  cur_bg int := p_id_current_billgroup;
begin

  loop
  
    select id_parent_billgroup into parent_bg
    from t_billgroup
    where id_billgroup = cur_bg;
  
    if (parent_bg is null) then
      exit;
    end if;

    cur_bg := parent_bg;

  end loop;
  
  return cur_bg;

end GetBillingGroupAncestor;

function GetBillingGroupDescendants(p_id_billgroup_current int)
return billgroupdesc_results_tab
as
  results billgroupdesc_results_tab;
begin

  select billgroupdesc_results_rec(id_billgroup)
  bulk collect into results
  from t_billgroup
  where id_parent_billgroup is not null
  start with id_billgroup = p_id_billgroup_current
  connect by prior id_billgroup = id_parent_billgroup
  ;

  return results;

end GetBillingGroupDescendants;

function getexpiredintervals(
  p_dt_now date,
  p_not_materialized int
  ) return id_table
  
as
  retIntervals id_table;

begin

  SELECT id_rec(ui.id_interval)
  bulk collect into retIntervals
  FROM t_usage_interval ui
  INNER JOIN t_usage_cycle uc
     ON uc.id_usage_cycle = ui.id_usage_cycle
  INNER JOIN t_usage_cycle_type uct
     ON uct.id_cycle_type = uc.id_cycle_type
  WHERE
    /* if the not_materialized flag is '1' 
       then
          return only those intervals which have not been materialized
       else 
          the materialization status of the interval does not matter
    */
    CASE WHEN p_not_materialized = 1
             THEN (SELECT COUNT(id_materialization)
                        FROM t_billgroup_materialization
                        WHERE id_usage_interval = ui.id_interval)
             ELSE 0
             END = 0
    AND
    CASE WHEN uct.n_grace_period IS NOT NULL
      THEN ui.dt_end + uct.n_grace_period /* take into account the cycle type's grace period */
      ELSE p_dt_now /* the grace period has been disabled, so don't close this interval */
      END < p_dt_now;

    RETURN retIntervals;

end getexpiredintervals;

			function GetAllDescendentAccountTypes(
				parent varchar2
				) return retDescendents_table
as
retDescendents_tmp retDescendents_table;
begin
SELECT retDescendents(t_account_type.name) bulk collect into retDescendents_tmp
from t_account_type
where id_type in
(
select distinct id_descendent_type from t_acctype_descendenttype_map
start with id_type = (select id_type from t_account_type where upper(name) = upper(parent))
connect by nocycle prior id_descendent_type = id_type
);
    RETURN retDescendents_tmp;

end GetAllDescendentAccountTypes;

    function IsSystemPartitioned
      return int
    as
    begin
    
      for x in (select b_partitioning_enabled
                from t_usage_server
                where upper(b_partitioning_enabled) = 'Y'
                ) loop
        return 1;
      end loop;
      
      return 0;
    
    end IsSystemPartitioned;


    function GetUsageIntervalID (
      p_dt_end timestamp,
      p_id_cycle int)
    return int
    as
    begin
      
      return extract(day from
              p_dt_end - to_timestamp('1970-01-01', 'yyyy-mm-dd'))
          * power(2,16) + p_id_cycle;

    end GetUsageIntervalID;

    function DaysFromPartitionEpoch(
      dt timestamp)
    return int as
    begin
      return extract(day from dt - to_timestamp('1970-01-01', 'yyyy-mm-dd'));
    end DaysFromPartitionEpoch;

   function maxpartitionbound
   return number as
   begin
    return 9999999999;
   end;

  FUNCTION GenGuid
  RETURN RAW AS
    v_uid RAW(16);
  BEGIN
    v_uid := sys_guid();
    RETURN v_uid;
  END;

END;
/

CREATE OR REPLACE FORCE VIEW vw_audit_log ("TIME",username,userid,eventid,eventname,entityname,entityid,entitytype,details,loggedinas,applicationname,id_audit,id_event,id_userid,id_entitytype,id_entity,tx_logged_in_as,tx_application_name,dt_crt) AS
SELECT
       audit1.dt_crt AS Time,
          accmap1.nm_login
       || CASE accmap1.nm_login WHEN NULL THEN NULL ELSE '/' END
       || accmap1.nm_space
          AS username,
       audit1.id_userid userid,
       audit1.id_Event eventid,
       d.tx_desc EventName,
       (CASE audit1.id_entitytype
           WHEN 1
           THEN accmap2.nm_login
           WHEN 2
           THEN bp2.nm_name
           WHEN 3
           THEN gs2.tx_name
           WHEN 5
           THEN ft2.tx_FailureCompoundId_encoded
           WHEN 6
           THEN b2.tx_namespace || '\' || b2.tx_name || '\' || b2.tx_sequence
           WHEN 9
           THEN accmap2.nm_login
           ELSE
              NULL
        END)
          EntityName,
       audit1.id_entity EntityId,
       audit1.id_entitytype EntityType,
       auditdetail.tx_details Details,
       audit1.tx_logged_in_as LoggedInAs,
       audit1.tx_application_name ApplicationName,
       audit1."ID_AUDIT",
       audit1."ID_EVENT",
       audit1."ID_USERID",
       audit1."ID_ENTITYTYPE",
       audit1."ID_ENTITY",
       audit1."TX_LOGGED_IN_AS",
       audit1."TX_APPLICATION_NAME",
       audit1."DT_CRT"
  FROM t_audit audit1
       INNER JOIN t_audit_events auditevent
          ON audit1.id_event = auditevent.id_event
       INNER JOIN t_description d
          ON auditevent.id_desc = d.id_desc AND d.id_lang_code = 840
       INNER JOIN t_account_mapper accmap1 ON audit1.id_userid = accmap1.id_acc
       -- CORE-5043 add filtering account aliases
       INNER JOIN t_namespace ns1 ON accmap1.nm_space  = ns1.nm_space
              AND ns1.tx_typ_space != 'metered'
              AND ns1.tx_typ_space != 'system_ar'
       LEFT OUTER JOIN t_audit_details auditdetail
         ON audit1.id_audit = auditdetail.id_audit
       /* Handle different entity types below */
       LEFT OUTER JOIN t_account_mapper accmap2
         ON audit1.id_entitytype IN (1, 9)
        AND audit1.id_entity = accmap2.id_acc
        -- CORE-5043 add filtering account aliases
       INNER JOIN t_namespace ns2 ON accmap2.nm_space  = ns2.nm_space
              AND ns2.tx_typ_space != 'metered'
              AND ns2.tx_typ_space != 'system_ar'
       LEFT OUTER JOIN t_base_props bp2
         ON audit1.id_entitytype = 2
        AND audit1.id_entity = bp2.id_prop
       LEFT OUTER JOIN t_group_sub gs2
         ON audit1.id_entitytype = 3
        AND audit1.id_entity = gs2.id_group
       LEFT OUTER JOIN t_failed_transaction ft2
         ON audit1.id_entitytype = 5
        AND audit1.id_entity = ft2.id_failed_transaction
       LEFT OUTER JOIN t_batch b2
         ON audit1.id_entitytype = 6
        AND audit1.id_entity = b2.id_batch;

CREATE OR REPLACE FORCE VIEW vw_adjustment_details (id_sess,tx_uid,id_acc,id_payee,id_view,id_usage_interval,id_parent_sess,id_prod,id_svc,dt_session,amount,am_currency,dt_crt,tx_batch,tax_federal,tax_state,tax_county,tax_local,tax_other,id_pi_instance,id_pi_template,id_se,compoundprebilladjamt,compoundprebilladjedamt,atomicprebilladjamt,atomicprebilladjedamt,pendingprebilladjamt,compoundprebillfedtaxadjamt,compoundprebillstatetaxadjamt,compoundprebillcntytaxadjamt,compoundprebilllocaltaxadjamt,compoundprebillothertaxadjamt,compoundprebilltotaltaxadjamt,atomicprebillfedtaxadjamt,atomicprebillstatetaxadjamt,atomicprebillcntytaxadjamt,atomicprebilllocaltaxadjamt,atomicprebillothertaxadjamt,atomicprebilltotaltaxadjamt,compoundpostbilladjamt,compoundpostbilladjedamt,atomicpostbilladjamt,atomicpostbilladjedamt,pendingpostbilladjamt,compoundpostbillfedtaxadjamt,compoundpostbillstatetaxadjamt,compoundpostbillcntytaxadjamt,compoundpostbilllocaltaxadjamt,compoundpostbillothertaxadjamt,compoundpostbilltotaltaxadjamt,atomicpostbillfedtaxadjamt,atomicpostbillstatetaxadjamt,atomicpostbillcntytaxadjamt,atomicpostbilllocaltaxadjamt,atomicpostbillothertaxadjamt,atomicpostbilltotaltaxadjamt,prebilladjustmentid,postbilladjustmentid,prebilladjustmenttemplateid,postbilladjustmenttemplateid,prebilladjustmentinstanceid,postbilladjustmentinstanceid,prebilladjustmentreasoncodeid,postbilladjustmentreasoncodeid,prebilladjustmentdescription,postbilladjustmentdescription,prebilladjdefaultdesc,postbilladjdefaultdesc,adjustmentstatus,isadjusted,isprebilladjusted,ispostbilladjusted,isprebill,canadjust,canrebill,canmanageprebilladjustment,canmanagepostbilladjustment,canmanageadjustments,isintervalsoftclosed,numprebilladjustedchildren,numpostbilladjustedchildren,id_adj_trx,id_reason_code,id_acc_creator,id_acc_payer,c_status,adjustmentcreationdate,dt_modified,id_aj_type,id_aj_template,id_aj_instance,adjustmentusageinterval,tx_desc,tx_default_desc,n_adjustmenttype,adjustmenttemplatedisplayname,adjustmentinstancedisplayname,reasoncodename,reasoncodedescription,reasoncodedisplayname,languagecode,prebilladjamt,postbilladjamt) AS
select distinct
          ajinfo.ID_SESS, ajinfo.TX_UID, ajinfo.ID_ACC, ajinfo.ID_PAYEE, ajinfo.ID_VIEW,
          ajinfo.ID_USAGE_INTERVAL, ajinfo.ID_PARENT_SESS, ajinfo.ID_PROD,
          ajinfo.ID_SVC, ajinfo.DT_SESSION, ajinfo.AMOUNT, ajinfo.AM_CURRENCY,
          ajinfo.DT_CRT, ajinfo.TX_BATCH, ajinfo.TAX_FEDERAL, ajinfo.TAX_STATE,
          ajinfo.TAX_COUNTY, ajinfo.TAX_LOCAL, ajinfo.TAX_OTHER, ajinfo.ID_PI_INSTANCE,
          ajinfo.ID_PI_TEMPLATE, ajinfo.ID_SE, ajinfo.COMPOUNDPREBILLAdjAmt,
          ajinfo.CompoundPrebillAdjedAmt, ajinfo.AtomicPrebillAdjAmt, ajinfo.AtomicPrebillAdjedAmt,
          ajinfo.PENDINGPREBILLAdjAmt, ajinfo.COMPOUNDPREBILLFedTaxAdjAmt,
          ajinfo.COMPOUNDPREBILLSTATETAXADJAMT, ajinfo.COMPOUNDPREbillCntyTAXADJAMT,
          ajinfo.COMPOUNDPREBILLLOCALTAXADJAMT, ajinfo.COMPOUNDPREBILLOTHERTAXADJAMT,
          ajinfo.COMPOUNDPREBILLTOTALTAXADJAMT, ajinfo.AtomicPrebillFedTaxAdjAmt,
          ajinfo.ATOMICPREBILLSTATETAXADJAMT, ajinfo.ATOMICPREbillCntyTAXADJAMT,
          ajinfo.ATOMICPREBILLLOCALTAXADJAMT, ajinfo.ATOMICPREBILLOTHERTAXADJAMT,
          ajinfo.ATOMICPREBILLTOTALTAXADJAMT, ajinfo.COMPOUNDPOSTBILLAdjAmt, ajinfo.CompoundPostbillAdjedAmt,
          ajinfo.AtomicPostbillAdjAmt, ajinfo.AtomicPostbillAdjedAmt, ajinfo.PENDINGPOSTBILLAdjAmt,
          ajinfo.COMPOUNDPOSTBILLFedTaxAdjAmt, ajinfo.COMPOUNDPOSTBILLSTATETAXADJAMT,
          ajinfo.CompoundPostbillCntyTaxAdjAmt, ajinfo.COMPOUNDPOSTBILLLOCALTAXADJAMT,
          ajinfo.COMPOUNDPOSTBILLOTHERTAXADJAMT, ajinfo.COMPOUNDPOSTBILLTOTALTAXADJAMT,
          ajinfo.ATOMICPOSTBILLFedTaxAdjAmt, ajinfo.ATOMICPOSTBILLSTATETAXADJAMT,
          ajinfo.ATOMICPOSTbillCntyTAXADJAMT, ajinfo.ATOMICPOSTBILLLOCALTAXADJAMT,
          ajinfo.ATOMICPOSTBILLOTHERTAXADJAMT, ajinfo.ATOMICPOSTBILLTOTALTAXADJAMT,
          ajinfo.PREBILLADJUSTMENTID, ajinfo.POSTBILLADJUSTMENTID, ajinfo.PREBILLADJUSTMENTTEMPLATEID,
          ajinfo.POSTBILLADJUSTMENTTEMPLATEID, ajinfo.PREBILLADJUSTMENTINSTANCEID,
          ajinfo.POSTBILLADJUSTMENTINSTANCEID, ajinfo.PREBILLADJUSTMENTREASONCODEID,
          ajinfo.POSTBILLADJUSTMENTREASONCODEID, ajinfo.PREBILLADJUSTMENTDESCRIPTION,
          ajinfo.POSTBILLADJUSTMENTDESCRIPTION, ajinfo.PREBILLADJDEFAULTDESC,
          ajinfo.POSTBILLADJDEFAULTDESC, ajinfo.ADJUSTMENTSTATUS, ajinfo.ISADJUSTED,
          ajinfo.ISPREBILLADJUSTED, ajinfo.ISPOSTBILLADJUSTED, ajinfo.ISPREBILL, ajinfo.CANADJUST,
          ajinfo.CANREBILL, ajinfo.CANMANAGEPREBILLADJUSTMENT, ajinfo.CANMANAGEPOSTBILLADJUSTMENT,
          ajinfo.CANMANAGEADJUSTMENTS, ajinfo.ISINTERVALSOFTCLOSED, ajinfo.NUMPREBILLADJUSTEDCHILDREN,
          ajinfo.NUMPOSTBILLADJUSTEDCHILDREN,
          ajt.id_adj_trx,
          ajt.id_reason_code,
          ajt.id_acc_creator,
          ajt.id_acc_payer,
          ajt.c_status,
          ajt.dt_crt AS AdjustmentCreationDate,
          ajt.dt_modified,
          ajt.id_aj_type,
          ajt.id_aj_template AS id_aj_template,
          ajt.id_aj_instance AS id_aj_instance,
          ajt.id_usage_interval AS AdjustmentUsageInterval,
          ajt.tx_desc,
          ajt.tx_default_desc,
          ajt.n_adjustmenttype,
          nvl(ajtemplatedesc.tx_desc,'') as AdjustmentTemplateDisplayName,
          nvl(ajinstancedesc.tx_desc,'') as AdjustmentInstanceDisplayName,
          CASE WHEN (rcbp.nm_name IS NULL) THEN translate('' using nchar_cs) ELSE rcbp.nm_name END  AS ReasonCodeName,
          CASE WHEN (rcbp.nm_desc IS NULL) THEN translate('' using nchar_cs) ELSE rcbp.nm_desc END  AS ReasonCodeDescription,
          CASE WHEN (rcdesc.tx_desc IS NULL) THEN translate('' using nchar_cs) ELSE rcdesc.tx_desc END  AS ReasonCodeDisplayName,
          nvl(ajinstancedesc.id_lang_code,ajtemplatedesc.id_lang_code) as LanguageCode,
          ajinfo.AtomicPrebillAdjAmt AS PrebillAdjAmt,
          ajinfo.AtomicPostbillAdjAmt AS PostbillAdjAmt
          FROM t_adjustment_transaction ajt
          INNER JOIN VW_AJ_INFO ajinfo ON ajt.id_sess = ajinfo.id_sess
                  /*resolve adjustment template or instance name                      */
          INNER JOIN t_base_props ajtemplatebp ON ajt.id_aj_template = ajtemplatebp.id_prop
          left outer JOIN t_description  ajtemplatedesc ON ajtemplatebp.n_display_name = ajtemplatedesc.id_desc
          left outer JOIN t_base_props ajinstancebp ON ajt.id_aj_instance = ajinstancebp.id_prop
          LEFT OUTER JOIN t_description  ajinstancedesc ON ajinstancebp.n_display_name = ajinstancedesc.id_desc
          left outer join t_description des2 on des2.id_lang_code = ajtemplatedesc.id_lang_code and des2.id_desc =  ajinstancebp.n_display_name
          left outer join t_description des3 on des3.id_lang_code = ajinstancedesc.id_lang_code and des3.id_desc =  ajtemplatebp.n_display_name
                  /*resolve adjustment reason code name                  */
          INNER JOIN t_base_props rcbp ON ajt.id_reason_code = rcbp.id_prop
          INNER JOIN t_description  rcdesc ON rcbp.n_display_name = rcdesc.id_desc
					and
					rcdesc.id_lang_code = nvl(ajinstancedesc.id_lang_code,ajtemplatedesc.id_lang_code)
          WHERE ajt.c_status = 'A'
          and
          ( ajtemplatedesc.id_lang_code=ajinstancedesc.id_lang_code
          or des2.id_lang_code is null
          or des3.id_lang_code is null
          );

CREATE OR REPLACE FORCE VIEW t_vw_base_props (id_lang_code,id_prop,n_kind,n_name,n_desc,nm_name,nm_desc,b_approved,b_archive,n_display_name,nm_display_name) AS
select
  td_dispname.id_lang_code as id_lang_code, bp.id_prop, bp.n_kind, bp.n_name, bp.n_desc,
  bp.nm_name as nm_name, td_desc.tx_desc as nm_desc, bp.b_approved, bp.b_archive,
  bp.n_display_name, td_dispname.tx_desc as nm_display_name
from t_base_props bp
  left join t_description td_dispname on td_dispname.id_desc = bp.n_display_name
  left join t_description td_desc on td_desc.id_desc = bp.n_desc and td_desc.id_lang_code = td_dispname.id_lang_code;

CREATE FORCE VIEW t_vw_adm_exchange_rates (vt_start,vt_end,nm_country_source,nm_country_target,id_country_source,id_country_target,c_exchange_rate) AS
select xmap."VT_START",xmap."VT_END",xmap."NM_COUNTRY_SOURCE",xmap."NM_COUNTRY_TARGET",xmap."ID_COUNTRY_SOURCE",xmap."ID_COUNTRY_TARGET",
  case
    when nm_country_source = 'AED' then CAST( 0.2722580000 as number(22,10))
    when nm_country_source = 'AFN' then CAST( 0.0177990000 as number(22,10))
    when nm_country_source = 'ALL' then CAST( 0.0097245500 as number(22,10))
    when nm_country_source = 'AMD' then CAST( 0.0024235400 as number(22,10))
    when nm_country_source = 'ANG' then CAST( 0.5586590000 as number(22,10))
    when nm_country_source = 'AOA' then CAST( 0.0102397000 as number(22,10))
    when nm_country_source = 'ARS' then CAST( 0.1238390000 as number(22,10))
    when nm_country_source = 'AUD' then CAST( 0.9223690000 as number(22,10))
    when nm_country_source = 'AWG' then CAST( 0.5586590000 as number(22,10))
    when nm_country_source = 'AZN' then CAST( 1.2748600000 as number(22,10))
    when nm_country_source = 'BAM' then CAST( 0.6950060000 as number(22,10))
    when nm_country_source = 'BBD' then CAST( 0.5000000000 as number(22,10))
    when nm_country_source = 'BDT' then CAST( 0.0129121000 as number(22,10))
    when nm_country_source = 'BGN' then CAST( 0.6950030000 as number(22,10))
    when nm_country_source = 'BHD' then CAST( 2.6521800000 as number(22,10))
    when nm_country_source = 'BIF' then CAST( 0.0006460000 as number(22,10))
    when nm_country_source = 'BMD' then CAST( 1.0000000000 as number(22,10))
    when nm_country_source = 'BND' then CAST( 0.7963100000 as number(22,10))
    when nm_country_source = 'BOB' then CAST( 0.1447180000 as number(22,10))
    when nm_country_source = 'BRL' then CAST( 0.4469190000 as number(22,10))
    when nm_country_source = 'BSD' then CAST( 1.0000000000 as number(22,10))
    when nm_country_source = 'BTN' then CAST( 0.0169592000 as number(22,10))
    when nm_country_source = 'BWP' then CAST( 0.1151990000 as number(22,10))
    when nm_country_source = 'BYR' then CAST( 0.0000991818 as number(22,10))
    when nm_country_source = 'BZD' then CAST( 0.5007580000 as number(22,10))
    when nm_country_source = 'CAD' then CAST( 0.9188030000 as number(22,10))
    when nm_country_source = 'CDF' then CAST( 0.0010938700 as number(22,10))
    when nm_country_source = 'CHF' then CAST( 1.1132400000 as number(22,10))
    when nm_country_source = 'CLP' then CAST( 0.0018138600 as number(22,10))
    when nm_country_source = 'CNY' then CAST( 0.1598730000 as number(22,10))
    when nm_country_source = 'COP' then CAST( 0.0005232900 as number(22,10))
    when nm_country_source = 'CRC' then CAST( 0.0018096300 as number(22,10))
    when nm_country_source = 'CUC' then CAST( 1.0000000000 as number(22,10))
    when nm_country_source = 'CUP' then CAST( 0.0377358000 as number(22,10))
    when nm_country_source = 'CVE' then CAST( 0.0126459000 as number(22,10))
    when nm_country_source = 'CZK' then CAST( 0.0494407000 as number(22,10))
    when nm_country_source = 'DJF' then CAST( 0.0055679700 as number(22,10))
    when nm_country_source = 'DKK' then CAST( 0.1821460000 as number(22,10))
    when nm_country_source = 'DOP' then CAST( 0.0231321000 as number(22,10))
    when nm_country_source = 'DZD' then CAST( 0.0126130000 as number(22,10))
    when nm_country_source = 'EGP' then CAST( 0.1396880000 as number(22,10))
    when nm_country_source = 'ERN' then CAST( 0.0955110000 as number(22,10))
    when nm_country_source = 'ETB' then CAST( 0.0511195000 as number(22,10))
    when nm_country_source = 'EUR' then CAST( 1.3595000000 as number(22,10))
    when nm_country_source = 'FJD' then CAST( 0.5477090000 as number(22,10))
    when nm_country_source = 'FKP' then CAST( 1.6713700000 as number(22,10))
    when nm_country_source = 'GBP' then CAST( 1.6713600000 as number(22,10))
    when nm_country_source = 'GEL' then CAST( 0.5650250000 as number(22,10))
    when nm_country_source = 'GGP' then CAST( 1.6713400000 as number(22,10))
    when nm_country_source = 'GHS' then CAST( 0.3352900000 as number(22,10))
    when nm_country_source = 'GIP' then CAST( 1.6713000000 as number(22,10))
    when nm_country_source = 'GMD' then CAST( 0.0252247000 as number(22,10))
    when nm_country_source = 'GNF' then CAST( 0.0001426310 as number(22,10))
    when nm_country_source = 'GTQ' then CAST( 0.1288410000 as number(22,10))
    when nm_country_source = 'GYD' then CAST( 0.0047973100 as number(22,10))
    when nm_country_source = 'HKD' then CAST( 0.1289740000 as number(22,10))
    when nm_country_source = 'HNL' then CAST( 0.0523560000 as number(22,10))
    when nm_country_source = 'HRK' then CAST( 0.1790270000 as number(22,10))
    when nm_country_source = 'HTG' then CAST( 0.0220996000 as number(22,10))
    when nm_country_source = 'HUF' then CAST( 0.0044728700 as number(22,10))
    when nm_country_source = 'IDR' then CAST( 0.0000859485 as number(22,10))
    when nm_country_source = 'ILS' then CAST( 0.2871490000 as number(22,10))
    when nm_country_source = 'IMP' then CAST( 1.6712900000 as number(22,10))
    when nm_country_source = 'INR' then CAST( 0.0169685000 as number(22,10))
    when nm_country_source = 'IQD' then CAST( 0.0008591100 as number(22,10))
    when nm_country_source = 'IRR' then CAST( 0.0000390700 as number(22,10))
    when nm_country_source = 'ISK' then CAST( 0.0088613300 as number(22,10))
    when nm_country_source = 'JEP' then CAST( 0.5983360000 as number(22,10))
    when nm_country_source = 'JMD' then CAST( 0.0090132500 as number(22,10))
    when nm_country_source = 'JOD' then CAST( 1.4120300000 as number(22,10))
    when nm_country_source = 'JPY' then CAST( 0.0098198000 as number(22,10))
    when nm_country_source = 'KES' then CAST( 0.0113766000 as number(22,10))
    when nm_country_source = 'KGS' then CAST( 0.0190549000 as number(22,10))
    when nm_country_source = 'KHR' then CAST( 0.0002474640 as number(22,10))
    when nm_country_source = 'KMF' then CAST( 0.0027628900 as number(22,10))
    when nm_country_source = 'KPW' then CAST( 0.0075692500 as number(22,10))
    when nm_country_source = 'KRW' then CAST( 0.0009794580 as number(22,10))
    when nm_country_source = 'KWD' then CAST( 3.5467600000 as number(22,10))
    when nm_country_source = 'KYD' then CAST( 1.2195100000 as number(22,10))
    when nm_country_source = 'KZT' then CAST( 0.0054429200 as number(22,10))
    when nm_country_source = 'LAK' then CAST( 0.0001240770 as number(22,10))
    when nm_country_source = 'LBP' then CAST( 0.0006607200 as number(22,10))
    when nm_country_source = 'LKR' then CAST( 0.0076687100 as number(22,10))
    when nm_country_source = 'LRD' then CAST( 0.0118343000 as number(22,10))
    when nm_country_source = 'LSL' then CAST( 0.0955714000 as number(22,10))
    when nm_country_source = 'LTL' then CAST( 0.3936730000 as number(22,10))
    when nm_country_source = 'LVL' then CAST( 1.9340800000 as number(22,10))
    when nm_country_source = 'LYD' then CAST( 0.8193360000 as number(22,10))
    when nm_country_source = 'MAD' then CAST( 0.1211340000 as number(22,10))
    when nm_country_source = 'MDL' then CAST( 0.0742115000 as number(22,10))
    when nm_country_source = 'MGA' then CAST( 0.0004291850 as number(22,10))
    when nm_country_source = 'MKD' then CAST( 0.0220556000 as number(22,10))
    when nm_country_source = 'MMK' then CAST( 0.0010330600 as number(22,10))
    when nm_country_source = 'MNT' then CAST( 0.0005529440 as number(22,10))
    when nm_country_source = 'MOP' then CAST( 0.1252120000 as number(22,10))
    when nm_country_source = 'MRO' then CAST( 0.0034188000 as number(22,10))
    when nm_country_source = 'MUR' then CAST( 0.0327118000 as number(22,10))
    when nm_country_source = 'MVR' then CAST( 0.0651466000 as number(22,10))
    when nm_country_source = 'MWK' then CAST( 0.0025310000 as number(22,10))
    when nm_country_source = 'MXN' then CAST( 0.0777022000 as number(22,10))
    when nm_country_source = 'MYR' then CAST( 0.3099050000 as number(22,10))
    when nm_country_source = 'MZN' then CAST( 0.0317460000 as number(22,10))
    when nm_country_source = 'NAD' then CAST( 0.0955762000 as number(22,10))
    when nm_country_source = 'NGN' then CAST( 0.0061406200 as number(22,10))
    when nm_country_source = 'NIO' then CAST( 0.0389029000 as number(22,10))
    when nm_country_source = 'NOK' then CAST( 0.1674840000 as number(22,10))
    when nm_country_source = 'NPR' then CAST( 0.0104083000 as number(22,10))
    when nm_country_source = 'NZD' then CAST( 0.8496230000 as number(22,10))
    when nm_country_source = 'OMR' then CAST( 2.5980800000 as number(22,10))
    when nm_country_source = 'PAB' then CAST( 1.0000000000 as number(22,10))
    when nm_country_source = 'PEN' then CAST( 0.3607520000 as number(22,10))
    when nm_country_source = 'PGK' then CAST( 0.3649640000 as number(22,10))
    when nm_country_source = 'PHP' then CAST( 0.0227809000 as number(22,10))
    when nm_country_source = 'PKR' then CAST( 0.0101258000 as number(22,10))
    when nm_country_source = 'PLN' then CAST( 0.3272110000 as number(22,10))
    when nm_country_source = 'PYG' then CAST( 0.0002254500 as number(22,10))
    when nm_country_source = 'QAR' then CAST( 0.2746800000 as number(22,10))
    when nm_country_source = 'RON' then CAST( 0.3093640000 as number(22,10))
    when nm_country_source = 'RSD' then CAST( 0.0117650000 as number(22,10))
    when nm_country_source = 'RUB' then CAST( 0.0289187000 as number(22,10))
    when nm_country_source = 'RWF' then CAST( 0.0014728100 as number(22,10))
    when nm_country_source = 'SAR' then CAST( 0.2665390000 as number(22,10))
    when nm_country_source = 'SBD' then CAST( 0.1371000000 as number(22,10))
    when nm_country_source = 'SCR' then CAST( 0.0819793000 as number(22,10))
    when nm_country_source = 'SDG' then CAST( 0.1756700000 as number(22,10))
    when nm_country_source = 'SEK' then CAST( 0.1505360000 as number(22,10))
    when nm_country_source = 'SGD' then CAST( 0.7962000000 as number(22,10))
    when nm_country_source = 'SHP' then CAST( 1.6712500000 as number(22,10))
    when nm_country_source = 'SLL' then CAST( 0.0002299930 as number(22,10))
    when nm_country_source = 'SOS' then CAST( 0.0008340400 as number(22,10))
    when nm_country_source = 'SRD' then CAST( 0.3053450000 as number(22,10))
    when nm_country_source = 'STD' then CAST( 0.0000555001 as number(22,10))
    when nm_country_source = 'SYP' then CAST( 0.0067091700 as number(22,10))
    when nm_country_source = 'SZL' then CAST( 0.0955923000 as number(22,10))
    when nm_country_source = 'THB' then CAST( 0.0305951000 as number(22,10))
    when nm_country_source = 'TJS' then CAST( 0.2037620000 as number(22,10))
    when nm_country_source = 'TMT' then CAST( 0.3508770000 as number(22,10))
    when nm_country_source = 'TND' then CAST( 0.6128200000 as number(22,10))
    when nm_country_source = 'TOP' then CAST( 0.5392000000 as number(22,10))
    when nm_country_source = 'TRY' then CAST( 0.4760410000 as number(22,10))
    when nm_country_source = 'TTD' then CAST( 0.1549330000 as number(22,10))
    when nm_country_source = 'TWD' then CAST( 0.0332036000 as number(22,10))
    when nm_country_source = 'TZS' then CAST( 0.0006018700 as number(22,10))
    when nm_country_source = 'UAH' then CAST( 0.0853628000 as number(22,10))
    when nm_country_source = 'UGX' then CAST( 0.0003932400 as number(22,10))
    when nm_country_source = 'USD' then CAST( 1.0000000000 as number(22,10))
    when nm_country_source = 'UYU' then CAST( 0.0433841000 as number(22,10))
    when nm_country_source = 'UZS' then CAST( 0.0004354600 as number(22,10))
    when nm_country_source = 'VEF' then CAST( 0.1590410000 as number(22,10))
    when nm_country_source = 'VND' then CAST( 0.0000472925 as number(22,10))
    when nm_country_source = 'VUV' then CAST( 0.0105485000 as number(22,10))
    when nm_country_source = 'WST' then CAST( 0.4410000000 as number(22,10))
    when nm_country_source = 'XAF' then CAST( 0.0020725400 as number(22,10))
    when nm_country_source = 'XAG' then CAST( 19.0235000000 as number(22,10))
    when nm_country_source = 'XAU' then CAST( 1258.3900000000 as number(22,10))
    when nm_country_source = 'XCD' then CAST( 0.3703700000 as number(22,10))
    when nm_country_source = 'XDR' then CAST( 1.5392900000 as number(22,10))
    when nm_country_source = 'XOF' then CAST( 0.0020725700 as number(22,10))
    when nm_country_source = 'XPD' then CAST( 836.7890000000 as number(22,10))
    when nm_country_source = 'XPF' then CAST( 0.0113929000 as number(22,10))
    when nm_country_source = 'XPT' then CAST( 1453.6000000000 as number(22,10))
    when nm_country_source = 'YER' then CAST( 0.0046553900 as number(22,10))
    when nm_country_source = 'ZAR' then CAST( 0.0955487000 as number(22,10))
    when nm_country_source = 'ZMK' then CAST( 0.0001418440 as number(22,10))
    when nm_country_source = 'CYP' then CAST( 2.3225400000 as number(22,10))
    when nm_country_source = 'DEM' then CAST( 0.6950170000 as number(22,10))
    when nm_country_source = 'EEK' then CAST( 0.0868872000 as number(22,10))
    when nm_country_source = 'ESP' then CAST( 0.0081707700 as number(22,10))
    when nm_country_source = 'FRF' then CAST( 0.2072550000 as number(22,10))
    when nm_country_source = 'IEP' then CAST( 1.7262700000 as number(22,10))
    when nm_country_source = 'MGF' then CAST( 0.0000858369 as number(22,10))
    when nm_country_source = 'MTL' then CAST( 3.1663200000 as number(22,10))
    when nm_country_source = 'ROL' then CAST( 0.0000309277 as number(22,10))
    when nm_country_source = 'SDD' then CAST( 0.0017567000 as number(22,10))
    when nm_country_source = 'SKK' then CAST( 0.0451157000 as number(22,10))
    when nm_country_source = 'SPL' then CAST( 6.0000000000 as number(22,10))
    when nm_country_source = 'SVC' then CAST( 0.1142860000 as number(22,10))
    when nm_country_source = 'TMM' then CAST( 0.0000701754 as number(22,10))
    when nm_country_source = 'TRL' then CAST( 0.0000004767 as number(22,10))
    when nm_country_source = 'TVD' then CAST( 0.9236910000 as number(22,10))
    when nm_country_source = 'VEB' then CAST( 0.0001590410 as number(22,10))
    when nm_country_source = 'ZWD' then CAST( 0.0027631900 as number(22,10))
    else                                CAST(     0.000000 as number(22,10))
  end as c_exchange_rate
from
(
select to_date('2000-01-01','YYYY-MM-DD') as vt_start,
       dbo.MTMaxDate() as vt_end,
       substr(eds.nm_enum_data, INSTR(eds.nm_enum_data,'/',-1) + 1)  as nm_country_source,
       substr(edt.nm_enum_data, INSTR(edt.nm_enum_data,'/',-1) + 1)  as nm_country_target,
       eds.id_enum_data as id_country_source,
       edt.id_enum_data as id_country_target
from t_enum_data eds
cross join t_enum_data edt
where UPPER(eds.nm_enum_data) LIKE UPPER('Global/SystemCurrencies/SystemCurrencies/%')
  and UPPER(edt.nm_enum_data) LIKE UPPER('Global/SystemCurrencies/SystemCurrencies/%')
  and UPPER(edt.nm_enum_data) = UPPER('Global/SystemCurrencies/SystemCurrencies/USD')
) xmap;

CREATE FORCE VIEW agg_charge_definition (charge_type_id,charge_qualification_group,productview_name,row_num,include_table_name,source_value,target_field,include_predicate,included_field_prefix,field_name,population_string,mvm_procedure,child_charge_id,"FILTER",default_value) AS
select
 
a.c_Name as charge_type_id,
        
a.c_AmountChain as charge_qualification_group,
        
a.c_ProductViewName as productview_name,
        
b.c_row_num as row_num,
        
b.c_include_table_name as include_table_name,
        
b.c_source_value as source_value,
        
b.c_target_field as target_field,
        
b.c_include_predicate as include_predicate,
        
b.c_included_field_prefix as included_field_prefix,
        
b.c_field_name as field_name,
        
b.c_population_string as population_string,
        
b.c_mvm_procedure as mvm_procedure,
        
b.c_child_charge_name as child_charge_id,
        
b.c_filter as filter,
        
b.c_default_value as default_value
          
from t_amp_generatedcharge a
          
inner join t_amp_genchargedirective b on a.c_GenCharge_Id = b.c_GenCharge_Id;

CREATE OR REPLACE TRIGGER t_char_values_del_upd_trigger
            BEFORE DELETE OR UPDATE ON T_CHAR_VALUES
            FOR EACH ROW
            BEGIN
              if updating THEN
                if :NEW.nm_value <> :OLD.nm_value THEN
                  insert into t_char_values_history
                  (id_scv, id_entity, nm_value, c_start_date, c_end_date, c_spec_name, c_spec_type)
                  values
                  (:OLD.id_scv, :OLD.id_entity, :OLD.nm_value, :OLD.c_start_date, sysdate, :OLD.c_spec_name, :OLD.c_spec_type);
                END IF;
              END IF;
  
              if deleting THEN
                  insert into t_char_values_history
                  (id_scv, id_entity, nm_value, c_start_date, c_end_date, c_spec_name, c_spec_type)
                  values
                  (:OLD.id_scv, :OLD.id_entity, :OLD.nm_value, :OLD.c_start_date, sysdate, :OLD.c_spec_name,:OLD.c_spec_type);
              END IF;
  
            END;
/

CREATE TRIGGER TR_T_PT_TRANSLATIONRATESIDSC AFTER INSERT OR UPDATE ON t_pt_translationrates FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_translationrates table');
    END IF;
        
END;
/

CREATE OR REPLACE TRIGGER trig_recur_window_sub AFTER INSERT OR UPDATE OR DELETE
ON t_sub
REFERENCING NEW AS new old as old
FOR EACH row
DECLARE currentDate DATE;
BEGIN
	IF deleting THEN
	BEGIN
		/* dt_crt is nullable. Use SystemDate as workaround not disable possibility of fail on production */
        SELECT NVL(:old.dt_crt, metratime(1,'RC')) INTO currentDate FROM dual;
        DELETE FROM t_recur_window
           WHERE c__SubscriptionID   = :old.id_sub;
    END;
    ELSE
	/*inserting or deleting*/
		/* dt_crt is nullable. Use SystemDate as workaround not disable possibility of fail on production */
		SELECT NVL(:new.dt_crt, metratime(1,'RC')) INTO currentDate FROM dual;
		
		DELETE FROM TMP_NEWRW where c__SubscriptionID = :new.id_sub;
	
		UPDATE t_recur_window
            SET c_SubscriptionStart = :new.vt_start,
				c_SubscriptionEnd   = :new.vt_end
            WHERE EXISTS
             (	SELECT 1
				FROM t_recur_window trw
					JOIN t_pl_map plm on :new.id_po = plm.id_po
                and plm.id_sub = :new.id_sub and plm.id_paramtable = null
                WHERE
				  c__AccountID      = :new.id_acc
				  AND c__SubscriptionID   = :new.id_sub
          ) ;
          
		UPDATE t_recur_window
			SET 	c_SubscriptionStart = :new.vt_start,
					c_SubscriptionEnd   = :new.vt_end
			WHERE c__AccountID      = :new.id_acc
				AND c__SubscriptionID   = :new.id_sub;
      
      DELETE FROM TMP_NEWRW;
    
      INSERT INTO TMP_NEWRW
      SELECT :new.vt_start c_CycleEffectiveDate,
        :new.vt_start c_CycleEffectiveStart,
        :new.vt_end c_CycleEffectiveEnd,
        :new.vt_start c_SubscriptionStart,
        :new.vt_end c_SubscriptionEnd,
        rcr.b_advance c_Advance ,
        pay.id_payee c__AccountID,
        pay.id_payer c__PayingAccount,
        plm.id_pi_instance c__PriceableItemInstanceID,
        plm.id_pi_template c__PriceableItemTemplateID,
        plm.id_po c__ProductOfferingID,
        pay.vt_start c_PayerStart,
        pay.vt_end c_PayerEnd,
        :new.id_sub c__SubscriptionID,
        NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart,
        NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd,
        rv.n_value c_UnitValue,
        dbo.mtmindate() c_BilledThroughDate,
        -1 c_LastIdRun,
        dbo.mtmindate() c_MembershipStart,
        dbo.mtmaxdate() c_MembershipEnd,
        AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, :new.vt_end, :new.dt_crt) c__IsAllowGenChargeByTrigger
      from t_payment_redirection pay INNER JOIN t_pl_map plm
         ON plm.id_po = :new.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop
        AND :new.id_sub  = rv.id_sub AND rv.tt_end   = dbo.MTMaxDate()
        AND rv.vt_start < :new.vt_end AND rv.vt_end   > :new.vt_start
        AND rv.vt_start < pay.vt_end  AND rv.vt_end   > pay.vt_start
      WHERE
		pay.id_payee  = :new.id_acc
		AND pay.vt_start < :new.vt_end
		AND pay.vt_end   > :new.vt_start
      /*Make sure not to insert a row that already takes care of this account/sub id*/
		AND NOT EXISTS
			(SELECT 1
			FROM T_RECUR_WINDOW
			  WHERE c__AccountID    = :new.id_acc
			  AND c__SubscriptionID = :new.id_sub
			)
		AND :new.id_group IS NULL
		AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);
 	
	/* adds charges to METER tables */
	MeterInitialFromRecurWindow(currentDate);
	MeterCreditFromRecurWindow(currentDate);

	INSERT INTO t_recur_window
    SELECT c_CycleEffectiveDate,
    c_CycleEffectiveStart,
    c_CycleEffectiveEnd,
    c_SubscriptionStart,
    c_SubscriptionEnd,
    c_Advance,
    c__AccountID,
    c__PayingAccount,
    c__PriceableItemInstanceID,
    c__PriceableItemTemplateID,
    c__ProductOfferingID,
    c_PayerStart,
    c_PayerEnd,
    c__SubscriptionID,
    c_UnitValueStart,
    c_UnitValueEnd,
    c_UnitValue,
    c_BilledThroughDate,
    c_LastIdRun,
    c_MembershipStart,
    c_MembershipEnd
    FROM tmp_newrw
	WHERE c__SubscriptionID = :new.id_sub;
	
	END IF;
END;
/

CREATE OR REPLACE TRIGGER trig_recur_window_recur_map
AFTER INSERT OR UPDATE OR DELETE ON t_gsub_recur_map
REFERENCING NEW AS new OLD AS OLD
FOR EACH row
DECLARE
currentDate DATE;
v_id_sub INTEGER;
  BEGIN
    IF deleting THEN
      DELETE FROM t_recur_window WHERE EXISTS
       (SELECT 1
          FROM t_sub sub join t_pl_map plm on sub.id_po = plm.id_po
		  WHERE t_recur_window.c__AccountID = :old.id_acc
            AND t_recur_window.c__SubscriptionID = sub.id_sub
            AND sub.id_group = :old.id_group
			AND t_recur_window.c__PriceableItemInstanceID = plm.id_pi_instance
			AND t_recur_window.c__PriceableItemTemplateID = plm.id_pi_template
       );
    ELSE
	/*inserting or updating*/
		SELECT sub.id_sub INTO v_id_sub
		  FROM t_sub sub
		  WHERE sub.id_group = :new.id_group
			AND ROWNUM = 1;
		
		DELETE FROM TMP_NEWRW WHERE c__SubscriptionID = v_id_sub;
        UPDATE t_recur_window
          SET c_MembershipStart = :new.vt_start,
              c_MembershipEnd     = :new.vt_end
        WHERE EXISTS
         (SELECT 1
			FROM t_recur_window trw JOIN t_sub sub on trw.c__AccountID    = sub.id_acc
				AND trw.c__SubscriptionID = sub.id_sub
            WHERE sub.id_group = :new.id_group
      ) ;
	
	SELECT NVL(:new.tt_start, metratime(1,'RC')) INTO currentDate FROM dual;
	  
    insert into TMP_NEWRW
    SELECT sub.vt_start c_CycleEffectiveDate,
      sub.vt_start c_CycleEffectiveStart,
      sub.vt_end c_CycleEffectiveEnd,
      sub.vt_start c_SubscriptionStart,
      sub.vt_end c_SubscriptionEnd,
      rcr.b_advance c_Advance,
      pay.id_payee c__AccountID,
      pay.id_payer c__PayingAccount,
      plm.id_pi_instance c__PriceableItemInstanceID,
      plm.id_pi_template c__PriceableItemTemplateID,
      plm.id_po c__ProductOfferingID,
      pay.vt_start c_PayerStart,
      pay.vt_end c_PayerEnd,
      sub.id_sub c__SubscriptionID,
      NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart,
      NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd,
      rv.n_value c_UnitValue,
      currentDate c_BilledThroughDate,
      -1 c_LastIdRun,
      :new.vt_start c_MembershipStart,
      :new.vt_end c_MembershipEnd,
	   AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, currentDate) c__IsAllowGenChargeByTrigger
      from t_sub sub INNER JOIN t_payment_redirection pay
         ON pay.id_payee = :new.id_acc AND pay.vt_start < sub.vt_end
          AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po
         AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop
        AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate()
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE
      	sub.id_group = :new.id_group
      	AND NOT EXISTS
	        (SELECT 1
	          FROM T_RECUR_WINDOW
			  WHERE c__AccountID = :new.id_acc
	            AND c__SubscriptionID = sub.id_sub
	        )
	    AND :new.tt_end  = dbo.mtmaxdate()
	    AND rcr.b_charge_per_participant = 'N'
	    AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);
 /* adds charges to METER tables */
  MeterInitialFromRecurWindow(currentDate);
  MeterCreditFromRecurWindow(currentDate);
  
  INSERT INTO t_recur_window
    SELECT c_CycleEffectiveDate,
    c_CycleEffectiveStart,
    c_CycleEffectiveEnd,
    c_SubscriptionStart,
    c_SubscriptionEnd,
    c_Advance,
    c__AccountID,
    c__PayingAccount,
    c__PriceableItemInstanceID,
    c__PriceableItemTemplateID,
    c__ProductOfferingID,
    c_PayerStart,
    c_PayerEnd,
    c__SubscriptionID,
    c_UnitValueStart,
    c_UnitValueEnd,
    c_UnitValue,
    c_BilledThroughDate,
    c_LastIdRun,
    c_MembershipStart,
    c_MembershipEnd
    FROM tmp_newrw
	WHERE c__SubscriptionID = v_id_sub;
  
  UPDATE t_recur_window w1
    SET c_CycleEffectiveEnd =
    (SELECT MIN(NVL(w2.c_CycleEffectiveDate,w2.c_SubscriptionEnd))
      FROM t_recur_window w2
        WHERE w2.c__SubscriptionID  = w1.c__SubscriptionID
        AND w1.c_PayerStart         = w2.c_PayerStart
        AND w1.c_PayerEnd           = w2.c_PayerEnd
        AND w1.c_UnitValueStart     = w2.c_UnitValueStart
        AND w1.c_UnitValueEnd       = w2.c_UnitValueEnd
        AND w2.c_CycleEffectiveDate > w1.c_CycleEffectiveDate
    )
  WHERE 1=1
  AND EXISTS
  (SELECT 1
    FROM t_recur_window w2
      WHERE w2.c__SubscriptionID  = w1.c__SubscriptionID
      AND w1.c_PayerStart         = w2.c_PayerStart
      AND w1.c_PayerEnd           = w2.c_PayerEnd
      AND w1.c_UnitValueStart     = w2.c_UnitValueStart
      AND w1.c_UnitValueEnd       = w2.c_UnitValueEnd
      AND w2.c_CycleEffectiveDate > w1.c_CycleEffectiveDate
  ) ;
	
  END IF;
END;
/

ALTER FUNCTION allowinitialarrerscharge COMPILE ;

CREATE OR REPLACE TRIGGER trig_recur_window_pay_redir
  /* We don't want to trigger on delete, because the insert comes right after a delete, and we can get the info that was deleted
  from payment_redir_history*/
  AFTER
  INSERT ON t_payment_redirection REFERENCING NEW AS NEW
  FOR EACH row
  DECLARE currentDate DATE;
  BEGIN
    /*Get the old vt_start and vt_end for payees that have changed*/
    insert into tmp_redir
    SELECT DISTINCT redirold.id_payer,
      redirold.id_payee,
      redirold.vt_start,
      redirold.vt_end
    FROM t_payment_redir_history redirnew
    JOIN t_payment_redir_history redirold
       ON redirold.tt_end      = dbo.subtractSecond(redirnew.tt_start)
       WHERE redirnew.id_payee = :new.id_payee
         AND redirnew.tt_end     = dbo.MTMaxDate();

   /*Get the old windows for payees that have changed*/
    insert into tmp_oldrw
      SELECT * FROM t_recur_window trw JOIN tmp_redir
        ON trw.c__AccountID  = tmp_redir.id_payee
        AND trw.c_PayerStart = tmp_redir.vt_start
        AND trw.c_PayerEnd   = tmp_redir.vt_end;

SELECT metratime(1,'RC') INTO currentDate FROM dual;

insert into tmp_newrw
  SELECT orw.c_CycleEffectiveDate ,
    orw.c_CycleEffectiveStart ,
    orw.c_CycleEffectiveEnd ,
    orw.c_SubscriptionStart ,
    orw.c_SubscriptionEnd ,
    orw.c_Advance ,
    orw.c__AccountID ,
    :new.id_payer c__PayingAccount ,
    orw.c__PriceableItemInstanceID ,
    orw.c__PriceableItemTemplateID ,
    orw.c__ProductOfferingID ,
    :new.vt_start c_PayerStart ,
    :new.vt_end c_PayerEnd ,
    orw.c__SubscriptionID ,
    orw.c_UnitValueStart ,
    orw.c_UnitValueEnd ,
    orw.c_UnitValue ,
    orw.c_BilledThroughDate ,
    orw.c_LastIdRun ,
    orw.c_MembershipStart ,
    orw.c_MembershipEnd,
    AllowInitialArrersCharge(orw.c_Advance, :new.id_payer, orw.c_SubscriptionEnd, currentDate) c__IsAllowGenChargeByTrigger
  FROM tmp_oldrw orw
  WHERE orw.c__AccountId = :new.id_payee;
  
  MeterPayerChangeFromRecWind(currentDate);
  
  DELETE
  FROM t_recur_window
  WHERE EXISTS
    (SELECT 1
    FROM tmp_newrw orw where
    t_recur_window.c__PayingAccount      = orw.c__PayingAccount
    AND t_recur_window.c__ProductOfferingID = orw.c__ProductOfferingID
    AND t_recur_window.c_PayerStart         = orw.c_PayerStart
    AND t_recur_window.c_PayerEnd           = orw.c_PayerEnd
    AND t_recur_window.c__SubscriptionID    = orw.c__SubscriptionID
    );
  
  INSERT INTO t_recur_window
    SELECT c_CycleEffectiveDate,
    c_CycleEffectiveStart,
    c_CycleEffectiveEnd,
    c_SubscriptionStart,
    c_SubscriptionEnd,
    c_Advance,
    c__AccountID,
    c__PayingAccount,
    c__PriceableItemInstanceID,
    c__PriceableItemTemplateID,
    c__ProductOfferingID,
    c_PayerStart,
    c_PayerEnd,
    c__SubscriptionID,
    c_UnitValueStart,
    c_UnitValueEnd,
    c_UnitValue,
    c_BilledThroughDate,
    c_LastIdRun,
    c_MembershipStart,
    c_MembershipEnd
    FROM tmp_newrw;

  UPDATE t_recur_window w1
  SET c_CycleEffectiveEnd =
    (SELECT MIN(NVL(w2.c_CycleEffectiveDate,w2.c_SubscriptionEnd))
    FROM t_recur_window w2
    WHERE w2.c__SubscriptionID  = w1.c__SubscriptionID
    AND w1.c_PayerStart         = w2.c_PayerStart
    AND w1.c_PayerEnd           = w2.c_PayerEnd
    AND w1.c_UnitValueStart     = w2.c_UnitValueStart
    AND w1.c_UnitValueEnd       = w2.c_UnitValueEnd
    AND w2.c_CycleEffectiveDate > w1.c_CycleEffectiveDate
    )
  WHERE EXISTS
    (SELECT 1
    FROM t_recur_window w2
    WHERE w2.c__SubscriptionID  = w1.c__SubscriptionID
    AND w1.c_PayerStart         = w2.c_PayerStart
    AND w1.c_PayerEnd           = w2.c_PayerEnd
    AND w1.c_UnitValueStart     = w2.c_UnitValueStart
    AND w1.c_UnitValueEnd       = w2.c_UnitValueEnd
    AND w2.c_CycleEffectiveDate > w1.c_CycleEffectiveDate
    ) ;
END;
/

CREATE TRIGGER TRG_TMP_SESSION_SET_B_I
   BEFORE INSERT
   ON TTT_TMP_SESSION_SET
BEGIN
   mt_ttt.g_tx_id := mt_ttt.get_tx_id ();
END;
/

CREATE TRIGGER TRG_TMP_SESSION_SET_A_I
   AFTER INSERT
   ON TTT_TMP_SESSION_SET
BEGIN
   mt_ttt.g_tx_id := NULL;
END;
/

CREATE OR REPLACE TRIGGER TRG_TMP_SESSION_SET
   BEFORE INSERT
   ON TTT_TMP_SESSION_SET
   FOR EACH ROW
BEGIN
   :NEW.tx_id := mt_ttt.g_tx_id;
END;
/

CREATE TRIGGER TRG_TMP_SESSION_B_I
   BEFORE INSERT
   ON TTT_TMP_SESSION
BEGIN
   mt_ttt.g_tx_id := mt_ttt.get_tx_id ();
END;
/

CREATE TRIGGER TRG_TMP_SESSION_A_I
   AFTER INSERT
   ON TTT_TMP_SESSION
BEGIN
   mt_ttt.g_tx_id := NULL;
END;
/

CREATE OR REPLACE TRIGGER TRG_TMP_SESSION
   BEFORE INSERT
   ON TTT_TMP_SESSION
   FOR EACH ROW
BEGIN
   :NEW.tx_id := mt_ttt.g_tx_id;
END;
/

CREATE TRIGGER TRG_TMP_AGGREGATE_B_I
   BEFORE INSERT
   ON TTT_TMP_AGGREGATE
BEGIN
   mt_ttt.g_tx_id := mt_ttt.get_tx_id ();
END;
/

CREATE TRIGGER TRG_TMP_AGGREGATE_A_I
   AFTER INSERT
   ON TTT_TMP_AGGREGATE
BEGIN
   mt_ttt.g_tx_id := NULL;
END;
/

CREATE TRIGGER TRG_TMP_AGGREGATE
   BEFORE INSERT
   ON TTT_TMP_AGGREGATE
   FOR EACH ROW
BEGIN
   :NEW.tx_id := mt_ttt.g_tx_id;
END;
/

CREATE OR REPLACE TRIGGER trg_rec_win_on_t_gsubmember AFTER
  INSERT OR
  DELETE OR
  UPDATE ON t_gsubmember REFERENCING NEW AS new OLD AS OLD
  FOR EACH row
  DECLARE
	currentDate DATE;
	v_id_sub INTEGER;
  BEGIN
  IF deleting THEN
  BEGIN
	  SELECT sub.id_sub INTO v_id_sub
	  FROM t_sub sub
	  where sub.id_group = :old.id_group
		AND ROWNUM = 1;
	  
	  DELETE FROM t_recur_window trw
	  WHERE
			trw.c__subscriptionid = v_id_sub
			AND trw.c__accountid = :old.id_acc;
  END;
ELSE
  /*inserting or updating*/
  SELECT sub.id_sub INTO v_id_sub
  FROM t_sub sub
  WHERE sub.id_group = :new.id_group
	AND ROWNUM = 1;
  
   DELETE FROM tmp_newrw WHERE c__subscriptionid = v_id_sub;
      
   UPDATE t_recur_window trw
      SET trw.c_MembershipStart = :new.vt_start,
          trw.c_MembershipEnd = :new.vt_end
      WHERE exists
      (SELECT 1
         FROM t_sub ts inner join t_pl_map plm on ts.id_po = plm.id_po
            and plm.id_sub = null and plm.id_paramtable = null
   WHERE
              trw.c__accountid       = :new.id_acc
              AND ts.id_group           = :new.id_group
              AND trw.c__subscriptionid = ts.id_sub
           and trw.c__PriceableItemInstanceID = plm.id_pi_instance
              AND trw.c__PriceableItemTemplateID = plm.id_pi_template
      );
	  
	SELECT metratime(1,'RC') INTO currentDate FROM dual;
      
  INSERT INTO tmp_newrw
  SELECT
       :new.vt_start AS c_CycleEffectiveDate
      ,:new.vt_start AS c_CycleEffectiveStart
      ,:new.vt_end AS c_CycleEffectiveEnd
      ,:new.vt_start          AS c_SubscriptionStart
      ,:new.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , nvl(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , nvl(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , metratime(1,'RC') as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd
      , AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, :new.vt_end, currentDate) c__IsAllowGenChargeByTrigger
      FROM t_sub sub
      INNER JOIN t_payment_redirection pay ON pay.id_payee = :new.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start AND pay.vt_start < :new.vt_end AND pay.vt_end > :new.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate() AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start AND rv.vt_start < :new.vt_end AND rv.vt_end > :new.vt_start
      WHERE sub.id_group = :new.id_group
       AND not EXISTS
        (SELECT 1
		FROM T_RECUR_WINDOW
		where c__AccountID = :new.id_acc
			AND c__SubscriptionID = sub.id_sub
			and c__PriceableItemInstanceID = plm.id_pi_instance
			and c__PriceableItemTemplateID = plm.id_pi_template)
		AND rcr.b_charge_per_participant = 'Y'
		AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);
  
	/* adds charges to METER tables */
	MeterInitialFromRecurWindow(currentDate);
	MeterCreditFromRecurWindow(currentDate);
 
	INSERT INTO t_recur_window
    SELECT c_CycleEffectiveDate,
    c_CycleEffectiveStart,
    c_CycleEffectiveEnd,
    c_SubscriptionStart,
    c_SubscriptionEnd,
    c_Advance,
    c__AccountID,
    c__PayingAccount,
    c__PriceableItemInstanceID,
    c__PriceableItemTemplateID,
    c__ProductOfferingID,
    c_PayerStart,
    c_PayerEnd,
    c__SubscriptionID,
    c_UnitValueStart,
    c_UnitValueEnd,
    c_UnitValue,
    c_BilledThroughDate,
    c_LastIdRun,
    c_MembershipStart,
    c_MembershipEnd
    FROM tmp_newrw
	WHERE c__subscriptionid = v_id_sub;
 
	 /* TODO: do we need it for delete action? */
	UPDATE t_recur_window w1
	SET c_CycleEffectiveEnd =
	  (SELECT MIN(NVL(w2.c_CycleEffectiveDate,w2.c_SubscriptionEnd))
	  FROM t_recur_window w2
	  WHERE w2.c__SubscriptionID  = w1.c__SubscriptionID
	  AND w1.c_PayerStart         = w2.c_PayerStart
	  AND w1.c_PayerEnd           = w2.c_PayerEnd
	  AND w1.c_UnitValueStart     = w2.c_UnitValueStart
	  AND w1.c_UnitValueEnd       = w2.c_UnitValueEnd
	  AND w2.c_CycleEffectiveDate > w1.c_CycleEffectiveDate
	  )
	WHERE EXISTS
	  (SELECT 1
	  FROM t_recur_window w2
	  WHERE w2.c__SubscriptionID  = w1.c__SubscriptionID
	  AND w1.c_PayerStart         = w2.c_PayerStart
	  AND w1.c_PayerEnd           = w2.c_PayerEnd
	  AND w1.c_UnitValueStart     = w2.c_UnitValueStart
	  AND w1.c_UnitValueEnd       = w2.c_UnitValueEnd
	  AND w2.c_CycleEffectiveDate > w1.c_CycleEffectiveDate
	  ) ;
END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_BillMessageHistory
 AFTER INSERT OR UPDATE ON t_be_cor_bil_billmessage
 REFERENCING NEW AS dataRow 
FOR EACH ROW 
UPDATE t_be_cor_bil_billmessage_h
 SET c__enddate = :dataRow.c_updatedate 
WHERE c_BillMessage_Id = :dataRow.c_BillMessage_Id AND c__enddate = CAST(dbo.mtmaxdate() AS TIMESTAMP); 
INSERT INTO t_be_cor_bil_billmessage_h
( 
c__version, 
c_creationdate, 
c_updatedate, 
c_uid, 
c_billmessage_id, 
c_messagecode, 
c_messagetype, 
c_messagetext, 
c_messageformat, 
c_language, 
c__startdate, 
c__enddate
) 
VALUES 
( 
:dataRow.c__version, 
:dataRow.c_creationdate, 
:dataRow.c_updatedate, 
:dataRow.c_uid, 
:dataRow.c_billmessage_id, 
:dataRow.c_messagecode, 
:dataRow.c_messagetype, 
:dataRow.c_messagetext, 
:dataRow.c_messageformat, 
:dataRow.c_language, 
:dataRow.c_updatedate, 
CAST(dbo.mtmaxdate() AS TIMESTAMP)
)
/

ALTER PROCEDURE mtsp_insertinvoice_balances COMPILE ;

ALTER PROCEDURE getbalances COMPILE ;

ALTER PROCEDURE archive_delete COMPILE ;

ALTER PROCEDURE reverse_updatestaterecordset COMPILE ;

ALTER PROCEDURE rev_updatestatefromclosedtopfb COMPILE ;

ALTER PROCEDURE updatestaterecordset COMPILE ;

ALTER PROCEDURE updatestatefromclosedtopfb COMPILE ;

ALTER PROCEDURE archive_export COMPILE ;

ALTER PROCEDURE archive_trash COMPILE ;

ALTER PROCEDURE dearchive_account COMPILE ;

ALTER PROCEDURE checkaccountstatedaterules COMPILE ;

ALTER PROCEDURE updateunassignedaccounts COMPILE ;

ALTER PROCEDURE getpcviewhierarchy COMPILE ;

ALTER PROCEDURE deleteaccounts COMPILE ;

ALTER PROCEDURE getpaymentinfo COMPILE ;

ALTER PROCEDURE "ANALYZE" COMPILE ;

ALTER PROCEDURE mtsp_generate_st_rcs_quoting COMPILE ;

ALTER PROCEDURE popfirstmessage COMPILE ;

ALTER PROCEDURE mtunclaimmessages COMPILE ;

ALTER FUNCTION messagequeuelength COMPILE ;

ALTER PACKAGE  mt_rate_pkg COMPILE BODY;

ALTER PROCEDURE sp_deletepricelist COMPILE ;

ALTER PROCEDURE subscribebatchgroupsub COMPILE ;

ALTER PROCEDURE createsubscriptionrecord COMPILE ;

ALTER PROCEDURE adjustsubdates COMPILE ;

ALTER PROCEDURE addsubscriptionbase COMPILE ;

ALTER PROCEDURE deleteproductoffering COMPILE ;

ALTER PROCEDURE deletepriceableiteminstance COMPILE ;

ALTER PROCEDURE adddefaultpiplmappings COMPILE ;

ALTER PROCEDURE removegroupsubscription COMPILE ;

ALTER PROCEDURE removegsubs_quoting COMPILE ;

ALTER PROCEDURE prtn_deploy_all_meter_tables COMPILE ;

ALTER PROCEDURE prtn_deploy_all_usage_tables COMPILE ;

ALTER PROCEDURE mtsp_insertinvoice COMPILE ;

ALTER PROCEDURE checkgroupsubbusinessrules COMPILE ;

ALTER PROCEDURE creategroupsubscription COMPILE ;

ALTER PROCEDURE addnewsub COMPILE ;

ALTER PROCEDURE bulksubscriptionchange COMPILE ;

ALTER PROCEDURE updatesub COMPILE ;

ALTER PROCEDURE updategroupsubscription COMPILE ;

ALTER TRIGGER trg_recur_win_acc_usage_int COMPILE ;

ALTER PROCEDURE removesubscription COMPILE ;

ALTER PROCEDURE getrateschedules COMPILE ;

ALTER PROCEDURE updatestatefrompfbtoclosed COMPILE ;

ALTER PROCEDURE adjustgsubmemberdates COMPILE ;

ALTER PROCEDURE creategsubmemberrecord COMPILE ;

ALTER PROCEDURE updategroupsubmembership COMPILE ;

ALTER PROCEDURE addaccounttogroupsub COMPILE ;

ALTER PROCEDURE sequenceddeletegsubrecur COMPILE ;

ALTER PROCEDURE sequencedinsertgsubrecur COMPILE ;

ALTER PROCEDURE sequencedupsertgsubrecur COMPILE ;

ALTER PROCEDURE seqinsertgsubrecurinitialize COMPILE ;

ALTER PROCEDURE rev_updatestatefrompfbtoclosed COMPILE ;

ALTER PROCEDURE completematerialization COMPILE ;

ALTER PROCEDURE completerematerialization COMPILE ;

ALTER PROCEDURE updstatefromclosedtoarchived COMPILE ;

ALTER PROCEDURE createaccountstaterecord COMPILE ;

ALTER PROCEDURE updateaccountstate COMPILE ;

ALTER PROCEDURE createdefaultpartition COMPILE ;

ALTER PROCEDURE prtn_create_usage_partitions COMPILE ;

ALTER PROCEDURE createusageintervals COMPILE ;

ALTER PROCEDURE rev_updstatefromclosedtoarchiv COMPILE ;

ALTER PROCEDURE removegroupsubmember COMPILE ;

ALTER PROCEDURE addownedfolder COMPILE ;

ALTER PROCEDURE addbillmanager COMPILE ;

ALTER PROCEDURE determinereversibleevents COMPILE ;

ALTER PROCEDURE determineexecutableevents COMPILE ;

ALTER PROCEDURE instantiatescheduledevent COMPILE ;

ALTER PROCEDURE getrecurringeventdepsbyinst COMPILE ;

ALTER PROCEDURE canreverseeventdeps COMPILE ;

ALTER PROCEDURE canexecuteeventdeps COMPILE ;

ALTER PROCEDURE billingserverstop COMPILE ;

ALTER PROCEDURE billingserverstart COMPILE ;

ALTER PROCEDURE billingserverrepair COMPILE ;

ALTER PROCEDURE createandpopulatetempaccts COMPILE ;

ALTER PROCEDURE acquirerecurringeventinstance COMPILE ;

ALTER PROCEDURE copyadapterinstances COMPILE ;

ALTER PROCEDURE completechildgroupcreation COMPILE ;

ALTER PROCEDURE canreverseevents COMPILE ;

ALTER PROCEDURE canexecuteevents COMPILE ;

ALTER PROCEDURE acknowledgecheckpoint COMPILE ;

ALTER PROCEDURE mtsp_backoutinvoices COMPILE ;

ALTER PROCEDURE adduniquekeymetadata COMPILE ;

ALTER PROCEDURE getlocalizedentries COMPILE ;

ALTER PROCEDURE getcolumnmetadata COMPILE ;

ALTER PROCEDURE getmaterializedviewquerytags COMPILE ;

ALTER PROCEDURE dearchive_files COMPILE ;

ALTER TRIGGER trg_alldatatypebmehistory COMPILE ;

ALTER TRIGGER trg_invocationrecordbehistory COMPILE ;

ALTER TRIGGER trg_disputehistory COMPILE ;

ALTER TRIGGER trg_billmessageaccounthistory COMPILE ;

ALTER PROCEDURE openbillinggroup COMPILE ;

ALTER PROCEDURE account_bucket_mapping COMPILE ;

ALTER PROCEDURE isaccbillablenpayingforothers COMPILE ;

ALTER PROCEDURE updexpiredintervalstoblocked COMPILE ;

ALTER PROCEDURE unacknowledgecheckpoint COMPILE ;

ALTER PROCEDURE startuserdefinedgroupcreation COMPILE ;

ALTER PROCEDURE startchildgroupcreation COMPILE ;

ALTER PROCEDURE softclosebillinggroups COMPILE ;

ALTER PROCEDURE openusageinterval COMPILE ;

ALTER PROCEDURE hardcloseexpiredintervals_npa COMPILE ;

ALTER PACKAGE  mt_ttt COMPILE BODY;

ALTER TRIGGER trg_subscribe_batch COMPILE ;

ALTER TRIGGER trg_tmp_svc_relations COMPILE ;

ALTER TRIGGER trg_ttt_tmp_message COMPILE ;

ALTER TRIGGER trg_tmp_child_session_sets COMPILE ;

ALTER TRIGGER trg_tmp_aggregate_large COMPILE ;

ALTER PROCEDURE addcountertype COMPILE ;
