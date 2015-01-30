
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
																+  N' = @aPrincipalID AND  policy_type= @aPolicyType'
						 select @str = N'INSERT INTO t_principal_policy (' + CAST(@aPrincipalColumn AS nvarchar(255)) + N',
						               policy_type)' + N' VALUES ( ' + CAST(@aPrincipalID AS nvarchar(38)) + N', ''' + 
						               CAST(@aPolicyType AS nvarchar(2))	+ N''')' 
            select @args = '@aPrincipalID INT, @aPolicyType VARCHAR(2), @ap_id_prop INT OUTPUT'
            exec sp_executesql @selectstr, @args, @aPrincipalID, @aPolicyType, @ap_id_prop OUTPUT
             if (@ap_id_prop is null)
	            begin
              exec sp_executesql @str
  	          select @ap_id_prop = @@identity
              end
            end
        