
IF NOT EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 't_payment_history_details')
BEGIN
CREATE TABLE t_payment_history_details (

				id_payment_transaction nvarchar(72)NOT NULL,
				id_payment_history_details int NOT NULL,
				nm_invoice_num nvarchar(50) NOT NULL,
				dt_invoice_date datetime NOT NULL,
				nm_po_number nvarchar(30) NULL,
				n_amount decimal(18,2) NULL

				CONSTRAINT PK_t_pending_history_details PRIMARY KEY CLUSTERED

				(
					id_payment_transaction,
					id_payment_history_details
				))
END;


IF EXISTS (select 1 from syscolumns where name = 'nm_invoice_num'
and id = OBJECT_ID('t_payment_history'))
BEGIN
 
	EXECUTE ('INSERT INTO t_payment_history_details
	select 
	id_payment_transaction,
	1,
	nm_invoice_num,
	dt_invoice_date,
	nm_po_number,
	n_amount
	from t_payment_history');
	
	alter table t_payment_history drop column nm_invoice_num, dt_invoice_date , nm_po_number; 
	
END;


IF NOT EXISTS (select 1 from syscolumns where name = 'dt_invoice'
and id = OBJECT_ID('t_pending_ACH_trans_details'))
BEGIN
       
    ALTER TABLE dbo.t_pending_ACH_trans_details ADD
	dt_invoice datetime NULL,
	nm_po_number nvarchar(30) NULL;
END;