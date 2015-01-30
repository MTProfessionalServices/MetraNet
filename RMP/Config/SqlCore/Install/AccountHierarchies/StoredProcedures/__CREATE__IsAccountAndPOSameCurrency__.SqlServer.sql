
		create function IsAccountAndPOSameCurrency(@id_acc int, @id_po int) 
		returns varchar
		as
		begin 
		declare @sameCurrency char(1)
		select @sameCurrency = 
		CASE WHEN 
		(SELECT COUNT(id_po)  from t_pricelist pl
		inner join t_po po on po.id_nonshared_pl = pl.id_pricelist AND po.id_po = @id_po
		inner join t_av_internal av ON av.c_currency = pl.nm_currency_code AND av.id_acc = @id_acc
		) = 0
		THEN '0' ELSE '1' END
		return @sameCurrency
		end
		