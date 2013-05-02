
			   SELECT CASE type
			             WHEN 'P' THEN 'drop procedure ' + name
									 WHEN 'TR' THEN 'drop trigger ' + name
                   WHEN 'V' THEN 'drop view ' + name
        					 WHEN 'FN' THEN 'drop function ' + name
						 ELSE 'error'
					  END
					  AS statement
			   FROM sysobjects WHERE type IN ('P','TR','V','FN')
				 AND objectproperty(object_id(name), 'IsMSShipped') = 0
			 