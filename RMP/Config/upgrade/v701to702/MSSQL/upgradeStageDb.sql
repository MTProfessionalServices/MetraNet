PRINT N'Rebuilding t_acc_usage on Stage Db if exists'

IF OBJECT_ID('t_acc_usage', 'U') IS NOT NULL
BEGIN
	EXEC sp_RENAME 't_acc_usage.tax_inclusive' , 'is_implied_tax', 'COLUMN'

	EXEC sp_executesql N'UPDATE t_acc_usage SET is_implied_tax=''N'' WHERE is_implied_tax IS NULL'
	EXEC sp_executesql N'UPDATE t_acc_usage SET tax_informational=''N'' WHERE tax_informational IS NULL'
	
	EXEC sp_executesql N'ALTER TABLE t_acc_usage ALTER COLUMN is_implied_tax NVARCHAR(1) NOT NULL'
	EXEC sp_executesql N'ALTER TABLE t_acc_usage ALTER COLUMN tax_informational NVARCHAR(1) NOT NULL'
END
