
CREATE OR REPLACE VIEW VW_ACCOUNT_ANCESTOR
AS
select *
from t_account_ancestor aa
where id_ancestor <> id_descendent and num_generations = 1
