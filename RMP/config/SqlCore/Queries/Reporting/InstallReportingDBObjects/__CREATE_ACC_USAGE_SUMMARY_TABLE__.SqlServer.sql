
	   CREATE TABLE t_acc_usage_summ (
		id_sess bigint NOT NULL,
		id_acc int NOT NULL,
		id_view int NOT NULL,
		id_usage_interval int NOT NULL,
		call_count int NULL,
		amount numeric(22,10) NOT NULL,
		am_currency nvarchar(3) NOT NULL,
		dt_crt datetime NULL,
		tax_federal numeric(22,10) NULL,
		tax_state numeric(22,10) NULL,
		tax_county numeric(22,10) NULL,
		tax_local numeric(22,10) NULL,
		tax_other numeric(22,10) NULL,
		view_desc nvarchar (255) NULL)
	     