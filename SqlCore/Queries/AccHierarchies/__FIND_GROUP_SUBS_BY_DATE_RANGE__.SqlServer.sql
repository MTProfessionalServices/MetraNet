
select top 1000
ts.id_sub id_sub,
ts.id_sub_ext id_sub_ext,
ts.id_group id_group,
ts.id_po id_po,
ts.vt_start vt_start,
ts.vt_end vt_end,
tg.id_group_ext,
tg.id_usage_cycle usage_cycle,
tg.b_visable b_visable,
tg.tx_name tx_name,
tg.tx_desc tx_desc,
tg.b_proportional b_proportional,
tg.b_supportgroupops b_supportgroupops,
tg.id_corporate_account corporate_account,
tg.id_discountaccount discount_account,
pl.nm_currency_code
from 
t_sub ts
INNER JOIN t_group_sub tg on ts.id_group = tg.id_group
INNER JOIN t_po po on ts.id_po = po.id_po
INNER JOIN t_pricelist pl on pl.id_pricelist = po.id_nonshared_pl
where
ts.id_group is not NULL AND
%%TIMESTAMP%% between ts.vt_start AND ts.vt_end
%%FILTERS%%
order by tx_name
