
	   CREATE TABLE t_inv_summ_children (
		id_sess bigint NOT NULL,
		id_parent_sess bigint NULL,
		id_acc int NOT NULL,
		id_view int NOT NULL,
		tx_view_name varchar (255) NOT NULL,
		tx_view_description nvarchar (255) NULL,
		id_usage_interval int NOT NULL,
		confconn_amount numeric(22,10) NOT NULL,
		confconn_tax_federal numeric(22,10) NULL,
		confconn_tax_state numeric(22,10) NULL,
		confconn_tax_county numeric(22,10) NULL,
		confconn_tax_local numeric(22,10) NULL,
		confconn_tax_other numeric(22,10) NULL,
		id_invoice int NULL,
		invoice_string varchar (50) NULL,
		c_ConferenceID nchar (30) NULL,
		c_ParticipantName nchar (60) NULL,
		c_ActualStartTime datetime NULL,
		c_ActualEndtime datetime NULL,
		c_UserRole nvarchar (255) NULL,
		c_CallType nvarchar (255) NULL,
		c_Transport nvarchar (255) NULL)

	  