
			SELECT DISTINCT nm_currency_code
			FROM t_pricelist pl
				join t_po po on po.id_nonshared_pl = pl.id_pricelist
			WHERE po.id_po = %%ID_PO%%
      