
          select * from t_rsched where id_pt in(select distinct id_pt from t_rsched where id_pricelist=%%PRICELISTID%% and id_pi_template=%%PRICEABLEITEMID%%) and id_pricelist=%%PRICELISTID%% and id_pi_template=%%PRICEABLEITEMID%%
			