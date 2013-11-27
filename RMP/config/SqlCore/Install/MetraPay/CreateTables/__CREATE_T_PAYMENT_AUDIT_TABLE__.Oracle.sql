
        CREATE TABLE t_payment_audit (
					id_audit number(10) NOT NULL,
          id_acc number(10) NOT NULL, 
          nm_action nvarchar2(255) NOT NULL, 
          nm_routingnumber nvarchar2(9) NULL, 
          nm_lastfourdigits nvarchar2(4) NULL, 
          nm_accounttype nvarchar2(64) NULL, 
          nm_bankname nvarchar2(40) NULL, 
          nm_expdate nvarchar2(20) NULL, 
          id_expdatef number(10) NULL,
          dt_occurred date not null, 
          tx_IP_subscriber nvarchar2(20) NULL,
          tx_phone_number nvarchar2(30) NULL,
          tx_IP_CSR nvarchar2(20) NULL,
          id_CSR nvarchar2(20) NULL,
          tx_notes nvarchar2(255) NULL,
          CONSTRAINT PK_T_PAYMENT_AUDIT PRIMARY KEY (id_audit))
      
