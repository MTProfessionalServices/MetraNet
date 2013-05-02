CREATE PROCEDURE arch_delete_temp_tables
(
    @result          NVARCHAR(4000) OUTPUT
)
AS
BEGIN
	DECLARE @table_name_temp NVARCHAR(30) 
	 
	DECLARE temptablecur CURSOR FOR
	SELECT TABLE_NAME
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_NAME LIKE 't_pv_%_arch' 
	 
	OPEN temptablecur
		FETCH NEXT FROM temptablecur INTO @table_name_temp
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			IF OBJECT_ID(@table_name_temp) IS NOT NULL
			BEGIN
				EXEC ('DROP TABLE ' + @table_name_temp)
				
				IF (@@error <> 0)
				BEGIN
					SET @result = '2000015-archive delete operation failed-->Error in drop temp Product View tables operation'
			        
					CLOSE temptablecur
					DEALLOCATE temptablecur
					RETURN
				END
			END  
			FETCH NEXT FROM temptablecur INTO @table_name_temp
		END
	CLOSE temptablecur
	DEALLOCATE temptablecur 
	
	IF OBJECT_ID('t_acc_usage_arch') IS NOT NULL
	BEGIN
		DROP TABLE t_acc_usage_arch
		
		IF (@@ERROR <> 0)
	    SET @result = '2000016-archive delete operation failed-->Error in Delete t_acc_usage_arch operation'
	END
	
	IF OBJECT_ID('agg_usage_audit_trail_arch') IS NOT NULL
	BEGIN
		DROP TABLE agg_usage_audit_trail_arch
		
		IF (@@ERROR <> 0)
	    SET @result = '2000016-archive delete operation failed-->Error in Delete agg_usage_audit_trail_arch operation'
	END
	
	IF OBJECT_ID('agg_charge_audit_trail_arch') IS NOT NULL
	BEGIN
		DROP TABLE agg_charge_audit_trail_arch
		
		IF (@@ERROR <> 0)
	    SET @result = '2000016-archive delete operation failed-->Error in Delete agg_charge_audit_trail_arch operation'
	END
	
END