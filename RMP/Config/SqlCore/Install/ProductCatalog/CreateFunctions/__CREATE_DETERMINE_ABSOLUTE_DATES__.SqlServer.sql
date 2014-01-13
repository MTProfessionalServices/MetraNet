CREATE FUNCTION determine_absolute_dates(
	@v_date datetime,
	@my_date_type int,
	@my_date_offset int,
	@my_id_acc int,
	@is_start int
) returns datetime
as
begin
	DECLARE @my_date datetime
	DECLARE @my_acc_start datetime
	DECLARE @curr_id_cycle_type int
	DECLARE @curr_day_of_month int
	DECLARE @my_cycle_cutoff datetime

    SELECT @my_date = @v_date
    IF (@my_date_type = 1 AND @my_date IS NOT NULL)
        RETURN @my_date
    
    IF (@my_date_type = 4 or (@my_date_type = 1 and @my_date IS NULL))
	BEGIN
        IF (@is_start = 1)
            IF (@my_id_acc IS NOT NULL AND @my_id_acc > 0)
                select @my_date = dt_crt from t_account where id_acc = @my_id_acc
            ELSE
                select @my_date = dbo.mtmindate()
        ELSE
            SELECT @my_date = dbo.mtmaxdate()
        
        RETURN @my_date
    END

    IF (@my_date_type = 3)
	BEGIN
        SELECT @my_acc_start  = dt_crt FROM t_account WHERE id_acc = @my_id_acc
        IF (@my_acc_start > @my_date or @my_date IS NULL)
            SELECT @my_date = @my_acc_start
        
        SELECT @curr_id_cycle_type = id_cycle_type, @curr_day_of_month = day_of_month
            from t_acc_usage_cycle a, t_usage_cycle b
            where a.id_usage_cycle = b.id_usage_cycle and a.id_acc = @my_id_acc;
        IF (@curr_id_cycle_type = 1)
		BEGIN
            SELECT @my_cycle_cutoff =
					CAST((CAST(YEAR(@my_date) AS nvarchar) + '-' + CAST(MONTH(@my_date) AS nvarchar) + '-1') AS datetime) +
					(CASE @curr_day_of_month WHEN 31 THEN 0 ELSE @curr_day_of_month END)
            IF (@my_date > @my_cycle_cutoff)
                SELECT @my_cycle_cutoff = DATEADD (mm, 1, @my_date)
            
            SELECT @my_date = @my_cycle_cutoff
            SELECT @my_date = @my_date + @my_date_offset
        END
        RETURN @my_date
    END

    RETURN @my_date
END

