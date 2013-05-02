
		  CREATE TABLE t_ps_preauth (
		  id_preauth_tx_id [nvarchar](72) NOT NULL,
		  id_pymt_instrument nvarchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  dt_transaction datetime NOT NULL,
		  nm_description nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		  n_currency nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  n_amount numeric(22,10) NOT NULL,
		  n_request_params nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  nm_ar_request_id nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
		  CONSTRAINT PK_t_ps_preauth PRIMARY KEY CLUSTERED
		  (
		  id_preauth_tx_id
		  ))
	  