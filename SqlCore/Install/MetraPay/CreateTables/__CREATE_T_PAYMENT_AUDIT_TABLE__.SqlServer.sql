
        CREATE TABLE t_payment_audit (
          id_audit int identity(1,1) NOT NULL,
		      id_acc int NOT NULL, 
          nm_action nvarchar(255) NOT NULL, 
          nm_routingnumber nvarchar(9) NULL, 
          nm_lastfourdigits nvarchar(4) NULL, 
          nm_accounttype nvarchar(64) NULL, 
          nm_bankname nvarchar(40) NULL, 
          nm_expdate nvarchar(20) NULL, 
          id_expdatef int NULL,
          dt_occurred datetime NOT NULL DEFAULT GetUTCDate(),
          tx_IP_subscriber nvarchar(20) NULL,
          tx_phone_number nvarchar(30) NULL,
          tx_IP_CSR nvarchar(20) NULL,
          id_CSR nvarchar(20) NULL,
          tx_notes nvarchar(255) NULL,
          CONSTRAINT PK_T_PAYMENT_AUDIT PRIMARY KEY CLUSTERED (id_audit))
      
