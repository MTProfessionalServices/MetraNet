
create sequence seq_t_billingserver start with 1 increment by 1 nocache order nocycle;
CREATE TABLE t_billingserver
(
    id_billingserver number(10) NOT NULL,
    tx_machine nvarchar2(128) NOT NULL,
    n_MaxConcurrentAdapters number (10) , /* Directly from config */
    b_OnlyRunAssignedAdapters char(1) , /* Directly from config */
    b_CanCreateScheduledEvents char(1) , /* Directly from config */
    b_CanCreateIntervals char(1) , /* Directly from config */
    b_CanSoftCloseIntervals char(1), /* Directly from config */
    b_WillCreateScheduledEvents char(1) ,
    b_WillCreateIntervals char(1) ,
    b_WillSoftCloseIntervals char(1) ,
    n_ProcessEventsPeriod number(10) , /* Directly from config */
    b_online char(1) NOT NULL, /* Copied from t_pipeline: Not sure if needed as I assume this can be normalized by checking t_billingserver_service table */
    b_paused char(1) NOT NULL, /* Not set through config; set at runtime */
        CONSTRAINT UK_1_t_billingserver UNIQUE (tx_machine)
);

