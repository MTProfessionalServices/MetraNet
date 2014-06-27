
        create table t_adjustment_transaction (
        id_adj_trx int not null,
        id_sess bigint null,
        id_parent_sess bigint null,
        id_reason_code int not null,
        id_acc_creator INT NOT NULL,
        id_acc_payer INT NOT NULL,
        c_status VARCHAR(10) NOT NULL,
        -- Prebill  or postbill
        n_adjustmenttype INT NOT NULL,
        dt_crt DATETIME NOT NULL,
        dt_modified DATETIME NOT NULL,
        id_aj_template INT NULL,
        id_aj_instance INT NULL,
        id_aj_type INT NOT NULL,
        id_usage_interval INT NOT NULL,
        AdjustmentAmount NUMERIC(22,10) NOT NULL,
        aj_tax_federal NUMERIC(22,10) NOT NULL,
        aj_tax_state NUMERIC(22,10) NOT NULL,
        aj_tax_county NUMERIC(22,10) NOT NULL,
        aj_tax_local NUMERIC(22,10) NOT NULL,
        aj_tax_other NUMERIC(22,10) NOT NULL,
        am_currency nvarchar(3) NOT NULL,
        tx_default_desc nvarchar(1900) NULL,
        tx_desc nvarchar(1900) NULL,
        ARBatchID varchar(15) NULL,
        ARDelBatchID varchar(15) NULL,
        ARDelAction char(1) NULL,
        archive_sess int,
        div_currency nvarchar(3) NULL,
        div_amount numeric(22,10) NULL,
        constraint pk_t_adjustment_transaction primary key(id_adj_trx),
        CONSTRAINT aj_trxcheck CHECK 	(id_aj_template IS NOT NULL OR id_aj_instance IS NOT NULL))
		
		 
        create index idx_adj_txn_dt_crt_ndel_usage on t_adjustment_transaction 
        (dt_crt, c_status, id_sess) 
