-- settings for this run
declare @MinInvNum as int
declare @MaxInvNum as int
declare @id_acc as int
declare @id_interval as int

set @MinInvNum = 10000
set @MaxInvNum = 11000
set @id_acc = 139
set @id_interval = 1000

-- loop from @id_invoice_min to max and insert a row into t_invoice for each
declare @InvNum as int
set @InvNum = @MinInvNum
while (@InvNum <= @MaxInvNum) begin

	insert into t_invoice values (
	'mt',			-- namespace
	@InvNum,		-- invoice_string
	@id_interval,		-- id_interval
	@id_acc,		-- id_acc
	100,			-- invoice_amount
	2002-08-01,		-- invoice_date
	2002-08-15,		-- invoice_due_date
	@InvNum,	 	-- id_invoice_num
	'USD',			-- invoice_currency
	-10,			-- payment_ttl_amt
	-5,			-- postbill_adj_ttl_amt
	10,			-- ar_adj_ttl_amt
	5,			-- tax_ttl_amt
	1000,                   -- current_balance
	@id_acc,		-- id_payer
	@id_interval		-- id_payer_interval
	)

	set @InvNum = @InvNum + 1
end

select * from t_invoice where id_interval = @id_interval
