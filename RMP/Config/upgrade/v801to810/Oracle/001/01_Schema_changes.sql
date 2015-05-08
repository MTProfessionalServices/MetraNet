SET DEFINE OFF

ALTER TABLE t_message DROP PRIMARY KEY DROP INDEX;

ALTER TABLE t_message ADD CONSTRAINT pk_t_message PRIMARY KEY (id_message,id_partition) USING INDEX (CREATE INDEX pk_t_message ON t_message(id_message,id_partition)  );

ALTER TABLE t_session_set DROP PRIMARY KEY DROP INDEX;

ALTER TABLE t_session_set ADD CONSTRAINT pk_t_session_set PRIMARY KEY (id_ss,id_partition) USING INDEX (CREATE INDEX pk_t_session_set ON t_session_set(id_ss,id_partition)  );

ALTER TABLE t_acc_usage DROP PRIMARY KEY DROP INDEX;

ALTER TABLE t_acc_usage ADD CONSTRAINT pk_t_acc_usage PRIMARY KEY (id_sess,id_usage_interval) USING INDEX (CREATE INDEX pk_t_acc_usage ON t_acc_usage(id_sess,id_usage_interval)  );

ALTER TABLE t_session_state DROP PRIMARY KEY DROP INDEX;

ALTER TABLE t_session_state ADD CONSTRAINT pk_t_session_state PRIMARY KEY (id_sess,dt_end,tx_state,id_partition) USING INDEX (CREATE INDEX pk_t_session_state ON t_session_state(id_sess,dt_end,tx_state,id_partition)  );

ALTER TABLE t_session DROP PRIMARY KEY DROP INDEX;

ALTER TABLE t_session ADD CONSTRAINT pk_t_session PRIMARY KEY (id_ss,id_source_sess,id_partition) USING INDEX (CREATE INDEX pk_t_session ON t_session(id_ss,id_source_sess,id_partition)  );

ALTER TABLE t_tax_details MODIFY (is_implied DEFAULT NULL);

ALTER TABLE t_tax_details DROP PRIMARY KEY DROP INDEX;

ALTER TABLE t_tax_details ADD CONSTRAINT pk_t_tax_details PRIMARY KEY (id_usage_interval,id_tax_charge,id_tax_detail,id_tax_run) USING INDEX (CREATE INDEX pk_t_tax_details ON t_tax_details(id_usage_interval,id_tax_charge,id_tax_detail,id_tax_run)  );

ALTER TABLE subscriptionsbymonth ADD (reportingcurrency NVARCHAR2(3));

COMMENT ON COLUMN subscriptionsbymonth.reportingcurrency IS 'Currency for the Subscription';

DROP TABLE tmp_accs;

CREATE TABLE tmp_accs (
  id_ancestor NUMBER(*,0) NOT NULL,
  id_descendent NUMBER(*,0) NOT NULL
);

CREATE TABLE tmp_previous_two_months (
  instanceid VARCHAR2(64 BYTE),
  "YEAR" NUMBER(*,0),
  "MONTH" NUMBER(*,0),
  firstdayofmonth DATE,
  lastdayofmonth DATE
);

CREATE TABLE subscriptionparticipants (
  instanceid NVARCHAR2(64),
  productofferingid NUMBER(*,0) NOT NULL,
  "YEAR" NUMBER(*,0) NOT NULL,
  "MONTH" NUMBER(*,0) NOT NULL,
  totalparticipants NUMBER(*,0) NOT NULL,
  distincthierarchies NUMBER(*,0) NOT NULL,
  newparticipants NUMBER(*,0) NOT NULL,
  unsubscribedparticipants NUMBER(*,0) NOT NULL
);

COMMENT ON TABLE subscriptionparticipants IS 'The SubscriptionParticipants reports on a total number of subscriptions (including both indivudal subscriptions and group subscription partipants) to each product offering in a calendar month. The SubscriptionParticipants table holds data for the current calendar month and the two preceeding calendar months.';

COMMENT ON COLUMN subscriptionparticipants.instanceid IS 'The MetraNet instance from which the data originated.';

COMMENT ON COLUMN subscriptionparticipants.productofferingid IS 'Product Offering Identifier.';

COMMENT ON COLUMN subscriptionparticipants."YEAR" IS 'The calendar year in which the subscription participants were active.';

COMMENT ON COLUMN subscriptionparticipants."MONTH" IS 'The calendar month in which the subscription participants were active.';

COMMENT ON COLUMN subscriptionparticipants.totalparticipants IS 'Total number of subscriptions to  this product offering that were active during the calendar month.';

COMMENT ON COLUMN subscriptionparticipants.distincthierarchies IS 'The number of unique customers. For example, a company may have 200 users with the subscription, that would be ONE here and 200 in Subscriptions above.';

COMMENT ON COLUMN subscriptionparticipants.newparticipants IS 'Total number of new subscriptions to this product offering that became active during this calendar month that were not active in the previous calendar month.';

COMMENT ON COLUMN subscriptionparticipants.unsubscribedparticipants IS 'Total number of subscriptions to this product offering that expired during this calendar month.';

DROP TABLE all_rcs_linked;

CREATE TABLE all_rcs_linked (
  instanceid VARCHAR2(64 BYTE),
  subscriptionid NUMBER(*,0) NOT NULL,
  payerid NUMBER(*,0) NOT NULL,
  payeeid NUMBER(*,0) NOT NULL,
  startdate DATE,
  enddate DATE,
  actiontype NVARCHAR2(255),
  currency NVARCHAR2(3),
  prorateddailyrate NUMBER(22,10),
  dailyrate NUMBER(22,10),
  rate NUMBER(22,10),
  productofferingid NUMBER(*,0),
  priceableitemtemplateid NUMBER(*,0),
  priceableiteminstanceid NUMBER(*,0),
  subscriptionstartdate DATE,
  subscriptionenddate DATE,
  mrr NUMBER(22,10),
  oldrate NUMBER(22,10),
  olddailyrate NUMBER(22,10),
  oldprorateddailyrate NUMBER(22,10),
  oldsubscriptionstartdate DATE,
  oldsubscriptionenddate DATE
);

DROP TABLE all_rcs_by_month;

CREATE TABLE all_rcs_by_month (
  instanceid VARCHAR2(64 BYTE),
  subscriptionid NUMBER(*,0) NOT NULL,
  productofferingid NUMBER(*,0),
  priceableitemtemplateid NUMBER(*,0),
  priceableiteminstanceid NUMBER(*,0),
  subscriptionstartdate DATE,
  subscriptionenddate DATE,
  currency NVARCHAR2(3),
  actiontype NVARCHAR2(255),
  "YEAR" NUMBER(*,0),
  "MONTH" NUMBER(*,0),
  dailyrate NUMBER(22,10),
  rate NUMBER(22,10),
  olddailyrate NUMBER(22,10),
  oldrate NUMBER(22,10),
  oldprorateddailyrate NUMBER(22,10),
  oldsubscriptionstartdate DATE,
  oldsubscriptionenddate DATE,
  days NUMBER(*,0)
);

COMMENT ON COLUMN t_rec_win_bcp_for_reverse.c_cycleeffectivedate IS 'The date in the cycle for this PO/sub';

ALTER TABLE t_ep_usage ADD (c_isliabilityproduct CHAR,c_revenuecode NVARCHAR2(128),c_deferredrevenuecode NVARCHAR2(128));

COMMENT ON COLUMN t_ep_usage.c_isliabilityproduct IS 'Shows is this a liability product';

COMMENT ON COLUMN t_ep_usage.c_revenuecode IS 'Revenue Code for product';

COMMENT ON COLUMN t_ep_usage.c_deferredrevenuecode IS 'Deferred Revenue Code for product';

ALTER TABLE t_approvals ADD (c_partitionid NUMBER(10) DEFAULT 1 NOT NULL);

COMMENT ON COLUMN t_approvals.c_partitionid IS 'Partition ID of the Change (e.g.: For Subscription, Product Offering or Rate updates, the Partition Id of the related Product Offering will be saved)';

COMMENT ON COLUMN t_approvals.c_submitteddate IS 'When the change was submitted';

COMMENT ON COLUMN t_approvals.c_submitterid IS 'Id of account, who did the change';

COMMENT ON COLUMN t_approvals.c_changetype IS 'Type of the Change ("RateUpdate", "AccountUpdate", "ProductOfferingUpdate", ect.)';

COMMENT ON COLUMN t_approvals.c_changedetails IS 'Encrypted full information about the change, that will be given to MT Service on Apply';

COMMENT ON COLUMN t_approvals.c_approverid IS 'Id of account, who Approved, Denied or Dissmissed the change';

COMMENT ON COLUMN t_approvals.c_changelastmodifieddate IS 'When the change was modified last time';

COMMENT ON COLUMN t_approvals.c_itemdisplayname IS 'Changes description that will be displayed for user';

COMMENT ON COLUMN t_approvals.c_uniqueitemid IS 'Field with unique value';

COMMENT ON COLUMN t_approvals.c_comment IS 'Comment that Approver provided on changing state of the Change';

COMMENT ON COLUMN t_approvals.c_currentstate IS 'State of the change ("Pending", "Approved", "FailedToApply")';

COMMENT ON COLUMN t_acc_tmpl_types.all_types IS 'The value indicating the designated account templates model: 0  old model (template is applicable to the accounts of a specific type), 1  All Types model (template is applicable to all accounts regardless theirs types).';

ALTER TABLE t_billgroup ADD (id_partition NUMBER(10));

COMMENT ON COLUMN t_billgroup.id_partition IS 'Unique Partition identifier';

ALTER TABLE t_billgroup MODIFY (tx_name NVARCHAR2(255));

CREATE TABLE t_notification_event_types (
  id_notification_event_type NUMBER(10) NOT NULL,
  notification_event_name NVARCHAR2(255) NOT NULL,
  CONSTRAINT pk_t_notification_event_types PRIMARY KEY (id_notification_event_type)
);

COMMENT ON TABLE t_notification_event_types IS 'The table contains notification event types configured in the system.';

COMMENT ON COLUMN t_notification_event_types.id_notification_event_type IS 'Unique identifier of the notification event type.';

COMMENT ON COLUMN t_notification_event_types.notification_event_name IS 'Name of the notification event type.';

CREATE TABLE t_notification_events (
  id_notification_event NUMBER(20) NOT NULL,
  id_notification_event_type NUMBER(10) NOT NULL,
  notification_event_prop_values NVARCHAR2(2000) NOT NULL,
  id_partition NUMBER(10),
  dt_crt DATE NOT NULL,
  CONSTRAINT pk_t_notification_events PRIMARY KEY (id_notification_event),
  CONSTRAINT fk_t_notification_events FOREIGN KEY (id_notification_event_type) REFERENCES t_notification_event_types (id_notification_event_type)
);

COMMENT ON TABLE t_notification_events IS 'The table contains notification events generated for notification types configured in the system.';

COMMENT ON COLUMN t_notification_events.id_notification_event IS 'Unique identifier of the notification event.';

COMMENT ON COLUMN t_notification_events.id_notification_event_type IS 'Unique identifier of the notification event type.';

COMMENT ON COLUMN t_notification_events.notification_event_prop_values IS 'XML string containing property names and values for the notification event.';

COMMENT ON COLUMN t_notification_events.id_partition IS 'Partition Id of the notification event if applicable otherwise null.';

COMMENT ON COLUMN t_notification_events.dt_crt IS 'Notification event creation date.';

CREATE TABLE t_localized_items_type (
  id_local_type NUMBER(*,0) NOT NULL,
  local_type_description NVARCHAR2(255) NOT NULL,
  CONSTRAINT pk_t_localized_items_type PRIMARY KEY (id_local_type)
);

COMMENT ON TABLE t_localized_items_type IS 'Dictionary table for t_localized_items.id_local_type colum. Contains id localization type and their description';

COMMENT ON COLUMN t_localized_items_type.id_local_type IS 'Primary key.';

COMMENT ON COLUMN t_localized_items_type.local_type_description IS 'Description type';


INSERT INTO t_localized_items_type(id_local_type, local_type_description)
VALUES (1, 'Localization type for Adapters (see t_recevent table)');

INSERT INTO t_localized_items_type(id_local_type, local_type_description)
VALUES (2, 'Localization type for Composite Capability (see t_composite_capability_type table)');

INSERT INTO t_localized_items_type(id_local_type, local_type_description)
VALUES (3, 'Localization type for Atomic Capability (see t_atomic_capability_type table)');

INSERT INTO t_localized_items_type(id_local_type, local_type_description)
VALUES (4, 'Localization type for Security Roles (see t_role table)');
      

DROP TABLE sum_rcs_by_month;

CREATE TABLE sum_rcs_by_month (
  instanceid VARCHAR2(64 BYTE),
  subscriptionid NUMBER(*,0) NOT NULL,
  priceableitemtemplateid NUMBER(*,0),
  priceableiteminstanceid NUMBER(*,0),
  currency NVARCHAR2(3),
  "YEAR" NUMBER(*,0),
  "MONTH" NUMBER(*,0),
  daysinmonth NUMBER(*,0),
  daysactiveinmonth NUMBER(*,0),
  totalamount NUMBER(22,10),
  oldamount NUMBER(22,10),
  newamount NUMBER(22,10)
);

DROP TABLE all_rcs;

CREATE TABLE all_rcs (
  instanceid VARCHAR2(64 BYTE),
  subscriptionid NUMBER(*,0) NOT NULL,
  payerid NUMBER(*,0) NOT NULL,
  payeeid NUMBER(*,0) NOT NULL,
  startdate DATE,
  enddate DATE,
  actiontype NVARCHAR2(255),
  currency NVARCHAR2(3),
  prorateddailyrate NUMBER(22,10),
  dailyrate NUMBER(22,10),
  rate NUMBER(22,10),
  productofferingid NUMBER(*,0),
  priceableitemtemplateid NUMBER(*,0),
  priceableiteminstanceid NUMBER(*,0),
  subscriptionstartdate DATE,
  subscriptionenddate DATE,
  mrr NUMBER(22,10)
);

ALTER TABLE t_ep_discount ADD (c_isliabilityproduct CHAR,c_revenuecode NVARCHAR2(128),c_deferredrevenuecode NVARCHAR2(128));

COMMENT ON COLUMN t_ep_discount.c_isliabilityproduct IS 'Shows is this a liability product';

COMMENT ON COLUMN t_ep_discount.c_revenuecode IS 'Revenue Code for product';

COMMENT ON COLUMN t_ep_discount.c_deferredrevenuecode IS 'Deferred Revenue Code for product';

ALTER TABLE t_billgroup_member_tmp ADD (id_partition NUMBER(10));

COMMENT ON COLUMN t_billgroup_member_tmp.id_partition IS 'Unique Partition identifier';

ALTER TABLE t_billgroup_member_tmp MODIFY (tx_name NVARCHAR2(255));

ALTER TABLE t_ep_recurring ADD (c_isliabilityproduct CHAR,c_revenuecode NVARCHAR2(128),c_deferredrevenuecode NVARCHAR2(128));

UPDATE t_ep_recurring SET c_isliabilityproduct = 'N';

ALTER TABLE t_ep_recurring MODIFY (c_isliabilityproduct NOT NULL);

COMMENT ON COLUMN t_ep_recurring.c_isliabilityproduct IS 'Shows is this a liability product';

COMMENT ON COLUMN t_ep_recurring.c_revenuecode IS 'Revenue Code for product';

COMMENT ON COLUMN t_ep_recurring.c_deferredrevenuecode IS 'Deferred Revenue Code for product';

CREATE TABLE rg_temp_329389179_5 (
  instanceid NVARCHAR2(64) NOT NULL,
  metranetid NUMBER(*,0) NOT NULL,
  accounttype NVARCHAR2(200) NOT NULL,
  externalid NVARCHAR2(255) NOT NULL,
  externalidspace NVARCHAR2(40),
  firstname NVARCHAR2(40),
  middlename NVARCHAR2(1),
  lastname NVARCHAR2(40),
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
  startdate DATE,
  enddate DATE,
  CONSTRAINT RG_TEMP_329389179_8 PRIMARY KEY (instanceid,metranetid) USING INDEX (CREATE UNIQUE INDEX rg_temp_329389179_9 ON rg_temp_329389179_5(instanceid,metranetid)    )
);

INSERT INTO rg_temp_329389179_5(instanceid,metranetid,accounttype,externalid,externalidspace,firstname,middlename,lastname,company,currency,city,state,zipcode,email,country,phone,hierarchymetranetid,hierarchyaccounttype,hierarchyexternalid,hierarchyexternalidspace,hierarchyfirstname,hierarchymiddlename,hierarchylastname,hierarchycompany,hierarchycurrency,hierarchycity,hierarchystate,hierarchyzipcode,hierarchycountry,hierarchyemail,hierarchyphone,startdate,enddate) SELECT instanceid,metranetid,accounttype,externalid,externalidspace,firstname,SUBSTR(middlename, 0, LEAST(LENGTH(middlename), 1)),lastname,company,currency,city,state,zipcode,email,country,phone,hierarchymetranetid,hierarchyaccounttype,hierarchyexternalid,hierarchyexternalidspace,hierarchyfirstname,hierarchymiddlename,hierarchylastname,hierarchycompany,hierarchycurrency,hierarchycity,hierarchystate,hierarchyzipcode,hierarchycountry,hierarchyemail,hierarchyphone,NULL,NULL FROM customer;

DROP TABLE customer;

ALTER TABLE rg_temp_329389179_5 RENAME TO customer;

ALTER TABLE customer RENAME CONSTRAINT RG_TEMP_329389179_8 TO pk_customer;

ALTER INDEX rg_temp_329389179_9 RENAME TO PK_CUSTOMER;

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

COMMENT ON COLUMN customer.startdate IS 'Active Start Date for the Customer';

COMMENT ON COLUMN customer.enddate IS 'Active End Date for the Customer';

CREATE TABLE t_notification_event_consumers (
  id_not_evnt_consumer NUMBER(20) NOT NULL,
  id_notification_event NUMBER(20) NOT NULL,
  id_acc NUMBER(10) NOT NULL,
  dt_crt DATE NOT NULL,
  CONSTRAINT pk_t_notification_evnt_consmrs PRIMARY KEY (id_not_evnt_consumer),
  CONSTRAINT fk_t_notification_evnt_consmrs FOREIGN KEY (id_notification_event) REFERENCES t_notification_events (id_notification_event)
);

COMMENT ON TABLE t_notification_event_consumers IS 'The table maps notification events to account ids who can see the generated notification events.';

COMMENT ON COLUMN t_notification_event_consumers.id_not_evnt_consumer IS 'Unique row identifier.';

COMMENT ON COLUMN t_notification_event_consumers.id_notification_event IS 'Unique identifier of the notification event.';

COMMENT ON COLUMN t_notification_event_consumers.id_acc IS 'Unique identifier of the account to which the notification event should be displayed.';

COMMENT ON COLUMN t_notification_event_consumers.dt_crt IS 'Row creation date.';

ALTER TABLE t_ep_nonrecurring ADD (c_isliabilityproduct CHAR,c_revenuecode NVARCHAR2(128),c_deferredrevenuecode NVARCHAR2(128));

UPDATE t_ep_nonrecurring SET c_isliabilityproduct = 'N';

ALTER TABLE t_ep_nonrecurring MODIFY (c_isliabilityproduct NOT NULL);

COMMENT ON COLUMN t_ep_nonrecurring.c_isliabilityproduct IS 'Shows is this a liability product';

COMMENT ON COLUMN t_ep_nonrecurring.c_revenuecode IS 'Revenue Code for product';

COMMENT ON COLUMN t_ep_nonrecurring.c_deferredrevenuecode IS 'Deferred Revenue Code for product';

ALTER TABLE t_ep_unit_dependent_recurring ADD (c_isliabilityproduct CHAR NOT NULL,c_revenuecode NVARCHAR2(128),c_deferredrevenuecode NVARCHAR2(128));

COMMENT ON COLUMN t_ep_unit_dependent_recurring.c_isliabilityproduct IS 'Shows is this a liability product';

COMMENT ON COLUMN t_ep_unit_dependent_recurring.c_revenuecode IS 'Revenue Code for product';

COMMENT ON COLUMN t_ep_unit_dependent_recurring.c_deferredrevenuecode IS 'Deferred Revenue Code for product';

CREATE TABLE t_localized_items (
  id_local_type NUMBER(*,0) NOT NULL,
  id_item NUMBER(*,0) NOT NULL,
  id_item_second_key NUMBER(*,0) DEFAULT -1 NOT NULL,
  id_lang_code NUMBER(*,0) NOT NULL,
  tx_name NVARCHAR2(255),
  tx_desc NVARCHAR2(2000),
  CONSTRAINT pk_t_localized_items PRIMARY KEY (id_local_type,id_item,id_item_second_key,id_lang_code),
  CONSTRAINT fk_localize_to_t_language FOREIGN KEY (id_lang_code) REFERENCES t_language (id_lang_code),
  CONSTRAINT fk_local_to_local_items_type FOREIGN KEY (id_local_type) REFERENCES t_localized_items_type (id_local_type)
);

COMMENT ON TABLE t_localized_items IS 'The t_localized_items table contains the localized DisplayName and Description of entyties (for example t_recevent, t_composite_capability_type, t_atomic_capability_type tables) for the languages supported by the MetraTech platform.(Package:Pipeline) ';

COMMENT ON COLUMN t_localized_items.id_local_type IS 'Composite key: This is foreign key to t_localized_items_type.';

COMMENT ON COLUMN t_localized_items.id_item IS 'Composite key: Localize identifier. This is foreign key to t_recevent and other tables (see constraints)';

COMMENT ON COLUMN t_localized_items.id_item_second_key IS 'Composite key: Second localize identifier. This is foreign key, for example, to t_compositor (it is atomoc capability) and other tables with composite PK. In case second key is not used set -1 as default value';

COMMENT ON COLUMN t_localized_items.id_lang_code IS 'Composite key: Language identifier displayed on the MetraNet Presentation Server';

COMMENT ON COLUMN t_localized_items.tx_name IS 'The localized DisplayName';

COMMENT ON COLUMN t_localized_items.tx_desc IS 'The localized DEscription';

ALTER TABLE t_billgroup_tmp ADD (id_partition NUMBER(10));

COMMENT ON COLUMN t_billgroup_tmp.id_partition IS 'Unique Partition identifier';

ALTER TABLE t_billgroup_tmp MODIFY (tx_name NVARCHAR2(255),tx_description NVARCHAR2(2000));

CREATE TABLE t_message_mapping (
  id_message NUMBER(10) NOT NULL,
  id_origin_message NUMBER(10) NOT NULL,
  CONSTRAINT pk_t_message_mapping PRIMARY KEY (id_origin_message)
);

COMMENT ON TABLE t_message_mapping IS 'Mapping table for linking between parents messages and childs messages.';

COMMENT ON COLUMN t_message_mapping.id_message IS 'Child message';

COMMENT ON COLUMN t_message_mapping.id_origin_message IS 'Primary key. Parents message';

DECLARE l_count PLS_INTEGER;
BEGIN
   SELECT COUNT ( * ) INTO l_count  FROM USER_TAB_COLUMNS  WHERE table_name = upper('t_failed_transaction') AND column_name = upper('dt_Start_Resubmit');
   IF l_count = 0
   THEN
      execute immediate 'alter table t_failed_transaction add dt_Start_Resubmit TIMESTAMP NULL';
   END IF;
END;

DECLARE l_count PLS_INTEGER;
BEGIN
   SELECT COUNT ( * ) INTO l_count  FROM USER_TAB_COLUMNS  WHERE table_name =  upper('t_failed_transaction') AND column_name =  upper('resubmit_Guid');
   IF l_count = 0
   THEN
      execute immediate 'alter table t_failed_transaction add resubmit_Guid VARCHAR2(36) NULL';
   END IF;
END;

DROP TABLE t_aj_flatdiscount_nocond;

DROP TABLE t_aj_percentdiscount;

DROP TABLE t_aj_flatdiscount;

DROP TABLE t_aj_percentdiscount_nocond;

ALTER PACKAGE dbo COMPILE;

CREATE OR REPLACE PROCEDURE CompleteChildGroupCreation
(
  p_id_materialization INT,
  p_dt_end DATE,
  status out INT
)
AS
  v_id_parent_billgroup INT;
  cnt int;
  v_id_partition INT;
BEGIN
  /* initialize @status to failure (-1) */
  status := -1;
  
  SELECT max(id_parent_billgroup), count(id_parent_billgroup)
    into v_id_parent_billgroup, cnt
  FROM t_billgroup_materialization
  WHERE id_materialization = p_id_materialization;
  
  /* Error if there is no id_parent_billgroup is NULL */
  IF cnt != 1 then
    status := -2;
    RETURN;
  END if;
  
  /* delete child group accounts for parent billing group 
    from t_billgroup_member
    */
  DELETE  t_billgroup_member bgm
  where exists (
    select 1
    from t_billgroup_member_tmp bgmt
  WHERE bgmt.id_acc = bgm.id_acc
    and bgmt.id_materialization = p_id_materialization
    AND bgm.id_billgroup = v_id_parent_billgroup);

  /* update t_billgroup_member_history to reflect the deletion */
  UPDATE t_billgroup_member_history bgmh
    SET tt_end = p_dt_end
  where exists (
    select 1
    from t_billgroup_member_tmp bgmt
    where bgmt.id_acc = bgmh.id_acc
      and bgmt.id_materialization = p_id_materialization
      and bgmh.id_billgroup = v_id_parent_billgroup);
  
   -- get id_partition of the parent bill group
   SELECT id_partition
   INTO v_id_partition
   FROM t_billgroup bg
   WHERE id_billgroup = v_id_parent_billgroup;
  
  /* insert child billing group data into t_billgroup from t_billgroup_tmp */
  INSERT INTO t_billgroup (id_billgroup,
    tx_name,
    tx_description,
    id_usage_interval,
    id_parent_billgroup,
    tx_type,
    id_partition)
  SELECT bgt.id_billgroup,
    bgt.tx_name,
    bgt.tx_description,
    bgm.id_usage_interval,
    bgm.id_parent_billgroup,
    bgm.tx_type,
    v_id_partition
  FROM t_billgroup_tmp bgt
  INNER JOIN t_billgroup_materialization bgm
     ON bgm.id_materialization = bgt.id_materialization
  WHERE bgm.id_materialization = p_id_materialization;

  /* insert child billing group data into t_billgroup_member */
  INSERT INTO t_billgroup_member (id_billgroup, id_acc, id_materialization,
    id_root_billgroup)
  SELECT bgt.id_billgroup, bgmt.id_acc, p_id_materialization,
    dbo.GetBillingGroupAncestor(bgt.id_billgroup)
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt
   ON bgt.tx_name = bgmt.tx_name
  WHERE bgmt.id_materialization =  p_id_materialization
    and bgt.id_materialization = p_id_materialization;

  /* update t_billgroup_member_history to reflect the addition */
  INSERT INTO t_billgroup_member_history (
    id_billgroup,
    id_acc,
    id_materialization,
    tx_status,
    tt_start,
    tt_end)
  SELECT bgt.id_billgroup,
    bgmt.id_acc,
    p_id_materialization,
    'Succeeded',
    p_dt_end,
    dbo.MTMaxDate()
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt
    ON bgt.tx_name = bgmt.tx_name
  WHERE bgmt.id_materialization =  p_id_materialization
    and bgt.id_materialization = p_id_materialization;
  
  /* set @status to success */
  status := 0;

END CompleteChildGroupCreation;
/

ALTER PROCEDURE upsertdescription COMPILE;

CREATE OR REPLACE procedure UpdateBaseProps(
				a_id_prop t_base_props.id_prop%type,
				a_id_lang int,
				a_nm_name t_base_props.nm_name%type,
				a_nm_desc t_base_props.nm_desc%type,
				a_nm_display_name t_base_props.nm_display_name%type,
				updated_id_display_name OUT int,
				updated_id_display_desc OUT int)
				AS
				old_id_name t_base_props.n_name%type;
				id_name t_base_props.n_name%type;
				old_id_desc t_base_props.n_desc%type;
				old_id_display_name t_base_props.n_display_name%type;
				BEGIN
					begin
						SELECT n_name, n_desc, n_display_name
						into old_id_name, old_id_desc, old_id_display_name
						from t_base_props where id_prop = a_id_prop;
					exception
						when no_data_found then
							null;
					end;
					UpsertDescription(a_id_lang, a_nm_name, old_id_name, id_name);
					UpsertDescription(a_id_lang, a_nm_desc, old_id_desc, updated_id_display_desc);
					UpsertDescription(a_id_lang, a_nm_display_name, old_id_display_name, updated_id_display_name);
					UPDATE t_base_props
					SET n_name = id_name, n_desc = updated_id_display_desc, n_display_name = updated_id_display_name,
							nm_name = a_nm_name, nm_desc = a_nm_desc, nm_display_name = a_nm_display_name
					WHERE id_prop = a_id_prop;
				END;
/

CREATE OR REPLACE PROCEDURE UpdateCounterPropDef(
        id_lang_code int,
        temp_id_prop int,
        nm_name nvarchar2,
        nm_display_name nvarchar2,
        id_pi int,
        nm_servicedefprop nvarchar2,
        nm_preferredcountertype nvarchar2,
        n_order int)
      AS
        identity_value int;
        id_locale int;
        id_dummy int;
		updated_id_display_name int;
		updated_id_display_desc int;
      BEGIN
		UpdateBaseProps(temp_id_prop, id_lang_code, nm_name, NULL, nm_display_name, updated_id_display_name, updated_id_display_desc);
        UPDATE t_counterpropdef
		SET nm_servicedefprop = nm_servicedefprop,
		n_order = n_order,
		nm_preferredcountertype = nm_preferredcountertype
		WHERE id_prop = temp_id_prop;
      END;
/

CREATE OR REPLACE procedure CanExecuteEventDeps (
   p_dt_now               date,
   p_id_instances         varchar2,
   lang_code              int,
   p_result         out   sys_refcursor
)
as
   exec_deps   int;
begin

   delete from	tmp_deps;
   exec_deps := dbo.GetEventExecutionDeps(p_dt_now, p_id_instances);                                                            /*  */

  open p_result for
    select
      orig_evt.tx_name OriginalEventName,
      orig_evt.tx_display_name OriginalEventDisplayName,
      COALESCE(loc.tx_name, evt.tx_display_name) EventDisplayName,
      evt.tx_type EventType,
      deps.OriginalInstanceID,
      deps.EventID,
      deps.EventName,
      deps.InstanceID,
      deps.ArgIntervalID,
      deps.ArgStartDate,
      deps.ArgEndDate,
      deps.Status,
      /*  the corrective action that must occur */
      CASE deps.Status WHEN 'NotYetRun' THEN 'Execute'
                       WHEN 'Failed' THEN 'Reverse'
                       WHEN 'ReadyToRun' THEN 'Cancel'
                       WHEN 'Reversing' THEN 'TryAgainLater'
                       ELSE 'Unknown' END AS Action,
      nvl(deps.BillGroupName, N'Not Available') BillGroupName
    FROM
    (
      SELECT
        MIN(deps_inner.id_orig_instance) OriginalInstanceID,
        deps_inner.id_event EventID,
        deps_inner.tx_name EventName,
        deps_inner.id_instance InstanceID,
        deps_inner.id_arg_interval ArgIntervalID,
        deps_inner.dt_arg_start ArgStartDate,
        deps_inner.dt_arg_end ArgEndDate,
        deps_inner.tx_status Status,
        bg.tx_name as BillGroupName
      FROM  tmp_deps deps_inner
          /* table(exec_deps) deps_inner */
      LEFT OUTER JOIN t_billgroup bg
        ON bg.id_billgroup = deps_inner.id_billgroup
      WHERE
        /* excludes input instances */
        (deps_inner.id_instance NOT IN ( select column_value
                      from table(dbo.csvtoint(p_id_instances)))
            OR deps_inner.id_instance IS NULL) AND
        /* only look at deps that need an action to be taken */
        deps_inner.tx_status NOT IN ('Succeeded', 'ReadyToRun', 'Running')
      GROUP BY
        deps_inner.id_instance,
        deps_inner.id_event,
        deps_inner.tx_name,
        deps_inner.id_arg_interval,
        deps_inner.dt_arg_start,
        deps_inner.dt_arg_end,
        deps_inner.tx_status,
        bg.tx_name
    ) deps
    INNER JOIN t_recevent evt ON evt.id_event = deps.EventID
    INNER JOIN t_recevent_inst orig_inst
      ON orig_inst.id_instance = deps.OriginalInstanceID
    INNER JOIN t_recevent orig_evt ON orig_evt.id_event = orig_inst.id_event
    LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = lang_code AND evt.id_event=loc.id_item);

end CanExecuteEventDeps;
/

CREATE OR REPLACE PROCEDURE checkgroupsubbusinessrules (
   p_name                       IN       NVARCHAR2,
   p_desc                       IN       NVARCHAR2,
   p_startdate                  IN       DATE,
   p_enddate                    IN       DATE,
   p_id_po                      IN       INTEGER,
   p_proportional               IN       VARCHAR2,
   p_discountaccount            IN       INTEGER,
   p_corporateaccount           IN       INTEGER,
   p_existingid                 IN       INTEGER,
   p_id_usage_cycle             IN       INTEGER,
   p_systemdate                 IN       DATE,
   p_enforce_same_corporation            VARCHAR2,
   p_allow_acc_po_curr_mismatch IN       INTEGER DEFAULT 0,
   p_status                     OUT      INTEGER
)
AS
   existingpo             INTEGER;
   constrainedcycletype   INTEGER;
   groupsubcycletype      INTEGER;
   corporatestartdate     DATE;
   var_condn              NUMBER  := 0;
   var_p_enddate          DATE    := p_enddate;
BEGIN
   p_status := 0; /* verify that the corporate account and the product offering have the same currency.*/

   IF (p_enforce_same_corporation = '1')
   THEN
      IF (dbo.isaccountandposamecurrency (p_corporateaccount, p_id_po) = '0'
         )
      THEN /* MT_ACCOUNT_PO_CURRENCY_MISMATCH*/
         if (p_allow_acc_po_curr_mismatch <> 0) THEN
        		p_status := 1;
	       else
            p_status := -486604729;
            RETURN;
         END IF;
      END IF;
   END IF; /* verify that the discount account, if not null has the same currency as the po.*/

   IF (p_enforce_same_corporation = '0' AND p_discountaccount IS NOT NULL)
   THEN
      IF (dbo.isaccountandposamecurrency (p_discountaccount, p_id_po) = '0')
      THEN /* MT_ACCOUNT_PO_CURRENCY_MISMATCH*/
         p_status := -486604729;
         RETURN;
      END IF;
   END IF;

   IF var_p_enddate IS NULL
   THEN
      var_p_enddate := dbo.mtmaxdate;
   END IF; /* verify that the product offering exists and the effective date is kosher*/

   IF p_proportional = 'N'
   THEN
      IF p_discountaccount IS NULL AND dbo.pocontainsdiscount (p_id_po) = 1
      THEN /* MT_GROUP_SUB_DISCOUNT_ACCOUNT_REQUIRED*/
         p_status := -486604787;
         RETURN;
      END IF;
   END IF; /* verify that the account is actually a corporate account*/

   IF p_enforce_same_corporation = '1'
   THEN
      SELECT COUNT (1)
        INTO var_condn
        FROM DUAL
       WHERE NOT EXISTS (
                SELECT 1
                  FROM t_account_ancestor aa INNER JOIN t_account a ON a.id_acc =
                                                                         aa.id_descendent
                       INNER JOIN t_account_type AT ON AT.id_type = a.id_type
                 WHERE AT.b_iscorporate = '1'
                   AND aa.id_descendent = p_corporateaccount
                   AND aa.vt_start <= p_startdate
                   AND aa.vt_end >= p_startdate)
          OR NOT EXISTS (
                SELECT 1
                  FROM t_account_ancestor aa INNER JOIN t_account a ON a.id_acc =
                                                                         aa.id_descendent
                       INNER JOIN t_account_type AT ON AT.id_type = a.id_type
                 WHERE AT.b_iscorporate = '1'
                   AND aa.id_descendent = p_corporateaccount
                   AND aa.vt_start <= var_p_enddate
                   /* AND aa.vt_end >= var_p_enddate */
                   )
          OR EXISTS (
                SELECT 1 /* This finds a record that ends during the                interval...*/
                  FROM t_account_ancestor aa INNER JOIN t_account a ON a.id_acc =
                                                                         aa.id_descendent
                       INNER JOIN t_account_type AT ON AT.id_type = a.id_type
                 WHERE AT.b_iscorporate = '1'
                   AND aa.id_descendent = p_corporateaccount
                   AND p_startdate <= aa.vt_end
                   AND aa.vt_end <
                          var_p_enddate /* ... and there is not corp. account record that extends                its validity.*/
                   AND NOT EXISTS (
                          SELECT 1
                            FROM t_account_ancestor aa2 INNER JOIN t_account a ON a.id_acc =
                                                                                    aa2.id_descendent
                                 INNER JOIN t_account_type AT ON AT.id_type =
                                                                     a.id_type
                           WHERE AT.b_iscorporate = '1'
                             AND aa2.vt_start <=
                                              aa.vt_end
                                              + (1 / (24 * 60 * 60))
                             /* AND aa2.vt_end > aa.vt_end */
                             ));

      IF var_condn <> 0
      THEN
      
        DECLARE
          v_accStart  DATE;
          v_accEnd    DATE;
        BEGIN
          SELECT vt_start, vt_end
          INTO v_accStart, v_accEnd
          FROM t_account_ancestor
          WHERE id_descendent = p_corporateaccount AND num_generations = 0
                AND ROWNUM <= 1;
          
          IF p_startdate < v_accStart THEN
            /* MT_GROUP_SUB_STARTS_BEFORE_ACCOUNT*/
            p_status := -486604710;
            RETURN;
          END IF;
          
          IF var_p_enddate > v_accEnd THEN
            /* MT_GROUP_SUB_ENDS_AFTER_ACCOUNT*/
            p_status := -486604709;
            RETURN;
          END IF;
        END;
      
        /* MT_GROUP_SUB_CORPORATE_ACCOUNT_INVALID*/
        p_status := -486604786;
        RETURN;
      END IF;
   END IF; /* make sure start date is before end date   MT_GROUPSUB_STARTDATE_AFTER_ENDDATE*/

   IF var_p_enddate IS NOT NULL
   THEN
      IF p_startdate > var_p_enddate
      THEN
         p_status := -486604782;
         RETURN;
      END IF;
   END IF; /* verify that the group subscription name does not conflict with an existing    group subscription, based on group sub name and corporate account     MT_GROUP_SUB_NAME_EXISTS -486604784*/

   p_status := 0;

   FOR i IN (SELECT id_group
               FROM t_group_sub
              WHERE p_name = tx_name
                AND (p_existingid <> id_group OR p_existingid IS NULL))
   LOOP
      p_status := i.id_group;
   END LOOP;

   IF p_status <> 0
   THEN
      p_status := -486604784;
      RETURN;
   END IF; /* verify that the usage cycle type matched that of the      product offering*/

   FOR i IN (SELECT dbo.poconstrainedcycletype (p_id_po) p_id_po, id_cycle_type
               INTO constrainedcycletype, groupsubcycletype
               FROM t_usage_cycle
              WHERE id_usage_cycle = p_id_usage_cycle)
   LOOP
      constrainedcycletype := i.p_id_po;
      groupsubcycletype := i.id_cycle_type;
   END LOOP;

   IF constrainedcycletype > 0 AND constrainedcycletype <> groupsubcycletype
   THEN /* MT_GROUP_SUB_CYCLE_TYPE_MISMATCH*/
      p_status := -486604762;
      RETURN;
   END IF; /* check that the discount account has in its ancestory tree      the corporate account*/

   IF p_enforce_same_corporation = '1' AND p_discountaccount IS NOT NULL
   THEN
      SELECT MAX (id_ancestor)
        INTO p_status
        FROM t_account_ancestor
       WHERE id_descendent = p_discountaccount
         AND id_ancestor = p_corporateaccount;

      IF p_status IS NULL
      THEN /* MT_DISCOUNT_ACCOUNT_MUST_BE_IN_CORPORATE_HIERARCHY*/
         p_status := -486604760;
         RETURN;
      END IF;
   END IF; /* make sure the start date is after the start date of the corporate account*/

   IF (p_enforce_same_corporation = '1')
   THEN
      FOR i IN (SELECT dbo.mtstartofday (dt_crt) dt_crt
                  FROM t_account
                 WHERE id_acc = p_corporateaccount)
      LOOP
         corporatestartdate := i.dt_crt;
      END LOOP;

      IF corporatestartdate > p_startdate
      THEN /* MT_CANNOT_CREATE_GROUPSUB_BEFORE_CORPORATE_START_DATE*/
         p_status := -486604747;
         RETURN;
      END IF;
   END IF;

   p_status := 1;
END;
/

CREATE OR REPLACE procedure InsertBaseProps(
				id_lang_code int,
				a_kind t_base_props.n_kind%type,
				a_approved t_base_props.b_approved%type,
        a_archive t_base_props.b_archive%type,
        a_nm_name t_base_props.nm_name%type,
        a_nm_desc t_base_props.nm_desc%type,
        a_nm_display_name t_base_props.nm_display_name%type,
        a_id_prop out int,
		id_display_name out int,
		id_display_desc out int)
				as
        id_name t_base_props.n_name%type;
				begin
					UpsertDescription(id_lang_code, a_nm_display_name, NULL, id_display_name) ;
					UpsertDescription(id_lang_code, a_nm_name, NULL, id_name) ;
					UpsertDescription(id_lang_code, a_nm_desc, NULL, id_display_desc) ;
					insert into t_base_props (id_prop, n_kind, n_name, n_desc,nm_name,nm_desc,b_approved,b_archive,
					n_display_name, nm_display_name) values
					(seq_t_base_props.nextval, a_kind, id_name, id_display_desc, a_nm_name,a_nm_desc,a_approved,a_archive,
					id_display_name,a_nm_display_name);
					select seq_t_base_props.currval into a_id_prop from dual;
				end;
/

CREATE OR REPLACE procedure AddCounterParamType
          (id_lang_code int,
		   temp_n_kind int,
          nm_name nvarchar2,
          id_counter_type t_counter_params_metadata.id_counter_meta%type,
          nm_param_type t_counter_params_metadata.paramtype%type,
          nm_param_dbtype t_counter_params_metadata.DBtype%type,
          id_prop OUT int)
      as
				identity_value t_counter_params_metadata.id_prop%type;
				id_display_name int;
				id_display_desc int;
      BEGIN
				InsertBaseProps(id_lang_code, temp_n_kind, 'N', 'N', nm_name, NULL, NULL, identity_value, id_display_name, id_display_desc);

				INSERT INTO t_counter_params_metadata
					(id_prop, id_counter_meta, ParamType, DBType)
				VALUES
					(identity_value, id_counter_type, nm_param_type, nm_param_dbtype);
		        id_prop := identity_value;
			END;
/

CREATE OR REPLACE PROCEDURE AddApproval(
    SubmittedDate DATE,
    SubmitterId NUMBER,
    ChangeType  VARCHAR2,
    ChangeDetails BLOB,
    ItemDisplayName             VARCHAR2 DEFAULT '',
    UniqueItemId                VARCHAR2,
    user_comment                VARCHAR2 DEFAULT '',
    CurrentState                VARCHAR,
    PartitionId                 NUMBER DEFAULT 1,
    AllowMultiplePendingChanges NUMBER,
    IdApproval OUT INT,
    Status OUT INT )
AS
  PendingChangeCount INT;
  SQLError           INT;
BEGIN
  IF (AllowMultiplePendingChanges <> 1) THEN
    BEGIN
      SELECT COUNT(*) INTO PendingChangeCount FROM t_approvals
      WHERE
        c_changetype                 = ChangeType
      AND c_UniqueItemId             = UniqueItemId
      AND c_CurrentState             = 'Pending';
      IF (NVL(PendingChangeCount,0) <> 0) THEN
        BEGIN
          IdApproval := 0 ;
          Status     := -1;
          /* Multiple pending changes are not allowed for this change type */
          RETURN;
        END ;
      END IF;
    END;
  END IF;
  INSERT INTO t_approvals (id_approval, c_SubmittedDate, c_SubmitterId, c_ChangeType, c_ChangeDetails, c_ApproverId, c_ChangeLastModifiedDate,
        c_ItemDisplayName, c_UniqueItemId, c_Comment, c_CurrentState, c_PartitionId)
      VALUES
      (SEQ_T_APPROVAL.NextVal, SubmittedDate, SubmitterId, ChangeType, ChangeDetails, NULL, NULL, ItemDisplayName,
        UniqueItemId, user_comment, CurrentState, PartitionId);
  SQLError    := SQLCODE;
  IF SQLError <> 0 THEN
    BEGIN
      Status := -1;
      RETURN;
    END;
  ELSE
    BEGIN
      Status := 0;
      SELECT SEQ_T_APPROVAL.CURRVAL INTO IdApproval FROM dual;
    END;
  END IF;
END;
/

CREATE OR REPLACE PROCEDURE CANREVERSEEVENTS(dt_now DATE, id_instances VARCHAR2, lang_code int, RES OUT SYS_REFCURSOR)
AS
BEGIN
  /*  */
  /* initially all instances are considered okay */
  /* a succession of queries attempt to find a reason */
  /* why an instance can not be reversed */

  /* builds up a table from the comma separated list of instance IDs */
  execute immediate 'truncate table t_CanExecuteEventsTempTbl';

  INSERT INTO t_CanExecuteEventsTempTbl
  SELECT
    args.column_value,
    COALESCE(loc.tx_name, evt.tx_display_name) tx_display_name,
    'OK'
  FROM table(cast(dbo.CSVToInt(CANREVERSEEVENTS.id_instances)as  tab_id_instance)) args
  INNER JOIN t_recevent_inst inst ON inst.id_instance = args.column_value
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = lang_code AND evt.id_event=loc.id_item);
  /* is the event not active */
  UPDATE t_CanExecuteEventsTempTbl results SET tx_reason = 'EventNotActive'
  where exists (
  SELECT 'X'
  FROM t_recevent_inst inst ,t_recevent evt
  WHERE
  inst.id_instance = results.id_instance and
  evt.id_event = inst.id_event and
    /* event is NOT active */
    evt.dt_activated > CANREVERSEEVENTS.dt_now AND
    (evt.dt_deactivated IS NOT NULL OR CANREVERSEEVENTS.dt_now >= evt.dt_deactivated)
    );
    
  /* is the event not reversible */
  FOR data in (select results.rowid as "rowid", evt.tx_reverse_mode as tx_reverse_mode FROM t_CanExecuteEventsTempTbl results
              INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance
              INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
              WHERE
            /* event is NOT reversible */
            evt.tx_reverse_mode = 'NotImplemented'
            )
  loop
      UPDATE t_CanExecuteEventsTempTbl SET tx_reason = data.tx_reverse_mode
      where rowid = data."rowid";
  end loop;
  
  
  
  /* is the instance in an invalid state */
  for data in (select results.rowid as "rowid", inst.tx_status as tx_status FROM t_CanExecuteEventsTempTbl results
              INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance
              WHERE
              inst.tx_status NOT IN ('ReadyToReverse', 'Succeeded', 'Failed')
              )
  loop
  UPDATE t_CanExecuteEventsTempTbl SET tx_reason = data.tx_status
  where rowid = data."rowid";
  end loop;
  
  
  
  /* is the interval hard closed */
  UPDATE t_CanExecuteEventsTempTbl results SET tx_reason = 'HardClosed'
  WHERE EXISTS (
  SELECT 'X'
  FROM t_recevent_inst inst,t_usage_interval ui
  WHERE
  inst.id_instance = results.id_instance AND
  ui.id_interval = inst.id_arg_interval AND
    ui.tx_interval_status = 'H');

  OPEN RES FOR
  SELECT
    id_instance InstanceID,
    tx_display_name EventDisplayName,
    tx_reason Reason
  FROM t_CanExecuteEventsTempTbl;
  COMMIT;
END;
/

CREATE OR REPLACE procedure CanReverseEventDeps (
   p_dt_now               date,
   p_id_instances         varchar2,
   lang_code              int,
   p_result         out   sys_refcursor
)
as
   exec_deps   int;
begin

   delete from tmp_deps;
   exec_deps := dbo.GetEventReversalDeps(p_dt_now, p_id_instances);                                                            /*  */

  open p_result for
      SELECT
        orig_evt.tx_name OriginalEventName,
        orig_evt.tx_display_name OriginalEventDisplayName,
        COALESCE(loc.tx_name, evt.tx_display_name) EventDisplayName,
        evt.tx_type EventType,
        evt.tx_reverse_mode ReverseMode,
        deps.OriginalInstanceID,
        deps.EventID,
        deps.EventName,
        deps.InstanceID,
        deps.ArgIntervalID,
        deps.ArgStartDate,
        deps.ArgEndDate,
        deps.Status,
        /* the corrective action that must occur */
        CASE deps.Status WHEN 'Succeeded' THEN 'Reverse'
                        WHEN 'Failed' THEN 'Reverse'
                        WHEN 'ReadyToRun' THEN 'Cancel'
                        WHEN 'Running' THEN 'TryAgainLater'
                        ELSE 'Unknown' END Action,
        nvl(deps.BillGroupName, 'Not Available') BillGroupName
      FROM
      (
        SELECT
          MIN(deps.id_orig_instance) OriginalInstanceID,
          deps.id_event EventID,
          deps.tx_name EventName,
          deps.id_instance InstanceID,
          deps.id_arg_interval ArgIntervalID,
          deps.dt_arg_start ArgStartDate,
          deps.dt_arg_end ArgEndDate,
          deps.tx_status Status,
          bg.tx_name BillGroupName
        FROM tmp_deps deps
        LEFT OUTER JOIN t_billgroup bg ON bg.id_billgroup = deps.id_billgroup
        WHERE
          /* excludes input instances */
          (deps.id_instance NOT IN (select column_value
                      from table(dbo.csvtoint(p_id_instances)))
               OR deps.id_instance IS NULL) AND
          /* only look at deps that need an action to be taken */
          deps.tx_status NOT IN ('NotYetRun', 'ReadyToReverse', 'Reversing')
        GROUP BY
          deps.id_instance,
          deps.id_event,
          deps.tx_name,
          deps.id_arg_interval,
          deps.dt_arg_start,
          deps.dt_arg_end,
          deps.tx_status,
          bg.tx_name
      ) deps
      INNER JOIN t_recevent evt ON evt.id_event = deps.EventID
      INNER JOIN t_recevent_inst orig_inst ON orig_inst.id_instance = deps.OriginalInstanceID
      INNER JOIN t_recevent orig_evt ON orig_evt.id_event = orig_inst.id_event
      LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = lang_code AND evt.id_event=loc.id_item);

end CanReverseEventDeps;
/

CREATE OR REPLACE PROCEDURE subscribebatchgroupsub (
   tmp_subscribe_batch_tmp           NVARCHAR2,
   tmp_account_state_rules_tmp       NVARCHAR2,
   corp_business_rule_enforced   NUMBER,
   dt_now                        DATE,
   p_allow_acc_po_curr_mismatch INTEGER default 0,
   p_allow_multiple_pi_sub_rcnrc INTEGER default 0
)
AS
BEGIN
   UPDATE tmp_subscribe_batch
      SET vt_end = dbo.mtmaxdate (),
          uncorrected_vt_end = dbo.mtmaxdate ()
    WHERE vt_end IS NULL; /* First clip the start and end date with the effective date on the subscription   * and validate that the intersection of the effective date on the sub and the   * delete interval is non-empty.   */

   UPDATE tmp_subscribe_batch ub
      SET (vt_start, vt_end, status, id_sub, id_po) =
             (SELECT dbo.mtmaxoftwodates (ub.vt_start,
                                          s.vt_start) AS vt_start,
                     dbo.mtminoftwodates (ub.vt_end, s.vt_end) AS vt_end,
                     CASE
                        WHEN ub.vt_start < s.vt_end
                        AND ub.vt_end > s.vt_start
                           THEN 0
                        ELSE -486604712
                     END AS status,
                     s.id_sub AS id_sub, s.id_po AS id_po
                FROM t_sub s
               WHERE s.id_group = ub.id_group)
    WHERE EXISTS (
             SELECT dbo.mtmaxoftwodates (ub.vt_start, s.vt_start) AS vt_start,
                    dbo.mtminoftwodates (ub.vt_end, s.vt_end) AS vt_end,
                    CASE
                       WHEN ub.vt_start < s.vt_end
                       AND ub.vt_end > s.vt_start
                          THEN 0
                       ELSE 1
                    END AS status,
                    s.id_sub AS id_sub, s.id_po AS id_po
               FROM t_sub s
              WHERE s.id_group = ub.id_group); /* Next piece of data massaging is to clip the start date of the request   * with the creation date of the account (provided the account was created    * before the end date of the subscription request).   */

   UPDATE tmp_subscribe_batch ub
      SET ub.vt_start =
                   (SELECT dbo.mtmaxoftwodates (ub.vt_start, acc.dt_crt)
                      FROM t_account acc
                     WHERE ub.id_acc = acc.id_acc AND acc.dt_crt <= ub.vt_end)
    WHERE EXISTS (SELECT dbo.mtmaxoftwodates (ub.vt_start, acc.dt_crt)
                    FROM t_account acc
                   WHERE ub.id_acc = acc.id_acc AND acc.dt_crt <= ub.vt_end);
   
   /* CR 13298: Eliminate duplicates   * MTPCUSER_DUPLICATE_ITEMS_IN_BATCH -289472432   */

   UPDATE tmp_subscribe_batch args
	   SET status = -289472432
	  WHERE EXISTS (SELECT 1 from
                     (SELECT id_acc,  id_group
                                  FROM tmp_subscribe_batch
                                  GROUP BY id_acc, id_group
                                  HAVING COUNT (*) > 1) args1
                       WHERE args.id_acc = args1.id_acc
                       AND args.id_group = args1.id_group
                       AND args.status = 0
                    ) ;

  /* Check that all potential group subscription members have the same currency on their profiles   * as the product offering.   * TODO: t_po table does not have an index on id_nonshared_pl.   * if below query affects performance, create it later.   */

IF p_allow_acc_po_curr_mismatch <> 1
THEN

   UPDATE tmp_subscribe_batch ub
      SET status = -486604729 /* mt_account_po_currency_mismatch */
    WHERE EXISTS (
             SELECT 1
               FROM t_po po,
                    t_payment_redirection pr,
                    t_av_internal tav,
                    t_pricelist pl1
              WHERE
                (pr.vt_start <= ub.vt_end AND pr.vt_end >= ub.vt_start)
                AND tav.id_acc = pr.id_payer
                AND pr.id_payee = ub.id_acc
                AND ub.id_po = po.id_po
                AND pl1.id_pricelist = po.id_nonshared_pl
                AND tav.c_currency <> pl1.nm_currency_code
                AND ub.status = 0);
END IF;
                                    /* subscription request.  I don't want to create a new error message for   * this corner case (porting back to 3.0 for BT); so borrow account state   * message.   * MT_ADD_TO_GROUP_SUB_BAD_STATE   */

   UPDATE tmp_subscribe_batch ub
      SET status = -486604774
    WHERE EXISTS (
             SELECT 1
               FROM t_account acc
              WHERE ub.id_acc = acc.id_acc
                AND acc.dt_crt > ub.vt_end
                AND ub.status = 0); /* Check to see if the account is in a state in which we can   * subscribe it.   * TODO: This is the business rule as implemented in 3.5 and 3.0 (check only   * the account state in effect at the wall clock time that the subscription is made).   * What would be better is to ensure that there is no overlap between   * the valid time interval of any "invalid" account state and the subscription   * interval.     * MT_ADD_TO_GROUP_SUB_BAD_STATE   */

   UPDATE tmp_subscribe_batch ar
      SET status = -486604774
    WHERE EXISTS (
             SELECT 1
               FROM t_account_state ast INNER JOIN tmp_account_state_rules asr ON ast.status =
                                                                                          asr.state
              WHERE asr.can_subscribe = 0
                AND ar.status = 0
                AND ar.id_acc = ast.id_acc
                AND ast.vt_start <= ar.tt_now
                AND ast.vt_end >= ar.tt_now);
        /* Check that we're not already in the group sub with overlapping date
* MT_ACCOUNT_ALREADY_IN_GROUP_SUBSCRIPTION
*/

   UPDATE tmp_subscribe_batch ar
      SET status = -486604790
    WHERE EXISTS (
             SELECT 1
               FROM t_gsubmember s
              WHERE s.id_acc = ar.id_acc
                AND s.id_group = ar.id_group
                AND s.vt_start <= ar.vt_end
                AND ar.vt_start <= s.vt_end
                AND ar.status = 0);

   /* Check for different subscription to the same PO by the same account with overlapping date
   */
   UPDATE tmp_subscribe_batch ar
      SET status = -289472485
    WHERE EXISTS (
             /* Check for conflicting individual sub */
             SELECT 1
               FROM t_sub s
              WHERE s.id_po = ar.id_po
                AND s.id_acc = ar.id_acc
                AND s.id_sub <> ar.id_sub
                AND s.vt_start <= ar.vt_end
                AND ar.vt_start <= s.vt_end
                AND s.id_group IS NULL)
       OR     EXISTS (
                 /* Check for conflicting group sub */
                 SELECT 1
                   FROM t_gsubmember gs INNER JOIN t_sub s ON gs.id_group =
                                                                    s.id_group
                  WHERE gs.id_acc = ar.id_acc
                    AND s.id_po = ar.id_po
                    AND s.id_sub <> ar.id_sub
                    AND gs.vt_start <= ar.vt_end
                    AND ar.vt_start <= gs.vt_end)
          AND ar.status = 0;

   /* Check to make sure that effective date of PO intersects the corrected interval
    */
   UPDATE tmp_subscribe_batch ar
      SET status = -289472472
    WHERE EXISTS (
             SELECT 1
               FROM t_po p INNER JOIN t_effectivedate ed ON ed.id_eff_date =
                                                                 p.id_eff_date
              WHERE ar.id_po = p.id_po
                AND (ed.dt_start > ar.vt_start OR ed.dt_end < ar.vt_end)
                AND ar.status = 0);

   /* Check to see if there is another PO with the same PI template for which an overlapping subscription exists.
    * Only do this if other business rules have passed.
    */
   UPDATE tmp_subscribe_batch sb
      SET status = -289472484
    WHERE EXISTS (
             SELECT 1
               FROM t_pl_map plm1, t_vw_effective_subs s2, t_pl_map plm2
              WHERE sb.id_po = plm1.id_po
                AND s2.id_po = plm2.id_po
                AND plm1.id_pi_template = plm2.id_pi_template
                AND s2.id_acc = sb.id_acc
                AND s2.id_po <> sb.id_po
                AND s2.dt_start < sb.vt_end
                AND plm1.id_paramtable IS NULL
                AND plm2.id_paramtable IS NULL
                AND sb.vt_start < s2.dt_end
                AND sb.status = 0);

   /* MT_GSUB_DATERANGE_NOT_IN_SUB_RANGE
    */
   UPDATE tmp_subscribe_batch ar
      SET status = -486604789
    WHERE EXISTS (
             SELECT 1
               FROM t_sub s
              WHERE s.id_group = ar.id_group
                AND (ar.vt_start < s.vt_start OR ar.vt_end > s.vt_end)
                AND ar.status = 0);

   /* Check that the group subscription exists
    * MT_GROUP_SUBSCRIPTION_DOES_NOT_EXIST
    */
   UPDATE tmp_subscribe_batch ar
      SET status = -486604788
    WHERE NOT EXISTS (SELECT 1
                        FROM t_group_sub
                       WHERE t_group_sub.id_group = ar.id_group)
      AND ar.status = 0;

   /* If corp account business rule is enforced, check that
    * all potential gsub members are located in the same corporate hierarchy
    * as group subscription
    * bug fix 13689 corporate account need not be under root.
    * MT_ACCOUNT_NOT_IN_GSUB_CORPORATE_ACCOUNT
    */
   IF (corp_business_rule_enforced = 1)
   THEN
      UPDATE tmp_subscribe_batch ar
         SET status = -486604769
       WHERE EXISTS (
                SELECT 1
                  FROM t_group_sub gs,
                       t_account_ancestor aa,
                       t_account acc,
                       t_account_type atype
                 WHERE ar.id_group = gs.id_group
                   AND atype.id_type = acc.id_type
                   AND aa.id_ancestor = acc.id_acc
                   AND aa.id_descendent = ar.id_acc
                   AND aa.vt_start <= ar.tt_now
                   AND ar.tt_now <= aa.vt_end
                   AND atype.b_iscorporate = '1'
                   AND aa.num_generations = 0
                   AND aa.id_ancestor <> gs.id_corporate_account
                   AND ar.status = 0);
   END IF;

   /* MT_GROUP_SUB_MEMBER_CYCLE_MISMATCH
    * Check for billing cycle relative
    */
   UPDATE tmp_subscribe_batch ar
      SET status = -486604730
    WHERE EXISTS (
             SELECT 1
               FROM t_sub s, t_group_sub gs
              WHERE s.vt_end >= ar.tt_now
                AND ar.id_group = gs.id_group
                AND ar.id_group = s.id_group
                AND (
                        /* Only consider this business rule when the target PO
                         * has a billing cycle relative instance
                         */
                        EXISTS (
                           SELECT 1
                             FROM t_pl_map plm JOIN t_discount piinst ON piinst.id_prop =
                                                                           plm.id_pi_instance
                            WHERE plm.id_po = s.id_po
                              AND plm.id_paramtable IS NULL
                              AND piinst.id_usage_cycle IS NULL)
                     OR EXISTS (
                           SELECT 1
                             FROM t_pl_map plm JOIN t_recur piinst ON piinst.id_prop =
                                                                        plm.id_pi_instance
                            WHERE plm.id_po = s.id_po
                              AND plm.id_paramtable IS NULL
                              AND piinst.tx_cycle_mode IN
                                                   ('BCR', 'BCR Constrained'))
                     OR EXISTS (
                           SELECT 1
                             FROM t_pl_map plm JOIN t_aggregate piinst ON piinst.id_prop =
                                                                            plm.id_pi_instance
                            WHERE plm.id_po = s.id_po
                              AND plm.id_paramtable IS NULL
                              AND piinst.id_usage_cycle IS NULL)
                    )
                AND EXISTS (
                       /* All payers must have the same cycle as the cycle as the group sub itself
                        */
                       SELECT 1
                         FROM t_payment_redirection pr JOIN t_acc_usage_cycle auc ON auc.id_acc =
                                                                                       pr.id_payer
                        WHERE pr.id_payee = ar.id_acc
                          AND pr.vt_start <= s.vt_end
                          AND s.vt_start <= pr.vt_end
                          AND auc.id_usage_cycle <> gs.id_usage_cycle)
                AND ar.status = 0);

   /* fills the results table with a row for each member/payer combination
    */
   INSERT INTO ebcrresults
      SELECT batch.id_acc, payercycle.id_usage_cycle,
             dbo.checkebcrcycletypecompatible (payercycle.id_cycle_type,
                                               rc.id_cycle_type
                                              )
        FROM tmp_subscribe_batch batch INNER JOIN t_group_sub gs ON gs.id_group =
                                                                            batch.id_group
             INNER JOIN t_sub sub ON sub.id_group = gs.id_group
             INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po
             INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
             INNER JOIN t_payment_redirection pay ON pay.id_payee =
                                                                  batch.id_acc
                                                AND
                                                    /* checks all payer's who overlap with the group sub */
                                                    pay.vt_end >= sub.vt_start
                                                AND pay.vt_start <= sub.vt_end
             INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = pay.id_payer
             INNER JOIN t_usage_cycle payercycle ON payercycle.id_usage_cycle =
                                                            auc.id_usage_cycle
       WHERE rc.tx_cycle_mode = 'EBCR'
         AND rc.b_charge_per_participant = 'Y'
         AND plmap.id_paramtable IS NULL
         AND                                                                                                                                                                                                                                                                                                                                                                                                    /* todo: it would be better if we didn't consider subscriptions that ended
             * in a hard closed interval so that retroactive changes would be properly guarded.
             * only consider current or future group subs
             * don't worry about group subs in the past    */ (   (dt_now
                                                                      BETWEEN sub.vt_start
                                                                          AND sub.vt_end
                                                                  )
                                                               OR (sub.vt_start >
                                                                        dt_now
                                                                  )
                                                              )
         AND batch.status = 0;
        /* checks that members' payers are compatible with the EBCR cycle type
*/

   UPDATE tmp_subscribe_batch batch
      SET status =
             -289472443
                      /* mtpcuser_ebcr_cycle_conflicts_with_payer_of_member */
    WHERE EXISTS (SELECT 1
                    FROM ebcrresults res
                   WHERE res.id_acc = batch.id_acc AND res.b_compatible = 0);

   /* checks that each member has only one billing cycle across all payers
    */
   UPDATE tmp_subscribe_batch batch
      SET status =
                -289472442
                          /* mtpcuser_ebcr_members_conflict_with_each_other */
    WHERE EXISTS (
             SELECT 1
               FROM ebcrresults res INNER JOIN ebcrresults res2 ON res2.id_acc =
                                                                     res.id_acc
                                                              AND res2.b_compatible =
                                                                     res.b_compatible
                                                              AND res2.id_usage_cycle <>
                                                                     res.id_usage_cycle
              WHERE res.id_acc = batch.id_acc
                AND res.b_compatible = 1
                AND batch.status = 0);

   /* check that account type of each member is compatible with the product offering
    * since the absense of ANY mappings for the product offering means that PO is "wide open"
    * we need to do 2 EXISTS queries.
    */
   UPDATE tmp_subscribe_batch ar
      SET status = -289472435       /* mtpcuser_conflicting_po_account_type */
    WHERE (    EXISTS (SELECT 1
                         FROM t_po_account_type_map atmap
                        WHERE atmap.id_po = ar.id_po)
           /* PO is not wide open - see if susbcription is permitted for the account type
            */
           AND NOT EXISTS (
                      SELECT 1
                        FROM t_account tacc INNER JOIN t_po_account_type_map atmap ON atmap.id_account_type =
                                                                                        tacc.id_type
                       WHERE atmap.id_po = ar.id_po
                             AND ar.id_acc = tacc.id_acc)
          )
      AND status = 0;

   /* Check MTPCUSER_ACCOUNT_TYPE_CANNOT_PARTICIPATE_IN_GSUB 0xEEBF004FL -289472433
    */
   UPDATE tmp_subscribe_batch ar
      SET status = -289472433
    WHERE EXISTS (
             SELECT 1
               FROM t_account acc INNER JOIN t_account_type acctype ON acc.id_type =
                                                                         acctype.id_type
              WHERE ar.id_acc = acc.id_acc
                AND acctype.b_canparticipateingsub = '0'
                AND status = 0);

   /* This is a sequenced insert.  For sequenced updates/upsert, run the delete (unsubscribe) first.
    */
   INSERT INTO t_gsubmember_historical
               (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
      SELECT ar.id_group, ar.id_acc, ar.vt_start, ar.vt_end, ar.tt_now,
             dbo.mtmaxdate ()
        FROM tmp_subscribe_batch ar
       WHERE ar.status = 0;

   INSERT INTO t_gsubmember
               (id_group, id_acc, vt_start, vt_end)
      SELECT ar.id_group, ar.id_acc, ar.vt_start, ar.vt_end
        FROM tmp_subscribe_batch ar
       WHERE ar.status = 0;

   /* Coalecse to merge abutting records
    * Implement coalescing to merge any gsubmember records to the
    * same subscription that are adjacent.  Still need to work on
    * what a bitemporal coalesce looks like.
    */
   LOOP
      UPDATE t_gsubmember gsm
         SET vt_end =
                (SELECT MAX (aa2.vt_end) AS maxend
                   FROM t_gsubmember aa2
                  WHERE gsm.id_group = aa2.id_group
                    AND gsm.id_acc = aa2.id_acc
                    AND gsm.vt_start < aa2.vt_start
                    AND gsm.vt_end + NUMTODSINTERVAL (1, 'second') >=
                                                                  aa2.vt_start
                    AND gsm.vt_end < aa2.vt_end)
       WHERE EXISTS (
                SELECT 1
                  FROM t_gsubmember aa2
                 WHERE gsm.id_group = aa2.id_group
                   AND gsm.id_acc = aa2.id_acc
                   AND gsm.vt_start < aa2.vt_start
                   AND gsm.vt_end + NUMTODSINTERVAL (1, 'second') >=
                                                                  aa2.vt_start
                   AND gsm.vt_end < aa2.vt_end)
         AND EXISTS (
                   SELECT 1
                     FROM tmp_subscribe_batch ar
                    WHERE ar.id_group = gsm.id_group
                          AND ar.id_acc = gsm.id_acc);

      EXIT WHEN SQL%ROWCOUNT <= 0;
   END LOOP;

   DELETE FROM t_gsubmember
         WHERE EXISTS (
                  SELECT 1
                    FROM t_gsubmember aa2
                   WHERE t_gsubmember.id_group = aa2.id_group
                     AND t_gsubmember.id_acc = aa2.id_acc
                     AND (   (    aa2.vt_start < t_gsubmember.vt_start
                              AND t_gsubmember.vt_end <= aa2.vt_end
                             )
                          OR (    aa2.vt_start <= t_gsubmember.vt_start
                              AND t_gsubmember.vt_end < aa2.vt_end
                             )
                         ))
           AND EXISTS (
                  SELECT 1
                    FROM tmp_subscribe_batch ar
                   WHERE ar.id_group = t_gsubmember.id_group
                     AND ar.id_acc = t_gsubmember.id_acc);

   /* Here is another approach.
    * Select a record that can be extended in valid time direction.
    * Issue an update statement to extend the vt_end and to set the
    * [tt_start, tt_end] to be the intersection of the original records
    * transaction time interval and the transaction time interval of the
    * extender.
    * Issue an insert statement to create 0,1 or 2 records that have the
    * same valid time interval as the original record but that have a new
    * tt_end or tt_start in the case that their associated tt_start or tt_end
    * extends beyond that of the extending record.
    *
    *  --------
    *  |      |
    *  |      |
    *  |   ---------
    *  |   |  |    |
    *  |   |  |    |
    *  |   |  |    |
    *  --------    |
    *      |       |
    *      |       |
    *      ---------
    */
   LOOP
      INSERT INTO tmp_coalesce_args
                  (id_group, id_acc, vt_start, vt_end, tt_start, tt_end,
                   update_tt_start, update_tt_end, update_vt_end)
         SELECT   gsm.id_group, gsm.id_acc, gsm.vt_start, gsm.vt_end,
                  gsm.tt_start, gsm.tt_end,
                  dbo.mtmaxoftwodates (gsm.tt_start,
                                       gsm2.tt_start
                                      ) AS update_tt_start,
                  dbo.mtminoftwodates (gsm.tt_end,
                                       gsm2.tt_end
                                      ) AS update_tt_end,
                  MAX (gsm2.vt_end) AS update_vt_end
             FROM t_gsubmember_historical gsm INNER JOIN t_gsubmember_historical gsm2 ON gsm.id_group =
                                                                                           gsm2.id_group
                                                                                    AND gsm.id_acc =
                                                                                           gsm2.id_acc
                                                                                    AND gsm.vt_start <
                                                                                           gsm2.vt_start
                                                                                    AND gsm2.vt_start <=
                                                                                             gsm.vt_end
                                                                                           + NUMTODSINTERVAL
                                                                                                (1,
                                                                                                 'second'
                                                                                                )
                                                                                    AND gsm.vt_end <
                                                                                           gsm2.vt_end
                                                                                    AND gsm.tt_start <=
                                                                                           gsm2.tt_end
                                                                                    AND gsm2.tt_start <=
                                                                                           gsm.tt_end
            WHERE EXISTS (
                     SELECT 1
                       FROM tmp_subscribe_batch ar
                      WHERE ar.id_group = gsm.id_group
                        AND ar.id_acc = gsm.id_acc)
         GROUP BY gsm.id_group,
                  gsm.id_acc,
                  gsm.vt_start,
                  gsm.vt_end,
                  gsm.tt_start,
                  gsm.tt_end,
                  dbo.mtmaxoftwodates (gsm.tt_start, gsm2.tt_start),
                  dbo.mtminoftwodates (gsm.tt_end, gsm2.tt_end);

      EXIT WHEN SQL%ROWCOUNT <= 0;

      /* These are the records whose extender transaction time ends strictly within the record being
       * extended
       */
      INSERT INTO t_gsubmember_historical
                  (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
         SELECT gsm.id_group, gsm.id_acc, gsm.vt_start, gsm.vt_end,
                gsm2.vt_end + NUMTODSINTERVAL (1, 'second') AS tt_start,
                gsm.tt_end
           FROM t_gsubmember_historical gsm INNER JOIN t_gsubmember_historical gsm2 ON gsm.id_group =
                                                                                         gsm2.id_group
                                                                                  AND gsm.id_acc =
                                                                                         gsm2.id_acc
                                                                                  AND gsm.vt_start <
                                                                                         gsm2.vt_start
                                                                                  AND gsm2.vt_start <=
                                                                                           gsm.vt_end
                                                                                         + NUMTODSINTERVAL
                                                                                              (1,
                                                                                               'second'
                                                                                              )
                                                                                  AND gsm.vt_end <
                                                                                         gsm2.vt_end
                                                                                  AND gsm.tt_start <=
                                                                                         gsm2.tt_end
                                                                                  AND gsm2.tt_end <
                                                                                         gsm.tt_end
          WHERE EXISTS (
                   SELECT *
                     FROM tmp_subscribe_batch ar
                    WHERE ar.id_group = gsm.id_group
                          AND ar.id_acc = gsm.id_acc);

      /* These are the records whose extender starts strictly within the record being
       * extended
       */
      INSERT INTO t_gsubmember_historical
                  (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
         SELECT gsm.id_group, gsm.id_acc, gsm.vt_start, gsm.vt_end,
                gsm.tt_start,
                gsm2.tt_start - NUMTODSINTERVAL (1, 'second') AS tt_end
           FROM t_gsubmember_historical gsm INNER JOIN t_gsubmember_historical gsm2 ON gsm.id_group =
                                                                                         gsm2.id_group
                                                                                  AND gsm.id_acc =
                                                                                         gsm2.id_acc
                                                                                  AND gsm.vt_start <
                                                                                         gsm2.vt_start
                                                                                  AND gsm2.vt_start <=
                                                                                           gsm.vt_end
                                                                                         + NUMTODSINTERVAL
                                                                                              (1,
                                                                                               'second'
                                                                                              )
                                                                                  AND gsm.vt_end <
                                                                                         gsm2.vt_end
                                                                                  AND gsm.tt_start <
                                                                                         gsm2.tt_start
                                                                                  AND gsm2.tt_start <=
                                                                                         gsm.tt_end
          WHERE EXISTS (
                   SELECT 1
                     FROM tmp_subscribe_batch ar
                    WHERE ar.id_group = gsm.id_group
                          AND ar.id_acc = gsm.id_acc);

      UPDATE t_gsubmember_historical gsm
         SET (vt_end, tt_start, tt_end) =
                (SELECT ca.update_vt_end, ca.update_tt_start,
                        ca.update_tt_end
                   FROM tmp_coalesce_args ca
                  WHERE gsm.id_group = ca.id_group
                    AND gsm.id_acc = ca.id_acc
                    AND gsm.vt_start = ca.vt_start
                    AND gsm.vt_end = ca.vt_end
                    AND gsm.tt_start = ca.tt_start
                    AND gsm.tt_end = ca.tt_end);

      DELETE FROM tmp_coalesce_args;
   END LOOP;

   /*  Here we select stuff to "delete"
    * In all cases we have containment invalid time.
    * Consider the four overlapping cases for transaction time.
    */
   UPDATE t_gsubmember_historical gsmh
      SET tt_start =
             (SELECT MAX (tt_end) + NUMTODSINTERVAL (1, 'second')
                FROM t_gsubmember_historical gsm
               WHERE gsmh.id_group = gsm.id_group
                 AND gsmh.id_acc = gsm.id_acc
                 AND gsm.vt_start <= gsmh.vt_start
                 AND gsmh.vt_end <= gsm.vt_end
                 AND gsm.tt_end >= gsmh.tt_start
                 AND gsm.tt_end < gsmh.tt_end)
    WHERE EXISTS (
             SELECT 1
               FROM t_gsubmember_historical gsm
              WHERE gsmh.id_group = gsm.id_group
                AND gsmh.id_acc = gsm.id_acc
                AND gsm.vt_start <= gsmh.vt_start
                AND gsmh.vt_end <= gsm.vt_end
                AND gsm.tt_end >= gsmh.tt_start
                AND gsm.tt_end < gsmh.tt_end)
      AND EXISTS (
                 SELECT 1
                   FROM tmp_subscribe_batch ar
                  WHERE ar.id_group = gsmh.id_group
                        AND ar.id_acc = gsmh.id_acc);

   UPDATE t_gsubmember_historical gsmh
      SET tt_end =
             (SELECT MIN (tt_start) - NUMTODSINTERVAL (1, 'second')
                FROM t_gsubmember_historical gsm
               WHERE gsmh.id_group = gsm.id_group
                 AND gsmh.id_acc = gsm.id_acc
                 AND gsm.vt_start <= gsmh.vt_start
                 AND gsmh.vt_end <= gsm.vt_end
                 AND gsm.tt_start > gsmh.tt_start
                 AND gsm.tt_start <= gsmh.tt_end)
    WHERE EXISTS (
             SELECT 1
               FROM t_gsubmember_historical gsm
              WHERE gsmh.id_group = gsm.id_group
                AND gsmh.id_acc = gsm.id_acc
                AND gsm.vt_start <= gsmh.vt_start
                AND gsmh.vt_end <= gsm.vt_end
                AND gsm.tt_start > gsmh.tt_start
                AND gsm.tt_start <= gsmh.tt_end)
      AND EXISTS (
                 SELECT 1
                   FROM tmp_subscribe_batch ar
                  WHERE ar.id_group = gsmh.id_group
                        AND ar.id_acc = gsmh.id_acc);

  /* ES2698  added the "ar" predicate to improve the performace of the delete 
    adding gsm.id_group,gsm.id_acc to the where clause and exists predicate 
    prevents a table scan on t_gsubmemember_historical  */
   DELETE      t_gsubmember_historical gsm
      WHERE (gsm.id_group, gsm.id_acc) in
                                    (SELECT   ar.id_group col1,
                                              ar.id_acc col2
                                         FROM tmp_subscribe_batch ar
                                     GROUP BY ar.id_group, ar.id_acc)
        AND EXISTS (
                  SELECT 1
                 FROM t_gsubmember_historical gsm2,
                      (SELECT   ar.id_group col1, ar.id_acc col2
                           FROM tmp_subscribe_batch ar
                       GROUP BY ar.id_group, ar.id_acc) temp0
                   WHERE gsm.id_group = gsm2.id_group
                     AND gsm.id_acc = gsm2.id_acc
                     AND (   (    gsm2.vt_start < gsm.vt_start
                              AND gsm.vt_end <= gsm2.vt_end
                             )
                          OR (    gsm2.vt_start <= gsm.vt_start
                              AND gsm.vt_end < gsm2.vt_end
                             )
                         )
                     AND gsm2.tt_start <= gsm.tt_start
                     AND gsm.tt_end <= gsm2.tt_end
                  AND gsm.id_group = temp0.col1
                  AND gsm.id_acc = temp0.col2);

   /* Update audit information.
    */
   UPDATE tmp_subscribe_batch tmp
      SET tmp.nm_display_name =
                      (SELECT gsub.tx_name
                         FROM t_group_sub gsub
                        WHERE gsub.id_group = tmp.id_group AND tmp.status = 0);

   INSERT INTO t_audit
               (id_audit, id_event, id_userid, id_entitytype, id_entity,
                dt_crt)
      SELECT tmp.id_audit, tmp.id_event, tmp.id_userid, tmp.id_entitytype,
             tmp.id_acc, tmp.tt_now
        FROM tmp_subscribe_batch tmp
       WHERE tmp.status = 0;

   INSERT INTO t_audit_details
               (ID_AUDITDETAILS,id_audit, tx_details)
      SELECT SEQ_T_AUDIT_DETAILS.nextval,tmp.id_audit, tmp.nm_display_name
        FROM tmp_subscribe_batch tmp
       WHERE tmp.status = 0;

   END subscribebatchgroupsub;
/

CREATE OR REPLACE PROCEDURE CreateCounterPropDef(
			temp_id_lang_code int,
			n_kind int,
			nm_name nvarchar2,
			nm_display_name nvarchar2,
			temp_id_pi t_counterpropdef.id_pi%type,
			nm_servicedefprop t_counterpropdef.nm_servicedefprop%type,
			nm_preferredcountertype t_counterpropdef.nm_preferredcountertype%type,
			n_order t_counterpropdef.n_order%type,
			id_prop OUT int)
		AS
			identity_value 	t_counterpropdef.id_prop%type;
			id_locale int;
			id_display_name int;
			id_display_desc int;
		BEGIN
			InsertBaseProps(temp_id_lang_code, n_kind, 'N', 'N', nm_name, NULL, nm_display_name, identity_value, id_display_name, id_display_desc);

			INSERT INTO t_counterpropdef
				(id_prop, id_pi, nm_servicedefprop, n_order,
				nm_preferredcountertype)
			VALUES
				(identity_value, temp_id_pi, nm_servicedefprop, n_order, nm_preferredcountertype);
			id_prop := identity_value;
		END;
/

CREATE OR REPLACE procedure AddCounterInstance
				(id_lang_code int,
				 n_kind int,
				 nm_name nvarchar2,
				 nm_desc nvarchar2,
			   counter_type_id t_counter.id_counter_type%type,
			   id_prop OUT int)
	   	  as
				identity_value int;
				id_display_name int;
				id_display_desc int;
    		begin
					InsertBaseProps(id_lang_code, n_kind, 'N', 'N', nm_name, nm_desc, null, identity_value, id_display_name, id_display_desc);
					INSERT INTO t_counter (id_prop, id_counter_type) values (identity_value, counter_type_id);
					id_prop := identity_value;
				end;
/

CREATE OR REPLACE PROCEDURE CANEXECUTEEVENTS(dt_now DATE, id_instances VARCHAR2, lang_code int, res out sys_refcursor)
AS
BEGIN

  /*  */
  /* initially all instances are considered okay */
  /* a succession of queries attempt to find a problem with executing them */
  /*  */

  execute immediate 'truncate table t_CanExecuteEventsTempTbl';
  
  /* builds up a table from the comma separated list of instance IDs */

  INSERT INTO t_CanExecuteEventsTempTbl
  SELECT
    args.COLUMN_VALUE,
    COALESCE(loc.tx_name, evt.tx_display_name) tx_display_name,
    'OK'
  FROM table(cast(dbo.CSVToInt(CANEXECUTEEVENTS.id_instances) as  tab_id_instance)) args
  INNER JOIN t_recevent_inst inst ON inst.id_instance = args.COLUMN_VALUE
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = lang_code AND evt.id_event=loc.id_item);

  /* is the event not active */
  UPDATE t_CanExecuteEventsTempTbl results
  SET tx_reason = 'EventNotActive'
  where exists
  (
  SELECT 'X'
  FROM t_recevent_inst inst , t_recevent evt
  WHERE
  inst.id_instance = results.id_instance
  AND
  evt.id_event = inst.id_event
  AND
    /* event is NOT active */
    evt.dt_activated > CanExecuteEvents.dt_now AND
    (evt.dt_deactivated IS NOT NULL OR CanExecuteEvents.dt_now >= evt.dt_deactivated)
   );

  /* is the instance in an invalid state */
    for data in (
		  select results.rowid as r_rowid, inst.tx_status as i_inst_tx_status
		  FROM t_CanExecuteEventsTempTbl results, t_recevent_inst inst
		  WHERE   inst.id_instance = results.id_instance and
		  inst.tx_status NOT IN ('NotYetRun', 'ReadyToRun')
	    )
    loop
        UPDATE t_CanExecuteEventsTempTbl results
          SET tx_reason = data.i_inst_tx_status
          where rowid = data.r_rowid;
    end loop;



  /* is the interval hard closed */
  UPDATE t_CanExecuteEventsTempTbl results
  SET tx_reason = 'HardClosed'
  where exists (
  SELECT 'X'
  FROM t_recevent_inst inst,t_usage_interval ui
  WHERE
  inst.id_instance = results.id_instance AND
  ui.id_interval = inst.id_arg_interval AND
    ui.tx_interval_status = 'H'
    );
    
  open res for
  SELECT
    id_instance InstanceID,
    tx_display_name EventDisplayName,
    tx_reason Reason
  FROM t_CanExecuteEventsTempTbl;
  COMMIT;
END;
/

ALTER PROCEDURE mt_sys_analyze_table COMPILE;

ALTER PROCEDURE exec_ddl COMPILE;

ALTER PROCEDURE cleanupmaterialization COMPILE;

ALTER PROCEDURE resetbillinggroupconstraints COMPILE;

CREATE OR REPLACE PROCEDURE CompleteMaterialization
(
  p_id_materialization INT,
  p_dt_end date,
  status out INT
)
AS

  v_id_usage_interval int;
  cnt int;
  p_maxdate date;
  v_table_name varchar(30);
  v_sampling_ratio int;
BEGIN
   /* initialize @status to failure (-1) */
   status := -1;
   v_sampling_ratio := 20;
  
   /* ESR-2814 analyze table */
   v_table_name := 't_billgroup_tmp';
   mt_sys_analyze_table ( v_table_name ,v_sampling_ratio);

   /* ESR-2814 analyze table */
   v_table_name := 't_billgroup_member_tmp';
   mt_sys_analyze_table ( v_table_name ,v_sampling_ratio);

   /* copy data from t_billgroup_tmp to t_billgroup */
   INSERT INTO t_billgroup (id_billgroup, tx_name, tx_description, id_usage_interval, id_parent_billgroup, tx_type, id_partition)
   SELECT bgt.id_billgroup, bgt.tx_name, bgt.tx_description, bgm.id_usage_interval, bgm.id_parent_billgroup, bgm.tx_type, bgt.id_partition
   FROM t_billgroup_tmp bgt
   INNER JOIN t_billgroup_materialization bgm
    ON bgm.id_materialization = bgt.id_materialization
   WHERE bgm.id_materialization = p_id_materialization;

  /* copy data from t_billgroup_member_tmp to t_billgroup_member */
  INSERT INTO t_billgroup_member (id_billgroup, id_acc, id_materialization, id_root_billgroup)
  SELECT bgt.id_billgroup,
        bgmt.id_acc,
        p_id_materialization,
        dbo.GetBillingGroupAncestor(bgt.id_billgroup)
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt
     ON bgt.tx_name = bgmt.tx_name
  WHERE bgmt.id_materialization =  p_id_materialization
    AND bgt.id_materialization = p_id_materialization;
   
	select dbo.MTMaxDate() into p_maxdate from dual;
/* update t_billgroup_member_history */
  INSERT INTO t_billgroup_member_history (id_billgroup,
      id_acc,
      id_materialization,
      tx_status,
      tt_start,
      tt_end)
  SELECT bgt.id_billgroup,
              bgmt.id_acc,
              p_id_materialization,
              'Succeeded',
              p_dt_end,
              p_maxdate
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt
     ON bgt.tx_name = bgmt.tx_name
  WHERE bgmt.id_materialization =  p_id_materialization
    AND bgt.id_materialization = p_id_materialization;

  /* store the id_usage_interval */
  SELECT max(bgm.id_usage_interval) into v_id_usage_interval
  FROM t_billgroup_materialization bgm
  WHERE bgm.id_materialization = p_id_materialization;
  
  /* Copy over billing group constraints */
  ResetBillingGroupConstraints(v_id_usage_interval, status);

  IF (status != 0) then
    status := -2;
    ROLLBACK;
    RETURN;
  END if;
  
   /* Reset status */
  status := -1;

  SELECT count(bg.id_billgroup) into cnt
  FROM t_billgroup bg
  WHERE bg.id_billgroup NOT IN (
    SELECT id_billgroup FROM t_billgroup_member bgm)
  and id_usage_interval = v_id_usage_interval;

   /* Check that each billing group in t_billgroup has atleast one account  */
  if cnt > 0 then
    status := -3;
    ROLLBACK;
    RETURN;
   END if;

   /* Delete temporary data and update t_billgroup_materialization */
   CleanupMaterialization(
        p_id_materialization,
        p_dt_end,
        'Succeeded',
        NULL,
        status);

  IF (status != 0)  then
    status := -4;
    ROLLBACK;
    RETURN;
   END if;

   /* set @status to success */
   status := 0;

   COMMIT;

end CompleteMaterialization;
/

ALTER PROCEDURE deletebillgroupdata COMPILE;

CREATE OR REPLACE PROCEDURE CompleteReMaterialization
(
  p_id_materialization INT,
  p_dt_end date,
  status out INT
)
AS

  cnt int;
  v_id_usage_interval INT;
  v_table_name varchar(30);
  v_sampling_ratio number;

BEGIN
 
  /* initialize @status to failure (-1) */
  status := -1;
  v_sampling_ratio := 20;

  /* Get the id_usage_interval for the given p_id_materialization */
  SELECT id_usage_interval  into v_id_usage_interval
  FROM t_billgroup_materialization bgm
  WHERE bgm.id_materialization = p_id_materialization;

  /* copy billing groups from t_billgroup_tmp to t_billgroup
    only if they don't exist in t_billgroup for the interval associated with
    this p_id_materialization
    */
  INSERT INTO t_billgroup (id_billgroup, tx_name, tx_description,
    id_usage_interval, id_parent_billgroup, tx_type, id_partition)
  SELECT bgt.id_billgroup, bgt.tx_name, bgt.tx_description,
    bgm.id_usage_interval, bgm.id_parent_billgroup, bgm.tx_type, bgt.id_partition
  FROM t_billgroup_tmp bgt
  INNER JOIN t_billgroup_materialization bgm
         ON bgm.id_materialization = bgt.id_materialization
  WHERE bgt.id_materialization = p_id_materialization
    AND bgt.tx_name NOT IN (
      SELECT tx_name
      FROM t_billgroup
      WHERE id_usage_interval = v_id_usage_interval);
      
  /* 
  copy data from t_billgroup_member_tmp (bgmt) to 
  t_billgroup_member(bgm) with the following conditions:
  
  if  (account in bgmt exists in bgm)
  {
     if (billing group for account in bgmt and billing group for account in bgm are not the same)
     {
        if (both billing groups are 'Open')
        {
           (1) 
           Move account to new billing group
           Record 'succeeded'
           (1a) 
           If the old billing group becomes empty (ie. loses all accounts)
           then delete the old billing group and update history associated with it.
        }
        else 
        {
           (2)
           Record 'failed'
        }
     }
  }
  else
  {
     if (account lands in a billing group that's 'Open'')
     {
        (3)
        Move account to bgm
        Record 'succeeded'
     }
     else 
     {
        (4)
        Record 'failed'
     }
  }
  */
 
   /* ESR-2814 analyze table */
   v_table_name := 't_billgroup_member_tmp';
   mt_sys_analyze_table ( v_table_name ,v_sampling_ratio);

  /* Doing (1) from the above algorithm
  In t_billgroup_member, the id_acc will be unique amongst the billgroups for
  a given interval
  */
  INSERT into tmp_billGroupMemberMoves
  SELECT bgmt.id_materialization id_materialization_new,
    bgmem.id_materialization id_materialization_old,
    bgmt.id_acc,
    bg1.id_billgroup id_billgroup_new,
    bg.id_billgroup id_billgroup_old,
    bg1.tx_name billgroup_name_new,
    bg.tx_name billgroup_name_old,
    bgsNew.status newStatus,
    bgsOld.status oldStatus
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_member bgmem
    ON bgmem.id_acc = bgmt.id_acc
  INNER JOIN t_billgroup bg
    ON bg.id_billgroup = bgmem.id_billgroup
    AND bg.tx_name != bgmt.tx_name
  INNER JOIN t_billgroup_tmp bgt
    ON bgt.tx_name = bgmt.tx_name
    AND bgt.id_materialization = bgmt.id_materialization
  INNER JOIN t_billgroup bg1
    ON bg1.tx_name = bgmt.tx_name
  LEFT OUTER JOIN vw_all_billing_groups_status bgsNew
    ON bgsNew.id_billgroup = bg1.id_billgroup
  LEFT OUTER JOIN vw_all_billing_groups_status bgsOld
    ON bgsOld.id_billgroup = bg.id_billgroup
  WHERE bgmt.id_materialization =  p_id_materialization
    AND bg.id_billgroup IN (
        SELECT id_billgroup
        FROM t_billgroup
        WHERE id_usage_interval = v_id_usage_interval)
    AND bg1.id_billgroup IN (
        SELECT id_billgroup
        FROM t_billgroup
        WHERE id_usage_interval = v_id_usage_interval);

  /* Update history for account */
  UPDATE t_billgroup_member_history bgmh
  SET tt_end = p_dt_end
  where exists (
    select 1
    FROM tmp_billGroupMemberMoves bgmt
    where bgmt.id_acc = bgmh.id_acc
    AND bgmt.id_billgroup_old = bgmh.id_billgroup
    AND bgmt.id_materialization_old = bgmh.id_materialization
    and bgmt.oldStatus = 'O'
    AND (bgmt.newStatus = 'O' OR bgmt.newStatus IS NULL)
    );

  /* Delete account(s) from t_billgroup_member */
  DELETE FROM t_billgroup_member bgm
  where exists (
    select 1
    from tmp_billGroupMemberMoves bgmt
    where bgmt.id_billgroup_old = bgm.id_billgroup
      AND bgmt.id_acc = bgm.id_acc
      and bgmt.oldStatus = 'O'
      AND (bgmt.newStatus = 'O' OR bgmt.newStatus IS NULL)
    );

  /* Insert updated account(s) into t_billgroup_member */
  INSERT INTO t_billgroup_member (id_billgroup, id_acc, id_materialization,
    id_root_billgroup)
  SELECT bgmt.id_billgroup_new, bgmt.id_acc, bgmt.id_materialization_new,
    dbo.GetBillingGroupAncestor(bgmt.id_billgroup_new)
  FROM tmp_billGroupMemberMoves bgmt
  WHERE bgmt.oldStatus = 'O'
    AND (bgmt.newStatus = 'O' OR bgmt.newStatus IS NULL);

  /* Insert new history for account */
  INSERT INTO t_billgroup_member_history (id_billgroup,
    id_acc,
    id_materialization,
    tx_status,
    tt_start,
    tt_end)
  SELECT bgmt.id_billgroup_new,
    bgmt.id_acc,
    bgmt.id_materialization_new,
    'Succeeded',
    p_dt_end,
    dbo.MTMaxDate()
  FROM tmp_billGroupMemberMoves bgmt
  WHERE bgmt.oldStatus = 'O'
    AND (bgmt.newStatus = 'O' OR bgmt.newStatus IS NULL);

  /*
    Doing (1a) from the above algorithm
  */

  /* Delete old billgroup if it doesn't have any accounts */
  INSERT INTO tmp_deleted_billgroups
  SELECT id_billgroup
  FROM t_billgroup bg
  INNER JOIN tmp_billGroupMemberMoves bgmoves
    ON bgmoves.id_billgroup_old = bg.id_billgroup
    AND bgmoves.id_billgroup_old NOT IN (
      SELECT id_billgroup
      FROM t_billgroup_member)
  WHERE bgmoves.oldStatus = 'O'
    AND (bgmoves.newStatus = 'O' OR bgmoves.newStatus IS NULL);
  
  DeleteBillGroupData('tmp_deleted_billgroups');

  /* Doing (2) from the above algorithm. 
  Insert rows into t_billgroup_member_history for account moves into and out of 'Soft Closed' or
  'Hard Closed' billing groups. These are not 'history' rows because
  no change is happening to the account. The tt_start and tt_end times on these rows
  don't matter. They are filtered based on tx_status = 'Failed'
  */

  INSERT INTO t_billgroup_member_history (id_billgroup,
    id_acc,
    id_materialization,
    tx_status,
    tt_start,
    tt_end,
    tx_failure_reason)
  SELECT NULL,
    bgmt.id_acc,
    bgmt.id_materialization_new,
    'Failed',
    p_dt_end,
    p_dt_end,
    'Attempting to move this account from billing group ['
      || bgmt.billgroup_name_old
      || ']  to billing group ['
      || bgmt.billgroup_name_new
      || '] when one (or both) billing group is not in an Open state.'
      as reason
  FROM tmp_billGroupMemberMoves bgmt
  WHERE bgmt.oldStatus != 'O'
    OR (bgmt.newStatus != 'O' AND bgmt.newStatus IS NOT NULL);

  /* Clear billGroupMemberMoves */
  DELETE  tmp_billGroupMemberMoves;

  /* Doing (3) from the above algorithm */
  INSERT into tmp_billUnassignedAccountMoves
  SELECT bgmt.id_materialization,
    bgmt.id_acc,
    bg.id_billgroup,
    bg.tx_name,
    bgs.status
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt
    ON bgt.tx_name = bgmt.tx_name
    AND bgt.id_materialization = bgmt.id_materialization
  INNER JOIN t_billgroup bg
    ON bg.tx_name = bgt.tx_name
  LEFT OUTER JOIN vw_all_billing_groups_status bgs
    ON bgs.id_billgroup = bg.id_billgroup
  WHERE bgmt.id_acc NOT IN (
    SELECT id_acc
    FROM t_billgroup_member
    WHERE id_billgroup IN (
      SELECT id_billgroup
      FROM t_billgroup
      WHERE id_usage_interval = v_id_usage_interval
      )
    )
    AND bgmt.id_materialization = p_id_materialization
    AND bg.id_billgroup IN (
      SELECT id_billgroup
      FROM t_billgroup
      WHERE id_usage_interval = v_id_usage_interval
      );
  
  /* Insert updated account(s) into t_billgroup_member */
  INSERT INTO t_billgroup_member (id_billgroup, id_acc, id_materialization,
    id_root_billgroup)
  SELECT buam.id_billgroup, buam.id_acc, buam.id_materialization,
    dbo.GetBillingGroupAncestor(buam.id_billgroup)
  FROM tmp_billUnassignedAccountMoves buam
  WHERE buam.status = 'O' OR buam.status IS NULL;
  
  /* Insert new history for account */
  INSERT INTO t_billgroup_member_history (id_billgroup,
    id_acc,
    id_materialization,
    tx_status,
    tt_start,
    tt_end)
  SELECT buam.id_billgroup,
    buam.id_acc,
    buam.id_materialization,
    'Succeeded',
    p_dt_end,
    dbo.MTMaxDate()
  FROM tmp_billUnassignedAccountMoves buam
  WHERE buam.status = 'O' OR buam.status IS NULL;
  
  /* Doing (4) from the above algorithm.
  Insert rows into t_billgroup_member_history. These are not 'history' rows because
  no change is happening to the account. The tt_start and tt_end times on these rows
  don't matter. They are filtered based on tx_status = 'Failed'
  */
  INSERT INTO t_billgroup_member_history (id_billgroup,
    id_acc,
    id_materialization,
    tx_status,
    tt_start,
    tt_end,
    tx_failure_reason)
  SELECT NULL,
    buam.id_acc,
    buam.id_materialization,
    'Failed',
    p_dt_end,
    p_dt_end,
    'Attempting to assign this account to the billing group ['
    || buam.billgroup_name
    || ']  when the  billing group is not in an Open state.'
      as reason
  FROM tmp_billUnassignedAccountMoves buam
  WHERE status != 'O' AND status IS NOT NULL;

  /* Check that each billing group in t_billgroup has atleast one account  */
  SELECT count(bg.id_billgroup) into cnt
  FROM t_billgroup bg
  WHERE bg.id_billgroup NOT IN (
    SELECT id_billgroup
    FROM t_billgroup_member bgm);
    
  IF cnt > 0 then
    status := -2;
    ROLLBACK;
    RETURN;
  END if;

  /* Clear @billUnassignedAccountMoves */
  DELETE  tmp_billUnassignedAccountMoves;

  /* Copy over billing group constraints */
  ResetBillingGroupConstraints(v_id_usage_interval, status);
  
  IF (status != 0) then
    status := -3;
    RollbacK;
    RETURN;
  END if;

  /* Reset status */
  status := -1;

  /* Delete temporary data and update t_billgroup_materialization */
  CleanupMaterialization(p_id_materialization,
    p_dt_end,
    'Succeeded',
    NULL,
    status);
  
  IF (status != 0) then
    status := -4;
    ROLLBACk;
    RETURN;
  END if;
  
  /* set status to success */
  status := 0;
  
  COMMIt;

END CompleteReMaterialization;
/

CREATE OR REPLACE procedure UpdateCounterInstance
		    (
				p_id_lang_code int,
				p_id_prop t_base_props.id_prop%type,
				counter_type_id t_counter.id_counter_type%type,
				nm_name_in t_base_props.nm_name%type,
				nm_desc_in t_base_props.nm_desc%type)
			  as
				updated_id_display_name int;
				updated_id_display_desc int;
			  begin
				UpdateBaseProps (p_id_prop, p_id_lang_code, NULL, nm_desc_in, NULL, updated_id_display_name, updated_id_display_desc);
				UPDATE t_base_props SET nm_name = nm_name_in,nm_desc = nm_desc_in
				WHERE
				id_prop = p_id_prop;
				UPDATE t_counter
				SET id_counter_type = counter_type_id
				WHERE id_prop = p_id_prop;
 			  end;
/

CREATE OR REPLACE procedure AddCounterParam
				(
				 p_id_lang_code int,
				 p_id_counter int,
				 id_counter_param_type int,
				 nm_counter_value nvarchar2,
				 nm_name nvarchar2,
				 nm_desc nvarchar2,
				 nm_display_name nvarchar2,
				 identity OUT int)
				AS
				identity_value int;
				id_display_name int;
				id_display_desc int;
				BEGIN
	        InsertBaseProps (p_id_lang_code, 190, 'N', 'N', nm_name, nm_desc, nm_display_name, identity_value, id_display_name, id_display_desc);
					INSERT INTO t_counter_params
			    (id_counter_param,id_counter, id_counter_param_meta, Value)
			    VALUES
				  (identity_value,p_id_counter, id_counter_param_type, nm_counter_value);
			    identity :=identity_value;
  			end;
/

ALTER FUNCTION table_exists COMPILE;

CREATE OR REPLACE PROCEDURE
 CreateAnalyticsDataMart(p_dt_now date, p_id_run int, p_nm_currency nvarchar2, p_nm_instance nvarchar2, p_n_months int, p_STAGINGDB_prefix nvarchar2)
   AUTHID CURRENT_USER
IS
  l_tmp_tbl varchar2(61);
  l_count number;
  l_billTo number;
BEGIN

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Cleaning out temporary tables');
end if;

l_tmp_tbl := UPPER('tmp_accs');
IF (TABLE_EXISTS(l_tmp_tbl)) THEN
    EXEC_DDL('DROP TABLE ' || l_tmp_tbl); END IF; l_tmp_tbl := UPPER('all_rcs'); IF (TABLE_EXISTS(l_tmp_tbl)) THEN
    EXEC_DDL('DROP TABLE ' || l_tmp_tbl); END IF; l_tmp_tbl := UPPER('all_rcs_linked'); IF (TABLE_EXISTS(l_tmp_tbl)) THEN
    EXEC_DDL('DROP TABLE ' || l_tmp_tbl); END IF; l_tmp_tbl := UPPER('all_rcs_by_month'); IF (TABLE_EXISTS(l_tmp_tbl)) THEN
    EXEC_DDL('DROP TABLE ' || l_tmp_tbl); END IF; l_tmp_tbl := UPPER('sum_rcs_by_month'); IF (TABLE_EXISTS(l_tmp_tbl)) THEN
    EXEC_DDL('DROP TABLE ' || l_tmp_tbl); END IF; l_tmp_tbl := UPPER('tmp_previous_two_months'); IF (TABLE_EXISTS(l_tmp_tbl)) THEN
    EXEC_DDL('DROP TABLE ' || l_tmp_tbl); END IF;


execute immediate 'create table tmp_accs (id_ancestor int not null, id_descendent int not null)';

execute immediate 'create table all_rcs (InstanceId varchar2(64), SubscriptionId int not null, PayerId int not null, PayeeId int not null, StartDate date, EndDate date, ActionType nvarchar2(255), Currency nvarchar2(3), ProratedDailyRate number(22,10), DailyRate number(22,10), Rate number(22,10), ProductOfferingId int, PriceableItemTemplateId int, PriceableItemInstanceId int, SubscriptionStartDate date, SubscriptionEndDate date, MRR number(22,10))';

execute immediate 'create table all_rcs_linked (InstanceId varchar2(64), SubscriptionId int not null, PayerId int not null, PayeeId int not null, StartDate date, EndDate date, ActionType nvarchar2(255), Currency nvarchar2(3), ProratedDailyRate number(22,10), DailyRate number(22,10), Rate number(22,10), ProductOfferingId int, PriceableItemTemplateId int, PriceableItemInstanceId int, SubscriptionStartDate date, SubscriptionEndDate date, MRR number(22,10), OldRate number(22,10), OldDailyRate number(22,10), OldProratedDailyRate number(22,10), OldSubscriptionStartDate date, OldSubscriptionEndDate date)';

execute immediate 'create table all_rcs_by_month (InstanceId varchar2(64), SubscriptionId int not null, ProductOfferingId int, PriceableItemTemplateId int, PriceableItemInstanceId int, SubscriptionStartDate date, SubscriptionEndDate date, Currency nvarchar2(3), ActionType nvarchar2(255), Year int, Month int, DailyRate number(22,10), Rate number(22,10), OldDailyRate number(22,10), OldRate number(22,10), OldProratedDailyRate number(22,10), OldSubscriptionStartDate date, OldSubscriptionEndDate date, Days int)';

execute immediate 'create table sum_rcs_by_month (InstanceId varchar2(64), SubscriptionId int not null, PriceableItemTemplateId int, PriceableItemInstanceId int, Currency nvarchar2(3), Year int, Month int, DaysInMonth int, DaysActiveInMonth int, TotalAmount number(22,10), OldAmount number(22,10), NewAmount number(22,10))';

execute immediate 'create table tmp_previous_two_months (InstanceId varchar2(64), Year int, Month int, FirstDayOfMonth date, LastDayOfMonth date)';

execute immediate 'create or replace procedure CreateADMInternal (p_dt_now date, p_id_run int, p_nm_currency nvarchar2, p_nm_instance nvarchar2, p_n_months int, p_STAGINGDB_prefix nvarchar2)
   AUTHID CURRENT_USER
IS
BEGIN

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL, sysdate, ''Debug'', ''Starting Analytics DataMart'');
END IF;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL, sysdate, ''Debug'', ''Flushing Analytics datamart tables'');
END IF;
end;';

execute immediate ('TRUNCATE TABLE Customer');
execute immediate ('TRUNCATE TABLE SalesRep');
execute immediate ('TRUNCATE TABLE SubscriptionsByMonth');
execute immediate ('TRUNCATE TABLE SubscriptionUnits');
execute immediate ('TRUNCATE TABLE SubscriptionSummary');
execute immediate ('TRUNCATE TABLE CurrencyExchangeMonthly');
execute immediate ('TRUNCATE TABLE ProductOffering');
execute immediate ('TRUNCATE TABLE SubscriptionParticipants');

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating Customers DataMart');
END IF;


/* customers datamart */
insert into tmp_accs (id_ancestor, id_descendent)
select * from (
with root_accts as
(
	select /* corporate accounts */
	a.id_acc
	from t_account a
	inner join t_account_type t on t.id_type = a.id_type
	where 1=1
	and t.b_iscorporate = 1
	and t.b_isvisibleinhierarchy = 1
),
tmp_corps as
(
select
r.id_acc id_ancestor, aa.id_descendent, aa.num_generations
from root_accts r
inner join t_account_ancestor aa on aa.id_ancestor = r.id_acc and p_dt_now between aa.vt_start and aa.vt_end
where 1=1
),
my_gens as
(
	select
	id_descendent, max(num_generations) num_generations
	from tmp_corps
	group by id_descendent
)
select
max(a.id_ancestor) id_ancestor, a.id_descendent
from tmp_corps a
inner join my_gens g on a.id_descendent = g.id_descendent and a.num_generations = g.num_generations
where 1=1
group by a.id_descendent
) a;

select count(1) into l_count from tmp_accs;

if (p_id_run is not null) then
	 INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Found Corporate Hierarchy Accounts: ' || nvl(l_count, 0));
END IF;

insert into tmp_accs (id_ancestor, id_descendent)
select * from (
with root_accts as
(
	select
	aa.id_descendent id_acc
	from t_account_ancestor aa
	inner join t_account a on a.id_acc = aa.id_descendent
	inner join t_account_type t on t.id_type = a.id_type and (t.b_iscorporate = 0 or t.b_isvisibleinhierarchy = 0)
	where 1=1
	and p_dt_now between aa.vt_start and aa.vt_end
	and aa.id_ancestor = 1
	and aa.num_generations = 1
	and aa.b_children = 'Y'
)
select
r.id_acc id_ancestor, aa.id_descendent
from root_accts r
inner join t_account_ancestor aa on aa.id_ancestor = r.id_acc and p_dt_now between aa.vt_start and aa.vt_end
left outer join tmp_accs a on aa.id_descendent = a.id_descendent
where 1=1
and a.id_descendent is null
) a;

select count(1) into l_count from tmp_accs;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Added Non-Corporate Hierarchy Accounts, Total Now: ' || nvl(l_count, 0));
END IF;

/* non-corporate nodes without hierarchy */
insert into tmp_accs (id_ancestor, id_descendent)
select
a.id_acc, a.id_acc
from t_account a
left outer join tmp_accs b on a.id_acc = b.id_descendent
inner join t_account_ancestor aa on aa.id_descendent = a.id_acc and p_dt_now between aa.vt_start and aa.vt_end and aa.id_ancestor = 1 and aa.num_generations > 0
where 1=1
and b.id_descendent is null
;

select count(1) into l_count from tmp_accs;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Added Non-Corporate Non-Hierarchy Accounts, Total Now: ' || nvl(l_count, 0));
END IF;

/* unrooted nodes */
insert into tmp_accs (id_ancestor, id_descendent)
select * from (
with tmp_unrooted as
(
select
aa.id_ancestor, aa.id_descendent, aa.num_generations
from t_account a
left outer join tmp_accs b on a.id_acc = b.id_descendent
inner join t_account_ancestor aa on aa.id_descendent = a.id_acc and p_dt_now between aa.vt_start and aa.vt_end
where 1=1
and b.id_descendent is null
),
my_unrooted as
(
	select id_descendent, max(num_generations) num_generations
	from tmp_unrooted
	group by id_descendent
)
select
b.id_ancestor, b.id_descendent
from my_unrooted a
inner join tmp_unrooted b on a.id_descendent = b.id_descendent and a.num_generations = b.num_generations
where 1=1
) a;

select count(1) into l_count from tmp_accs;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Added Non-Rooted Accounts, Total Now: ' || nvl(l_count, 0));
END IF;


select id_enum_data into l_billTo from t_enum_data where upper(nm_enum_data) = 'METRATECH.COM/ACCOUNTCREATION/CONTACTTYPE/BILL-TO';

insert into Customer
		(InstanceId,
		MetraNetId,
		AccountType,
		ExternalId,
		ExternalIdSpace,
		FirstName,
		MiddleName,
		LastName,
		Company,
		Currency,
		City,
		State,
		ZipCode,
		Country,
		Email,
		Phone,
		HierarchyMetraNetId,
		HierarchyAccountType,
		HierarchyExternalId,
		HierarchyExternalIdSpace,
		HierarchyFirstName,
		HierarchyMiddleName,
		HierarchyLastName,
		HierarchyCompany,
		HierarchyCurrency,
		HierarchyCity,
		HierarchyState,
		HierarchyZipCode,
		HierarchyCountry,
		HierarchyEmail,
		HierarchyPhone,
		StartDate,
		EndDate)
select
		InstanceId,
		MetraNetId,
		AccountType,
		ExternalId,
		ExternalIdSpace,
		FirstName,
		MiddleName,
		LastName,
		Company,
		Currency,
		City,
		State,
		ZipCode,
		Country,
		Email,
		Phone,
		HierarchyMetraNetId,
		HierarchyAccountType,
		HierarchyExternalId,
		HierarchyExternalIdSpace,
		HierarchyFirstName,
		HierarchyMiddleName,
		HierarchyLastName,
		HierarchyCompany,
		HierarchyCurrency,
		HierarchyCity,
		HierarchyState,
		HierarchyZipCode,
		HierarchyCountry,
		HierarchyEmail,
		HierarchyPhone,
		StartDate,
		EndDate
from (select
p_nm_instance as InstanceId,
c.id_acc as MetraNetId,
ct.name as AccountType,
cam.nm_login as ExternalId,
cam.nm_space as ExternalIdSpace,
cav.c_firstname as FirstName,
cav.c_middleinitial as MiddleName,
cav.c_lastname as LastName,
cav.c_company as Company,
cavi.c_currency as Currency,
cav.c_city as City,
cav.c_state as State,
cav.c_zip as ZipCode,
substr(ted2.nm_enum_data,20,100) as Country,
cav.c_email as Email,
cav.c_phonenumber as Phone,
p.id_acc as HierarchyMetraNetId,
pt.name as HierarchyAccountType,
pam.nm_login as HierarchyExternalId,
pam.nm_space as HierarchyExternalIdSpace,
pav.c_firstname as HierarchyFirstName,
pav.c_middleinitial as HierarchyMiddleName,
pav.c_lastname as HierarchyLastName,
pav.c_company as HierarchyCompany,
pavi.c_currency as HierarchyCurrency,
pav.c_city as HierarchyCity,
pav.c_state as HierarchyState,
pav.c_zip as HierarchyZipCode,
substr(ted3.nm_enum_data,20,100) as HierarchyCountry,
pav.c_email as HierarchyEmail,
pav.c_phonenumber as HierarchyPhone,
c.dt_crt as StartDate,
case when UPPER(state.status) != 'AC' then state.vt_start else state.vt_end end as EndDate,
DENSE_RANK() OVER (PARTITION BY c.id_acc, p.id_acc ORDER BY cam.nm_space, pam.nm_space) as priority_col
from tmp_accs r
inner join t_account c on c.id_acc = r.id_descendent
inner join t_account_state state on state.id_acc = c.id_acc
inner join t_account_type ct on ct.id_type = c.id_type
inner join t_account_mapper cam on cam.id_acc = c.id_acc and cam.nm_space not in ('ar')
left outer join t_av_internal cavi on cavi.id_acc = c.id_acc
left outer join t_av_contact cav on c.id_acc = cav.id_acc and cav.c_contactType = l_billTo
left outer join t_enum_data ted2 on ted2.id_enum_data = cav.c_country
inner join t_account p on p.id_acc = r.id_ancestor
inner join t_account_type pt on pt.id_type = p.id_type
inner join t_account_mapper pam on pam.id_acc = p.id_acc and pam.nm_space not in ('ar')
left outer join t_av_internal pavi on pavi.id_acc = p.id_acc
left outer join t_av_contact pav on p.id_acc = pav.id_acc and pav.c_contactType = l_billTo
left outer join t_enum_data ted3 on ted3.id_enum_data = pav.c_country
where 1=1
) a
where 1=1
and a.priority_col = 1;

select count(1) into l_count from Customer;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Customers: ' || nvl(l_count, 0));
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating SalesRep DataMart');
END IF;

/* sales reps */
insert into SalesRep
(	InstanceId,
	MetraNetId,
	ExternalId,
	CustomerId,
	Percentage,
	RelationshipType)
select p_nm_instance as InstanceId,
tao.id_owner as MetraNetId,
am.nm_login as ExternalId,
tao.id_owned as CustomerId,
tao.n_percent as Percentage,
substr(ted.nm_enum_data,37, 100) as RelationshipType
from t_acc_ownership tao
inner join t_enum_data ted on ted.id_enum_data = tao.id_relation_type
inner join t_account_mapper am on am.id_acc = tao.id_owner and am.nm_space = 'system_user'
where 1=1
and p_dt_now between tao.vt_start and tao.vt_end
;

select count(1) into l_count from SalesRep;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Sales Reps: ' || nvl(l_count, 0));
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating CurrencyExchangeMonthly DataMart');
END IF;

insert into CurrencyExchangeMonthly
(	InstanceId,
	StartDate,
	EndDate,
	SourceCurrency,
	TargetCurrency,
	ExchangeRate
)
select p_nm_instance,
	nvl(vt_start, dbo.mtmindate()),
	nvl(vt_end, dbo.mtmaxdate()),
	nm_country_source,
	nm_country_target,
	c_Exchange_Rate
from t_vw_adm_exchange_rates
;
select count(1) into l_count from CurrencyExchangeMonthly;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Currency Exchange Rates: ' || nvl(l_count, 0));
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating SubscriptionsByMonth DataMart');
END IF;

insert into all_rcs
(InstanceId,
SubscriptionId,
PayerId,
PayeeId,
StartDate,
EndDate,
ActionType,
Currency,
ProratedDailyRate,
DailyRate,
Rate,
ProductOfferingId,
PriceableItemTemplateId,
PriceableItemInstanceId,
SubscriptionStartDate,
SubscriptionEndDate,
MRR
)
select * from (
with my_pis as
(
select distinct
sub.id_sub,
sub.id_acc,
sub.id_po,
plm.id_pi_template,
plm.id_pi_instance,
sub.vt_start,
sub.vt_end
from t_sub sub
inner join t_pl_map plm on plm.id_po = sub.id_po and plm.id_paramtable is null and plm.id_sub is null
inner join t_recur tr on tr.id_prop = plm.id_pi_instance
where 1=1
and sub.id_group is null
union
select distinct
sub.id_sub,
mbr.id_acc,
sub.id_po,
plm.id_pi_template,
plm.id_pi_instance,
mbr.vt_start,
mbr.vt_end
from t_gsubmember mbr
inner join t_sub sub on sub.id_group = mbr.id_group
inner join t_pl_map plm on plm.id_po = sub.id_po and plm.id_paramtable is null and plm.id_sub is null
inner join t_recur tr on tr.id_prop = plm.id_pi_instance and tr.b_charge_per_participant = 'Y'
where 1=1
union
select distinct
sub.id_sub,
grm.id_acc,
sub.id_po,
plm.id_pi_template,
plm.id_pi_instance,
grm.vt_start,
grm.vt_end
from t_gsubmember mbr
inner join t_sub sub on sub.id_group = mbr.id_group
inner join t_pl_map plm on plm.id_po = sub.id_po and plm.id_paramtable is null and plm.id_sub is null
inner join t_recur tr on tr.id_prop = plm.id_pi_instance and tr.b_charge_per_participant = 'N'
inner join t_gsub_recur_map grm on grm.id_prop = tr.id_prop and grm.tt_end = dbo.mtmaxdate()
where 1=1
)
select
*
from (
select
p_nm_instance as InstanceId,
svc.id_sub as SubscriptionId,
au.id_acc as PayerId,
au.id_payee as PayeeId,
pv.c_ProratedIntervalStart as StartDate,
pv.c_ProratedIntervalEnd as EndDate,
pv.c_RCActionType as ActionType,
au.am_currency as Currency,
pv.c_ProratedDailyRate as ProratedDailyRate,
case when pv.c_prorateddays = 0 then au.amount else au.amount/pv.c_prorateddays end as DailyRate,
pv.c_RCAmount as Rate,
au.id_prod as ProductOfferingId,
au.id_pi_template as PriceableItemTemplateId,
au.id_pi_instance as PriceableItemInstanceId,
svc.vt_start as SubscriptionStartDate,
svc.vt_end as SubscriptionEndDate,
au.amount as MRR
from t_usage_interval tui
inner join t_pv_flatrecurringcharge pv on tui.id_interval = pv.id_usage_interval
inner join t_acc_usage au on au.id_usage_interval = pv.id_usage_interval and au.id_sess = pv.id_sess
inner join my_pis svc on svc.id_po = au.id_prod and svc.id_pi_template = au.id_pi_template and svc.id_pi_instance = au.id_pi_instance and svc.id_acc = au.id_payee
						and svc.id_sub = pv.c__SubscriptionID
where 1=1
and au.amount <> 0.0
union all
select
p_nm_instance as InstanceId,
svc.id_sub as SubscriptionId,
au.id_acc as PayerId,
au.id_payee as PayeeId,
pv.c_ProratedIntervalStart as StartDate,
pv.c_ProratedIntervalEnd as EndDate,
pv.c_RCActionType as ActionType,
au.am_currency as Currency,
pv.c_ProratedDailyRate as ProratedDailyRate,
case when pv.c_prorateddays = 0 then au.amount else au.amount/pv.c_prorateddays end as DailyRate,
pv.c_RCAmount as Rate,
au.id_prod as ProductOfferingId,
au.id_pi_template as PriceableItemTemplateId,
au.id_pi_instance as PriceableItemInstanceId,
svc.vt_start as SubscriptionStartDate,
svc.vt_end as SubscriptionEndDate,
au.amount as MRR
from t_usage_interval tui
inner join t_pv_udrecurringcharge pv on tui.id_interval = pv.id_usage_interval
inner join t_acc_usage au on au.id_usage_interval = pv.id_usage_interval and au.id_sess = pv.id_sess
inner join my_pis svc on svc.id_po = au.id_prod and svc.id_pi_template = au.id_pi_template and svc.id_pi_instance = au.id_pi_instance and svc.id_acc = au.id_payee
						and svc.id_sub = pv.c__SubscriptionID
where 1=1
and au.amount <> 0.0
) A
) a;

select count(1) into l_count from all_rcs;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Found RCs: ' || nvl(l_count, 0));
END IF;

execute immediate 'create index idx_all_rcs on all_rcs (InstanceId, SubscriptionId, PayeeId, PriceableItemTemplateId, PriceableItemInstanceId, StartDate, EndDate, ActionType, Currency)';

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Created index for RC linkage');
END IF;

insert into all_rcs_linked
(InstanceId,
SubscriptionId,
PayerId,
PayeeId,
StartDate,
EndDate,
ActionType,
Currency,
ProratedDailyRate,
DailyRate,
Rate,
ProductOfferingId,
PriceableItemTemplateId,
PriceableItemInstanceId,
SubscriptionStartDate,
SubscriptionEndDate,
MRR,
OldRate,
OldDailyRate,
OldProratedDailyRate,
OldSubscriptionStartDate,
OldSubscriptionEndDate
)
select
crc.*,
prc.Rate as OldRate,
prc.DailyRate as OldDailyRate,
prc.ProratedDailyRate as OldProratedDailyRate,
prc.SubscriptionStartDate as OldSubscriptionStartDate,
prc.SubscriptionEndDate as OldSubscriptionEndDate
from all_rcs crc
left outer join all_rcs prc on  crc.InstanceId = prc.InstanceId
                             and crc.SubscriptionId = prc.SubscriptionId
                             and crc.PayeeId = prc.PayeeId
                             and crc.PriceableItemTemplateId = prc.PriceableItemTemplateId
                             and crc.PriceableItemInstanceId = prc.PriceableItemInstanceId
							 and crc.Currency = prc.Currency
                             and prc.EndDate = crc.StartDate - (1/(24*60*60))
                             and prc.ActionType = crc.ActionType
                             and crc.ActionType IN ('Advance','Arrears')
where 1=1
;

select count(1) into l_count from all_rcs_linked;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Found Linked RCs: ' || nvl(l_count, 0));
END IF;

execute immediate 'create index idx_all_rcs_linked on all_rcs_linked (InstanceId, SubscriptionId, PriceableItemTemplateId, PriceableItemInstanceId, StartDate, EndDate)';

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Created index for linked RCs');
END IF;

insert into all_rcs_by_month
(
InstanceId,
SubscriptionId,
ProductOfferingId,
PriceableItemTemplateId,
PriceableItemInstanceId,
SubscriptionStartDate,
SubscriptionEndDate,
Currency,
ActionType,
Year,
Month,
DailyRate,
Rate,
OldDailyRate,
OldRate,
OldProratedDailyRate,
OldSubscriptionStartDate,
OldSubscriptionEndDate,
Days
)
select
*
from
(
WITH MONTHS AS (
  SELECT LEVEL-1 AS num
  FROM DUAL
  CONNECT BY LEVEL <= 12
)
select
rcs.InstanceId,
rcs.SubscriptionId,
rcs.ProductOfferingId,
rcs.PriceableItemTemplateId,
rcs.PriceableItemInstanceId,
rcs.SubscriptionStartDate,
rcs.SubscriptionEndDate,
rcs.Currency,
case when months.num <> 0 then to_nchar('NotInitial') else rcs.ActionType end as ActionType,
extract(year from add_months(rcs.startdate, months.num)) as Year,
extract(month from add_months(rcs.startdate, months.num)) as Month,
rcs.DailyRate,
rcs.Rate,
rcs.OldDailyRate,
rcs.OldRate,
rcs.OldProratedDailyRate,
rcs.OldSubscriptionStartDate,
rcs.OldSubscriptionEndDate,
case when months_between(trunc(rcs.enddate,'mon'), trunc(rcs.startdate,'mon')) = months.num then extract(day from rcs.enddate) - case when months.num = 0 then (extract(day from rcs.startdate) - 1) else 0 end
	 else case when extract(month from add_months(rcs.startdate, months.num)) in (4,6,9,11) then 30
	           when extract(month from add_months(rcs.startdate, months.num)) = 2 then case when mod(extract(year from add_months(rcs.startdate, months.num)), 400) = 0 then 29
																					  when mod(extract(year from add_months(rcs.startdate, months.num)), 100) = 0 then 28
																					  when mod(extract(year from add_months(rcs.startdate, months.num)), 4)   = 0 then 29
																					  else 28
																				 end
			   else 31
		  end
		  - case when months.num <> 0 then 0
				 else (extract(day from rcs.startdate) - 1)
			end
end as Days
from all_rcs_linked rcs
inner join months on months.num between 0 and months_between(trunc(rcs.enddate,'mon'), trunc(rcs.startdate,'mon'))
where 1=1
) a;

select count(1) into l_count from all_rcs_by_month;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Found RCs by month: ' || nvl(l_count, 0));
END IF;

insert into sum_rcs_by_month
(
InstanceId,
SubscriptionId,
PriceableItemTemplateId,
PriceableItemInstanceId,
Currency,
Year,
Month,
DaysInMonth,
DaysActiveInMonth,
TotalAmount,
OldAmount,
NewAmount
)
select
rcs.InstanceId,
rcs.SubscriptionId,
rcs.PriceableItemTemplateId,
rcs.PriceableItemInstanceId,
rcs.Currency,
rcs.Year,
rcs.Month,
case when rcs.Month in (4,6,9,11) then 30 when rcs.Month = 2 then case when mod(rcs.Year, 400) = 0 then 29 when mod(rcs.Year, 100) = 0 then 28 when mod(rcs.Year, 4) = 0 then 29 else 28 end else 31 end as DaysInMonth,
max(rcs.Days) as DaysActiveInMonth,
sum(cast(rcs.DailyRate*rcs.Days as numeric(18,6))) as TotalAmount,
sum(case when rcs.OldRate is null then cast(rcs.DailyRate*rcs.Days as numeric(18,6))
		 when rcs.Rate = rcs.OldRate then cast(rcs.DailyRate*rcs.Days as numeric(18,6))
         when rcs.DailyRate = 0 then cast(rcs.DailyRate*rcs.Days as numeric(18,6))
         else cast((rcs.DailyRate*rcs.Days)*(cast(rcs.OldRate/rcs.Rate as numeric(29,17))) as numeric(18,6))
    end) as OldAmount,
sum(case when rcs.OldSubscriptionEndDate is null then rcs.DailyRate*rcs.Days else 0 end) as NewAmount
from all_rcs_by_month rcs
where 1=1
group by
rcs.InstanceId,
rcs.SubscriptionId,
rcs.Currency,
rcs.PriceableItemTemplateId,
rcs.PriceableItemInstanceId,
rcs.Year,
rcs.Month
;

select count(1) into l_count from sum_rcs_by_month;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Summarized RCs by month: ' || nvl(l_count, 0));
END IF;

execute immediate 'create index idx_monthly_rcs on sum_rcs_by_month (InstanceId, SubscriptionId, PriceableItemTemplateId, PriceableItemInstanceId, Year, Month, Currency)';

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Created index for summarized subscriptions');
END IF;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Created index for exchange rates');
END IF;

insert into SubscriptionsByMonth
(	InstanceId,
	SubscriptionId,
	Year,
	Month,
	Currency,
	MRR,
	MRRPrimaryCurrency,
	MRRNew,
	MRRNewPrimaryCurrency,
	MRRBase,
	MRRBasePrimaryCurrency,
	MRRRenewal,
	MRRRenewalPrimaryCurrency,
	MRRPriceChange,
	MRRPriceChangePrimaryCurrency,
	MRRChurn,
	MRRChurnPrimaryCurrency,
	MRRCancelation,
	MRRCancelationPrimaryCurrency,
	SubscriptionRevenue,
	SubscriptionRevPrimaryCurrency,
	DaysInMonth,
	DaysActiveInMonth,
	ReportingCurrency
)
select cMonth.InstanceId,
	cMonth.SubscriptionId,
	cMonth.Year,
	cMonth.Month,
	cMonth.Currency,
	cMonth.TotalAmount as MRR,
	cMonth.TotalAmount*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRPrimaryCurrency,
	cMonth.NewAmount as MRRNew,
	cMonth.NewAmount*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRNewPrimaryCurrency,
	nvl(pMonth.TotalAmount,0) as MRRBase,
	nvl(pMonth.TotalAmount,0)*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRBasePrimaryCurrency,
	0 as MRRRenewal,
	0*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRRenewalPrimaryCurrency,
	(cMonth.TotalAmount - cMonth.OldAmount) as MRRPriceChange,
	(cMonth.TotalAmount - cMonth.OldAmount)*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRPriceChangePrimaryCurrency,
	0 as MRRChurn,
	0*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRChurnPrimaryCurrency,
	0 as MRRCancelation,
	0*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRCancelationPrimaryCurrency,
	0 as SubscriptionRevenue,
	0*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as SubscriptionRevPrimaryCurrency,
	cMonth.DaysInMonth,
	cMonth.DaysActiveInMonth,
	p_nm_currency
from sum_rcs_by_month cMonth
left outer join sum_rcs_by_month pMonth on  cMonth.InstanceId = pMonth.InstanceId
										 and cMonth.SubscriptionId = pMonth.SubscriptionId
										 and cMonth.PriceableItemTemplateId = pMonth.PriceableItemTemplateId
										 and cMonth.PriceableItemInstanceId = pMonth.PriceableItemInstanceId
										 and cMonth.Currency = pMonth.Currency
										 and case when cMonth.Month = 1 then cMonth.Year - 1 else cMonth.Year end = pMonth.Year
										 and case when cMonth.Month = 1 then 12 else cMonth.Month - 1 end = pMonth.Month
left outer join CurrencyExchangeMonthly exc on exc.InstanceId = cMonth.InstanceId and exc.SourceCurrency = cMonth.Currency and exc.TargetCurrency = p_nm_currency and p_dt_now between exc.StartDate and exc.EndDate
where 1=1
;

select count(1) into l_count from SubscriptionsByMonth;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Subscriptions by month: ' || nvl(l_count, 0));
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating SubscriptionSummary DataMart');
END IF;

insert into SubscriptionSummary
(	InstanceId,
	ProductOfferingId,
	Year,
	Month,
	TotalParticipants,
	DistinctHierarchies,
	NewParticipants,
	MRRPrimaryCurrency,
	MRRNewPrimaryCurrency,
	MRRBasePrimaryCurrency,
	MRRRenewalPrimaryCurrency,
	MRRPriceChangePrimaryCurrency,
	MRRChurnPrimaryCurrency,
	MRRCancelationPrimaryCurrency,
	SubscriptionRevPrimaryCurrency,
	DaysInMonth)
select
mrr.InstanceId,
sub.id_po as ProductOfferingId,
mrr.Year,
mrr.Month,
count(1) as TotalParticipants,
count(distinct cust.HierarchyMetraNetId) as DistinctHierarchies,
sum(case when (p_dt_now - sub.dt_start) <= 30 then 1 else 0 end) as NewParticipants,
sum(mrr.MRRPrimaryCurrency) as MRRPrimaryCurrency,
sum(mrr.MRRNewPrimaryCurrency) as MRRNewPrimaryCurrency,
sum(mrr.MRRBasePrimaryCurrency) as MRRBasePrimaryCurrency,
sum(mrr.MRRRenewalPrimaryCurrency) as MRRRenewalPrimaryCurrency,
sum(mrr.MRRPriceChangePrimaryCurrency) as MRRPriceChangePrimaryCurrency,
sum(mrr.MRRChurnPrimaryCurrency) as MRRChurnPrimaryCurrency,
sum(mrr.MRRCancelationPrimaryCurrency) as MRRCancelationPrimaryCurrency,
sum(mrr.SubscriptionRevPrimaryCurrency) as SubscriptionRevPrimaryCurrency,
mrr.DaysInMonth
from SubscriptionsByMonth mrr
inner join t_vw_effective_subs sub on sub.id_sub = mrr.SubscriptionId
inner join Customer cust on cust.InstanceId = mrr.InstanceId and cust.MetraNetId = sub.id_acc
where 1=1
group by mrr.InstanceId, mrr.Year, mrr.Month, sub.id_po, mrr.DaysInMonth
;

select count(1) into l_count from SubscriptionSummary;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Subscription summaries: ' || nvl(l_count, 0));
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating SubscriptionUnits DataMart');
END IF;

/* NOTE: this is UDRC''s not decision counters */
insert into SubscriptionUnits
(	InstanceId,
	SubscriptionId,
	StartDate,
	EndDate,
	UdrcId,
	UdrcName,
	UnitName,
	Units
)
select p_nm_instance as InstanceId,
rv.id_sub as SubscriptionId,
rv.vt_start as StartDate,
rv.vt_end as EndDate,
bp.id_prop as UdrcId,
nvl(bp.nm_display_name, bp.nm_name) as UdrcName,
nvl(rc.nm_unit_display_name, rc.nm_unit_name) as UnitName,
rv.n_value as Units
from t_recur_value rv
inner join t_base_props bp on bp.id_prop = rv.id_prop
inner join t_recur rc on rc.id_prop = rv.id_prop
where 1=1
and rv.tt_end = dbo.mtmaxdate()
;

select count(1) into l_count from SubscriptionUnits;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Subscription units: ' || nvl(l_count, 0));
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating ProductOffering DataMart');
END IF;

insert into ProductOffering
(	InstanceId,
	ProductOfferingId,
	ProductOfferingName,
	IsUserSubscribable,
	IsUserUnsubscribable,
	IsHidden,
	EffectiveStartDate,
	EffectiveEndDate,
	AvailableStartDate,
	AvailableEndDate)
select
p_nm_instance as InstanceId,
po.id_po as ProductOfferingId,
nvl(bp.nm_display_name, bp.nm_name) as ProductOfferingName,
po.b_user_subscribe as IsUserSubscribable,
po.b_user_unsubscribe as IsUserUnsubscribable,
po.b_hidden as IsHidden,
nvl(eff.dt_start, dbo.mtmindate()) as EffectiveStartDate,
nvl(eff.dt_end, dbo.mtmaxdate()) as EffectiveEndDate,
nvl(avl.dt_start, dbo.mtmindate()) as AvailableStartDate,
nvl(avl.dt_end, dbo.mtmaxdate()) as AvailableEndDate
from t_po po
inner join t_effectivedate eff on eff.id_eff_date = po.id_eff_date
inner join t_effectivedate avl on avl.id_eff_date = po.id_avail
inner join t_base_props bp on bp.id_prop = po.id_po
where 1=1
;

select count(1) into l_count from SubscriptionUnits;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Product Offerings: ' || nvl(l_count, 0));
  INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating SubscriptionParticipants DataMart');
END IF;

insert into tmp_previous_two_months(InstanceId,Month,Year,FirstDayOfMonth,LastDayOfMonth)
select
p_nm_instance as InstanceId,
extract(month from ADD_MONTHS(p_dt_now,0)) as Month,
extract(year from ADD_MONTHS(p_dt_now,0)) as Year,
TRUNC(ADD_MONTHS(p_dt_now,0),'MON') as FirstDayOfMonth,
TRUNC(ADD_MONTHS(p_dt_now,1),'MON')-1/60/60/24 as LastDayOfMonth
from dual
;
insert into tmp_previous_two_months(InstanceId,Month,Year,FirstDayOfMonth,LastDayOfMonth)
select
p_nm_instance as InstanceId,
extract(month from ADD_MONTHS(p_dt_now,-1)) as Month,
extract(year from ADD_MONTHS(p_dt_now,-1)) as Year,
TRUNC(ADD_MONTHS(p_dt_now,-1),'MON') as FirstDayOfMonth,
TRUNC(ADD_MONTHS(p_dt_now,0),'MON')-1/60/60/24 as LastDayOfMonth
from dual
;
insert into tmp_previous_two_months(InstanceId,Month,Year,FirstDayOfMonth,LastDayOfMonth)
select
p_nm_instance as InstanceId,
extract(month from ADD_MONTHS(p_dt_now,-2)) as Month,
extract(year from ADD_MONTHS(p_dt_now,-2)) as Year,
TRUNC(ADD_MONTHS(p_dt_now,-2),'MON') as FirstDayOfMonth,
TRUNC(ADD_MONTHS(p_dt_now,-1),'MON')-1/60/60/24 as LastDayOfMonth
from dual
;
insert into SubscriptionParticipants
(	InstanceId,
	ProductOfferingId,
	Year,
	Month,
	TotalParticipants,
	DistinctHierarchies,
	NewParticipants,
  UnsubscribedParticipants)
select
months.InstanceId,
sub.id_po as ProductOfferingId,
months.Year,
months.Month,
count(1) as TotalParticipants,
count(distinct cust.HierarchyMetraNetId) as DistinctHierarchies,
sum (case when sub.dt_start >= months.FirstDayOfMonth and sub.dt_start <= months.LastDayOfMonth then 1 else 0 end) as NewParticipants,
sum (case when sub.dt_end >= months.FirstDayOfMonth and sub.dt_end <= months.LastDayOfMonth then 1 else 0 end) as UnsubscribedParticipants
from t_vw_effective_subs sub
inner join Customer cust on cust.MetraNetId = sub.id_acc and cust.InstanceId = p_nm_instance
/*was this subscription active during any part of this month?*/
inner join tmp_previous_two_months months on (sub.dt_end >= months.FirstDayOfMonth and sub.dt_end <= months.LastDayOfMonth) or (sub.dt_start >= months.FirstDayOfMonth and sub.dt_start <= months.LastDayOfMonth) or (sub.dt_start <= months.FirstDayOfMonth and sub.dt_end >= months.LastDayOfMonth)
where 1=1
group by months.InstanceId, months.Year, months.Month, sub.id_po
;

select count(1) into l_count from SubscriptionParticipants;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'SubscriptionParticipants rows: ' || nvl(l_count, 0));
END IF;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Finished generating DataMart');
END IF;

end;
/

CREATE OR REPLACE PROCEDURE Addcountertype (
				id_lang_code INT,	n_kind INT,
				nm_name NVARCHAR2,
				nm_desc NVARCHAR2,
				nm_formula_template VARCHAR2,
				valid_for_dist CHAR,
				id_prop OUT INT)
				AS
				t_count INT;
				temp_nm_name VARCHAR2(255);
				temp_id_lang_code INT;
				identity_value INT;
				t_base_props_count INT;
				id_display_name INT;
				id_display_desc INT;
				BEGIN
					id_prop := -1;
					temp_nm_name := nm_name;
					temp_id_lang_code := id_lang_code;
					/* need to know if any records are there */
					SELECT COUNT(*) INTO t_base_props_count FROM T_BASE_PROPS
					WHERE T_BASE_PROPS.nm_name = temp_nm_name;
					SELECT COUNT(*) INTO t_count FROM t_vw_base_props
					WHERE t_vw_base_props.nm_name = temp_nm_name
					AND t_vw_base_props.id_lang_code = temp_id_lang_code;
					IF t_base_props_count != 0 THEN
 						id_prop := -1;
					END IF;
					IF t_count = 0
						THEN
						Insertbaseprops(id_lang_code, n_kind, 'N', 'N', nm_name, nm_desc, NULL, identity_value, id_display_name, id_display_desc);
						INSERT INTO T_COUNTER_METADATA (id_prop, FormulaTemplate, b_valid_for_dist)
						VALUES (identity_value, 				    nm_formula_template, valid_for_dist);
						id_prop := identity_value;
					END IF;
				END;
/

CREATE or replace PROCEDURE ANALYZE (p_table_name varchar2)
as
v_rows_changed number(10);
v_query varchar2(4000);
v_svctablename varchar2(255);
v_id_svc varchar2(10);
v_firstpass number(10);
l_cur       sys_refcursor;
ro rowid;
tx_uid1 t_acc_usage.tx_uid%TYPE;
begin
 /* mark the successful rows as analyzed.*/
 v_query := 'update ' || p_table_name ||         ' rr set tx_state = ''A''
        where exists (select 1 from t_acc_usage acc
                      where rr.id_sess = acc.id_sess and rr.id_interval = acc.id_usage_interval)
        and tx_state = ''I''';
  execute immediate v_query;
  /* set the id_parent_source_sess correctly for the children already */  /* identified by now (successful only)*/
  v_query := 'update ' || p_table_name || ' rr set id_parent_source_sess =
		  (select acc.tx_uid
		  from t_acc_usage acc
		  where rr.id_parent_sess = acc.id_sess
		  and acc.id_usage_interval = rr.id_interval
		  and acc.id_parent_sess is null)
		  where rr.id_parent_source_sess is null
		  and rr.tx_state = ''A''';
   execute immediate v_query;
   
   /* find parents for successful sessions*/
   v_query := 'insert into ' || p_table_name || ' (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
    select
            seq_' || p_table_name || '.NEXTVAL,
            tmp.tx_UID,    /* id_source_sess*/
            tmp.tx_batch,    /* tx_batch*/
            tmp.id_sess,    /* id_sess*/
            tmp.id_parent_sess,    /* id_parent*/
            null,                /* TODO: root*/
            tmp.id_usage_interval,    /* id_interval*/
            tmp.id_view,        /* id_view*/
            case aui.tx_status when ''H'' then ''C'' else ''A'' end, 
            tmp.id_svc,        /* id_svc*/
            NULL, /* id_parent_source_sess*/
            tmp.id_acc,
            tmp.amount,
            tmp.am_currency
        from  
            (select auparents.tx_uid, auparents.tx_batch, auparents.id_sess, auparents.id_parent_sess,
            auparents.id_usage_interval, auparents.id_view, auparents.id_svc, auparents.id_acc, auparents.amount,
            auparents.am_currency  from t_acc_usage auparents
            inner join ' || p_table_name || ' rr
            on rr.id_parent_sess = auparents.id_sess
            and auparents.id_usage_interval = rr.id_interval
            group by auparents.id_parent_sess, auparents.tx_uid, auparents.tx_batch, auparents.id_sess, auparents.id_parent_sess,
            auparents.id_usage_interval, auparents.id_view, auparents.id_svc, auparents.id_acc, auparents.amount,
            auparents.am_currency) tmp
            inner join t_acc_usage_interval aui on tmp.id_usage_interval = aui.id_usage_interval
            and tmp.id_acc = aui.id_acc
        where not exists (select 1 from '|| p_table_name || ' rr1 where rr1.id_sess = tmp.id_sess and tmp.id_usage_interval =rr1.id_interval)' ;
    execute immediate v_query;

    /* find children for successful sessions*/
    v_query := 'insert into ' || p_table_name || ' (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root,
						id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
            select
            seq_' || p_table_name || '.NEXTVAL,
            au.tx_UID,	/* id_source_sess*/
            au.tx_batch,	/* tx_batch*/
            au.id_sess,	/* id_sess*/
            au.id_parent_sess,	/* id_parent*/
            null,			/* TODO: root*/
            au.id_usage_interval,	/* id_interval*/
            au.id_view,		/* id_view*/
            case aui.tx_status when ''H'' then ''C'' else ''A'' end, /* tx_state*/
            au.id_svc,	/* id_svc*/
            rr.id_source_sess, /* id_parent_source_sess*/
						au.id_acc,
						au.amount,
			      au.am_currency
            from t_acc_usage au
            inner join ' || p_table_name || ' rr on au.id_parent_sess = rr.id_sess
            			and au.id_usage_interval = rr.id_interval
            inner join t_acc_usage_interval aui on au.id_usage_interval = aui.id_usage_interval
                  and aui.id_acc = au.id_acc
            where not exists (select 1 from ' || p_table_name || ' rr1 where rr1.id_sess = au.id_sess and rr1.id_interval = au.id_usage_interval)';

    execute immediate v_query;
    
    v_rows_changed := 1;
    v_firstpass := 1;
    /* complete the compound for failure cases.  In t_failed_transaction, you will have only the failed*/
    /* portion of the failed transaction. */
    while (v_rows_changed > 0)
    loop
        v_rows_changed := 0;
        If (v_firstpass = 1) then
            v_firstpass := 0;
        end if;
        /* find children for failed parent sessions*/
        /* this query gives us the tables where the children for the parents identified may live.*/
         v_query :=  'select distinct slog.nm_table_name, cast(ed.id_enum_data as nvarchar2(10))
				from ' || p_table_name || '  rr
				inner join t_failed_transaction ft
				on rr.id_source_sess = ft.tx_failureCompoundID
				inner join t_session_set ss
				on ss.id_ss = ft.id_sch_ss
                inner join t_session_set childss
				on ss.id_message = childss.id_message
				inner join t_enum_data ed
				on ed.id_enum_data = childss.id_svc
				inner join t_service_def_log slog
				on upper(ed.nm_enum_data) = upper(slog.nm_service_def)
				where id_parent_source_sess is null and tx_state = ''E''
				and childss.b_root = ''0''';
         OPEN l_cur for v_query;
         loop
            FETCH l_cur into v_svctablename, v_id_svc;
            exit when l_cur%NOTFOUND;
            dbms_output.put_line( v_svctablename);
            v_query := 'insert into ' || p_table_name || ' (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
			select 
			seq_' || p_table_name || '.NEXTVAL,
			conn.id_source_sess,	/* id_source_sess*/
			conn.c__CollectionID,	/* tx_batch*/
			NULL,	/* id_sess*/
			NULL,	/* id_parent_sess*/
			NULL,			/* TODO: root*/
			NULL,	/* id_interval*/
			NULL,		/* id_view*/
			''E'',			/* tx_state*/
			'|| v_id_svc || ' , 	/* id_svc*/
			conn.id_parent_source_sess,
			NULL,			 /* payer */	
			NULL,
			NULL
			from ' || p_table_name || ' rr
			inner join ' || v_svctablename || ' conn
			on rr.id_source_sess = conn.id_parent_source_sess
			where rr.id_parent_source_sess is null and tx_state = ''E''
			and not exists (select * from ' || p_table_name || ' where ' ||  p_table_name || '.id_source_sess = conn.id_source_sess)';
            execute immediate v_query;
            v_rows_changed := v_rows_changed + SQL%ROWCOUNT;
         END loop;
         CLOSE l_cur;
         /* find parents for failed children sessions*/
         /* this query gives us all the svc tables in which the parents may live*/
          v_query :=  'select distinct slog.nm_table_name, cast(ed.id_enum_data as nvarchar2(10))
				from ' || p_table_name || ' rr
				inner join t_failed_transaction ft
				on rr.id_source_sess = ft.tx_failureID
				inner join t_session_set ss
				on ss.id_ss = ft.id_sch_ss
				inner join t_session_set parentss
				on ss.id_message = parentss.id_message
				inner join t_enum_data ed
				on ed.id_enum_data = parentss.id_svc
				inner join t_service_def_log slog
				on upper(ed.nm_enum_data) = upper(slog.nm_service_def)
				where id_parent_source_sess is not null
				and tx_state = ''E''
				and ss.id_svc <> parentss.id_svc
				and parentss.b_root = ''1''';
          OPEN l_cur for v_query;
          loop
            FETCH l_cur into v_svctablename, v_id_svc;
            exit when l_cur%NOTFOUND;
            dbms_output.put_line( v_svctablename);
            v_query := 'insert into ' || p_table_name || ' (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
			 select
			 seq_' || p_table_name || '.NEXTVAL,
			 call.id_source_sess,	/* id_source_sess*/
			 call.c__CollectionID,	/* tx_batch*/
			 NULL,	/* id_sess*/
			 NULL,	/* id_parent_sess*/
			 NULL,			/* TODO: root*/
			 NULL,	/* id_interval*/
			 NULL,		/* id_view*/
			 ''E'',			/* tx_state */
			 '|| v_id_svc || ' , 	/* id_svc*/
			 call.id_parent_source_sess,
			 null, /* id_payer */	
			 null,
			 null
			 from ' || p_table_name || ' rr
			 inner join ' || v_svctablename || ' call
			 on rr.id_parent_source_sess = call.id_source_sess
			 where rr.id_parent_source_sess is not null and tx_state = ''E''
			 and not exists (select * from ' || p_table_name || ' where ' ||  p_table_name || '.id_source_sess = call.id_source_sess)';
            execute immediate v_query;
            v_rows_changed := v_rows_changed + SQL%ROWCOUNT;
          END loop;
          CLOSE l_cur;
    end loop;
    
    /* handle suspended and pending transactions.  We know we will have identified   all suspended and pending parents.  Only children need to be looked at.   following query tells us which tables to look for the children   changing the cursor query.. for whatever reason,it takes too long, even when there are    no suspended transactions (CR: 13059) */
    v_query :=  ' select distinct slog.nm_table_name , cast(ss2.id_svc as nvarchar2(10))
			 from t_session_set ss2
			 inner join t_enum_data ed
			 on ss2.id_svc = ed.id_enum_data
			 inner join t_service_def_log slog
			 on upper(ed.nm_enum_data) = upper(slog.nm_service_def)
			 where id_message in (
			 select ss.id_message from ' || p_table_name || ' rr
			 inner join t_session sess
			 on sess.id_source_sess = rr.id_source_sess
			 inner join t_session_set ss
			 on sess.id_ss = ss.id_ss
			 inner join t_message msg
			 on msg.id_message = ss.id_message
			 where rr.tx_state = ''NC'')
			 and ss2.b_root = ''0''';
    OPEN l_cur for v_query;
    loop
        FETCH l_cur into v_svctablename, v_id_svc;
        exit when l_cur%NOTFOUND;
                dbms_output.put_line( v_svctablename);
                v_query := ' insert into ' || p_table_name || ' (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
				    select seq_' || p_table_name || '.NEXTVAL, svc.id_source_sess, null,
				    null, null, null, null, null, ''NA'', ' || v_id_svc || ' , rr.id_source_sess, null, null, null
			        from ' || p_table_name || ' rr
			        inner join ' || v_svctablename || ' svc
				    on rr.id_source_sess = svc.id_parent_source_sess
				    where rr.tx_state = ''NC''
				    and svc.id_source_sess not in (select id_source_sess from ' || p_table_name || ')';
                execute immediate v_query;
    END loop;
    CLOSE l_cur;
            
    v_query :=  'update ' || p_table_name || '
	             set tx_state = ''NA'' where
	             tx_state = ''NC''';
    execute immediate v_query;
end;
/    

ALTER TYPE activebillrunwidgettbltype COMPILE;

CREATE OR REPLACE package body active_bill_run_pkg as
FUNCTION GetActvCurAverage(v_id_interval int)
  return ActiveBillRunWidgetTable PIPELINED IS
  p_returnTable ActiveBillRunWidgetTblType := ActiveBillRunWidgetTblType(null, null, null, null);
  
  p_result sys_refcursor;
  l_tbl_count NUMBER;  
  l_interval_id int;
  
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
							  rer.dt_start dt_start, 
							  ROUND((rer.dt_end - rer.dt_start) * 86400,0) duration, 
							  0.0 as three_month_avg
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
													  and ui.id_usage_cycle = (select id_usage_cycle from t_usage_interval where id_interval = ' || l_interval_id || '))
							and rer.tx_type = ''Execute''
              and rer.dt_start = (select max(dt_start) from t_recevent_run where id_instance = rer.id_instance)
							and (rer.tx_detail not like ''Manually changed status%'' or rer.tx_detail is null)
							group by rei.id_arg_interval, tx_display_name, rer.dt_start, rer.dt_end
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

ALTER TYPE id_rec COMPILE;

ALTER TYPE billgroupdesc_results_rec COMPILE;

ALTER TYPE retcompatibleevent COMPILE;

ALTER TYPE retdescendents COMPILE;

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

CREATE OR REPLACE FORCE VIEW vw_bus_partition_accounts (id_acc,id_partition,partition_name,partition_nm_space) AS
SELECT      aa.id_descendent id_acc,
              a.id_acc id_partition,
              am.nm_login partition_name,
              am.nm_space partition_namespace
  FROM        t_account a
        INNER JOIN t_account_type at ON a.id_type = at.id_type
        INNER JOIN t_account_ancestor aa ON a.id_acc = aa.id_ancestor and aa.vt_end >= TO_DATE('2038-01-01', 'YYYY-MM-DD')
        INNER JOIN t_account_mapper am on am.id_acc = a.id_acc
  WHERE       at.name = 'Partition';

COMMENT ON TABLE vw_bus_partition_accounts IS 'The view gets list of business partition accounts and it consists of four tables "t_account", "t_account_type", "t_account_ancestor" and "t_account_mapper" ';

ALTER PROCEDURE meterinitialfromrecurwindow COMPILE;

ALTER PROCEDURE meterudrcfromrecurwindow COMPILE;

ALTER FUNCTION metratime COMPILE;

ALTER FUNCTION allowinitialarrerscharge COMPILE;

CREATE OR REPLACE TRIGGER TRG_UPDATE_REC_WIND_ON_REC_VAL
  FOR INSERT OR UPDATE ON T_RECUR_VALUE
    COMPOUND TRIGGER

  startDate DATE;
  v_id_sub INTEGER;
  v_QuoteBatchId raw(16);
  num_notnull_quote_batchids INTEGER;

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
     
      SELECT sub.TX_QUOTING_BATCH INTO v_QuoteBatchId
		  FROM t_sub sub
		  WHERE sub.id_sub = :new.id_sub
			AND ROWNUM = 1;
    END IF;

  END AFTER EACH ROW;


  AFTER STATEMENT IS BEGIN

    IF sql%rowcount != 0 THEN
      /*TODO: look at MSSQL version... now it different */
      SELECT metratime(1,'RC') INTO startDate FROM dual;
      
      IF v_QuoteBatchId is not null THEN
        num_notnull_quote_batchids := 1;
      ELSE
        num_notnull_quote_batchids := 0;
      END IF;

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
          1 c__IsAllowGenChargeByTrigger,
          c__QuoteBatchId
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
        SET     rw.c_SubscriptionStart   = cur_sub.vt_start, rw.c_SubscriptionEnd   = cur_sub.vt_end,
                rw.c_CycleEffectiveStart = cur_sub.vt_start, rw.c_CycleEffectiveEnd = cur_sub.vt_end;

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
          AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, startDate, num_notnull_quote_batchids) c__IsAllowGenChargeByTrigger,
          sub.TX_QUOTING_BATCH c__QuoteBatchId
          FROM t_sub sub
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
          AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, gsm.vt_end, startDate, num_notnull_quote_batchids) c__IsAllowGenChargeByTrigger,
          sub.TX_QUOTING_BATCH c__QuoteBatchId
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
          AllowInitialArrersCharge(rcr.b_advance, pay.id_payee, sub.vt_end, null, num_notnull_quote_batchids) c__IsAllowGenChargeByTrigger,
          sub.TX_QUOTING_BATCH c__QuoteBatchId
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
          c_MembershipEnd,
          c__QuoteBatchId
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


ALTER PROCEDURE mtsp_generate_stateful_rcs COMPILE;

ALTER PROCEDURE updatechangedetails COMPILE;

ALTER PROCEDURE updateapproval COMPILE;

ALTER PROCEDURE isapprovalpending COMPILE;

ALTER PROCEDURE dismissapproval COMPILE;

ALTER PROCEDURE denyapproval COMPILE;

ALTER PROCEDURE approvalupdatechangestate COMPILE;

ALTER PROCEDURE moveaccount2 COMPILE;

ALTER PROCEDURE applytemplatetooneaccount COMPILE;

ALTER PROCEDURE startuserdefinedgroupcreation COMPILE;

ALTER PROCEDURE updatebillinggroupstatus COMPILE;

ALTER PROCEDURE hardclosebillinggroup COMPILE;

ALTER PROCEDURE openbillinggroup COMPILE;

ALTER PROCEDURE softclosebillinggroups COMPILE;

ALTER PROCEDURE mtsp_insertinvoice_balances COMPILE;

ALTER PROCEDURE mtsp_insertinvoice COMPILE;

ALTER PROCEDURE mtsp_backoutinvoices COMPILE;

ALTER PROCEDURE startchildgroupcreation COMPILE;

ALTER PROCEDURE satisfyconstraintsforpulllist COMPILE;

ALTER PROCEDURE validatebillgroupassignments COMPILE;

ALTER PROCEDURE copyadapterinstances COMPILE;

ALTER PROCEDURE updategroupsubscription COMPILE;

ALTER PROCEDURE creategroupsubscription COMPILE;

