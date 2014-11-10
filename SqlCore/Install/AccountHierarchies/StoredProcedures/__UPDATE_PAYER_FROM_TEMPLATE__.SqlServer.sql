CREATE PROCEDURE UpdatePayerFromTemplate (
	@IdAcc INTEGER
	,@PayerId INTEGER
	,@systemDate DATETIME
	,@PaymentStart DATETIME
	,@PaymentEnd DATETIME
	,@OldPayerId INTEGER
	,@p_account_currency NVARCHAR(5)
	,@errorStr NVARCHAR(4000) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @PayerExists INTEGER
	SELECT @PayerExists = COUNT(*) FROM t_account where id_acc = @PayerID
	IF (@PayerExists <> 0)
	BEGIN
		IF (@PayerID <> -1)
		BEGIN
		DECLARE @payerenddate DATETIME
		DECLARE @p_status INTEGER
		SET @p_status = 0
		SELECT @payerenddate = dbo.MTMaxDate()
			IF (@PayerID = @OldPayerId)
			BEGIN
				EXEC UpdatePaymentRecord @payerID,@IdAcc,@PaymentStart,@PaymentEnd,@systemDate,@payerenddate,@systemDate,1, @p_account_currency, @p_status output
				if (@p_status <> 1)
				begin
					SET @errorStr = 'No payment record changed for account. Return code is ' + CAST(@p_status AS NVARCHAR(255))
					SET @p_status = 0
				end
			end
			else
			begin
				DECLARE @payerbillable NVARCHAR(1)
				select @payerbillable = dbo.IsAccountBillable(@PayerID)
				exec CreatePaymentRecord @payerID,@IdAcc,@systemDate,@payerenddate,@payerbillable,@systemDate,'N', 1, @p_account_currency, @p_status output
				if (@p_status <> 1)
				begin
					SET @errorStr = 'No payment record created for account. Return code is ' + CAST(@p_status AS NVARCHAR(255))
					SET @p_status = 0
				end
			end
		END
	END
END
