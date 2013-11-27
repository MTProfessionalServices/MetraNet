use %%NETMETER%%

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT

IF  EXISTS (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'sp_InsertPolicy') AND type in (N'P'))
	DROP PROCEDURE sp_InsertPolicy
GO

create procedure sp_InsertPolicy
						(@aPrincipalColumn VARCHAR(255),
						 @aPrincipalID int,
						 @aPolicyType VARCHAR(2),
             @ap_id_prop int OUTPUT)
		        as
		        
            declare @args NVARCHAR(255)
		        declare @str nvarchar(2000)
						declare @selectstr nvarchar(2000)
            begin
						 select @selectstr = N'SELECT @ap_id_prop = id_policy  FROM t_principal_policy with(updlock) WHERE ' + 
																CAST(@aPrincipalColumn AS nvarchar(255))
																+  N' = ' + CAST(@aPrincipalID AS nvarchar(38)) + N' AND ' + N'policy_type=''' 
																+ CAST(@aPolicyType AS nvarchar(2)) + ''''
						 select @str = N'INSERT INTO t_principal_policy (' + CAST(@aPrincipalColumn AS nvarchar(255)) + N',
						               policy_type)' + N' VALUES ( ' + CAST(@aPrincipalID AS nvarchar(38)) + N', ''' + 
						               CAST(@aPolicyType AS nvarchar(2))	+ N''')' 
            select @args = '@ap_id_prop INT OUTPUT'
            exec sp_executesql @selectstr, @args, @ap_id_prop OUTPUT
             if (@ap_id_prop is null)
	            begin
              exec sp_executesql @str
  	          select @ap_id_prop = @@identity
              end
            end
GO