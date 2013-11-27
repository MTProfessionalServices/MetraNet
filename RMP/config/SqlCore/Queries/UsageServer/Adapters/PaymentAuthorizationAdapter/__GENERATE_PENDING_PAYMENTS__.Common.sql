
-- Generate the list of accounts and payment instruments to be processed for this bill group in this interval
payment_instruments:select[baseQuery="%%SELECT_STATEMENT%%"];

-- spread the balance out accross the user's payment instruments based on the max_amount_per_cycle limit assigned to the cards (if any)
payment_distributor:hash_running_total[key="id_acc", outputGroupBy=TRUE, preIncrement=TRUE,
initialize="
CREATE PROCEDURE initializeDistributor 
	@amtToCharge DECIMAL OUTPUT
	@totalCharged DECIMAL OUTPUT
	@invoiceBalance DECIMAL OUTPUT
AS
		SET @amtToCharge = 0.0
		SET @totalCharged = 0.0
		SET @invoiceBalance = 0.0", 
	update="
CREATE PROCEDURE updateAmounts 
	@current_balance DECIMAL
	@n_max_charge_per_cycle DECIMAL
	@amtToCharge DECIMAL OUTPUT
	@totalCharged DECIMAL OUTPUT
	@invoiceBalance DECIMAL OUTPUT
AS
	SET @invoiceBalance = @current_balance
	   
	IF(@current_balance > 0.0)
	BEGIN
		IF(@totalCharged < @current_balance)	
		BEGIN
	    		IF( @n_max_charge_per_cycle is null)
				BEGIN
        		SET @amtToCharge = @current_balance - @totalCharged
				SET @totalCharged = @current_balance	
				END
				ELSE       
				BEGIN
	        		IF( @current_balance - @totalCharged > @n_max_charge_per_cycle )
					BEGIN
	            		SET @amtToCharge = @n_max_charge_per_cycle
						SET @totalCharged = @totalCharged + @amtToCharge
					END
					ELSE
					BEGIN
	            		SET @amtToCharge = @current_balance - @totalCharged
						SET @totalCharged = @current_balance
					END
				END	
		END
		ELSE
		BEGIN
			SET @amtToCharge = 0.0
		END
	END
	ELSE
	BEGIN
	   if(@totalCharged <> @current_balance)
	   BEGIN
			SET @amtToCharge = @current_balance
			SET @totalCharged = @current_balance
	   END
	   ELSE
	   BEGIN
		  SET @amtToCharge = 0.0
	   END
	END
"];
	   
-- Route the group-by rows to the error handling branch so that caller can be notified
-- if user account can't cover it's balance based on the max_amount_per_cycle assigned
-- to its credit cards
groupby_route:switch[program="
CREATE FUNCTION routeGroupByRecords (@id_acc INTEGER) RETURNS INTEGER AS
	RETURN CASE WHEN @id_acc IS NULL THEN 1 ELSE 0 END
"];

control_copy:copy[];

-- insert records into table in Staging DB so that they can be put into t_pending_payment_trans
prep_upsert:insert[table="tmp_pending_payments", createTable=TRUE, transactionKey="id_commit_unit"];

-- Set up control program for SQL Exec Direct
upsert_control:sort_group_by[key="id_commit_unit", 
initialize="
CREATE PROCEDURE i @size_0 INTEGER
AS
SET @size_0 = 0",
update="
CREATE PROCEDURE u @size_0 INTEGER
AS
SET @size_0 = @size_0 + 1"];

-- Upsert code
upsert_exec:sql_exec_direct[
statementList=[query="%%UPSERT_STATEMENT%%", postprocess="DROP TABLE %%STAGINGDB%%.%1%"]
];


-- Filter out the group-by records where the balance is fully covered (non-errors)
process_errors:filter[program="
CREATE FUNCTION filter_errors (@invoiceBalance DECIMAL, @totalCharged DECIMAL) RETURNS BOOLEAN AS
	RETURN CASE WHEN @totalCharged <> @invoiceBalance THEN TRUE ELSE FALSE END
"];

-- Rename the internal column so that it can be included in the error output
rename_err_cols:rename[from="id_acc#", to="failed_acc"];

-- Reduce the columns in the error output
project_err_cols:projection[
column="failed_acc",
column="totalCharged",
column="invoiceBalance"];

-- Export the error output to the datatable specified by the caller
export_errors:export_queue[queueName="%%ERROR_QUEUE%%"];	

--printer:print[numToPrint=1000];

-- Put together the entire program
payment_instruments -> payment_distributor -> groupby_route;
groupby_route(0) -> control_copy;
groupby_route(1) -> process_errors -> rename_err_cols -> project_err_cols -> export_errors;

control_copy(0) -> prep_upsert -> upsert_exec("input(0)");
control_copy(1) -> upsert_control -> upsert_exec("control");
								