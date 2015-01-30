
				create function DoesAccountHavePayees(@id_acc int,@dt_ref datetime) 
				returns varchar
				as
        begin
				declare @returnValue char(1)
				SELECT @returnValue = CASE WHEN count(*) > 0 THEN 'Y' ELSE 'N' END
				FROM t_payment_redirection
				WHERE id_payer = @id_acc and
				((@dt_ref between vt_start and vt_end) OR @dt_ref < vt_start)
				if (@returnValue is null)
					begin
					select @returnValue = 'N'
					end
				return @returnValue
				end
				