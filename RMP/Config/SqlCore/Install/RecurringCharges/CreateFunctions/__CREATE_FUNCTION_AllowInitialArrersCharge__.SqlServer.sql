CREATE FUNCTION AllowInitialArrersCharge(@b_advance char, @id_acc int, @sub_end datetime, @current_date datetime, @isQuote int = 0) RETURNS bit
AS
BEGIN
	IF @b_advance = 'Y'
	BEGIN
	   /* allows to create initial for ADVANCE */
		RETURN 1
	END

	IF @isQuote > 0
	BEGIN
	   /* disable to create initial for ARREARS in case of quote */
		RETURN 0
	END

	IF @current_date IS NULL
		SET @current_date = dbo.metratime(1,'RC')
		
	/* Creates Initial charges in case it fits inder current interval*/
	IF EXISTS (select 1 from t_usage_interval us_int
				join t_acc_usage_cycle acc
				on us_int.id_usage_cycle = acc.id_usage_cycle
				where acc.id_acc = @id_acc
				AND @current_date BETWEEN DT_START AND DT_END
				AND @sub_end BETWEEN DT_START AND DT_END)
				
		RETURN 1

	RETURN 0
END