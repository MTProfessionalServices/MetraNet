BEGIN 
    EXECUTE IMMEDIATE 'create table t_adjustment_transaction ( 
        id_adj_trx NUMBER(10) not null, 
        id_sess NUMBER(20) null, 
        id_parent_sess NUMBER(20) null, 
        id_reason_code NUMBER(10) not null, 
        id_acc_creator NUMBER(10) NOT NULL, 
        id_acc_payer NUMBER(10) NOT NULL, 
        c_status VARCHAR2(10) NOT NULL, 
        n_adjustmenttype NUMBER(10) NOT NULL, 
        dt_crt DATE NOT NULL, 
        dt_modified DATE NOT NULL, 
        id_aj_template NUMBER(10) NULL, 
        id_aj_instance NUMBER(10) NULL, 
        id_aj_type NUMBER(10) NOT NULL, 
        id_usage_interval NUMBER(10) NOT NULL, 
        AdjustmentAmount NUMBER(22,10) NOT NULL, 
        aj_tax_federal NUMBER(22,10) NOT NULL, 
        aj_tax_state NUMBER(22,10) NOT NULL, 
        aj_tax_county NUMBER(22,10) NOT NULL, 
        aj_tax_local NUMBER(22,10) NOT NULL, 
        aj_tax_other NUMBER(22,10) NOT NULL, 
        am_currency nvarchar2(3) NOT NULL, 
        tx_default_desc nvarchar2(1900) NULL, 
        tx_desc nvarchar2(1900) NULL, 
        ARBatchID varchar2(15) NULL, 
        ARDelBatchID varchar2(15) NULL, 
        ARDelAction char(1) NULL, 
        archive_sess NUMBER(10), 
        div_currency nvarchar2(3) NULL, 
        div_amount number(22,10) NULL, 
        CONSTRAINT PK_T_ADJUSTMENT_TRANSACTION PRIMARY KEY(ID_ADJ_TRX), 
        CONSTRAINT aj_trxcheck CHECK  (id_aj_template IS NOT NULL OR id_aj_instance IS NOT NULL) 
    )'; 
    EXECUTE IMMEDIATE 'create index idx_adj_txn_dt_crt_ndel_usage on t_adjustment_transaction 
        (dt_crt, UPPER(c_status), id_sess)'; 
END; 
	        