
-- TEMPLATE HAS NO LANGUAGE BUT INSTANCE HAS LANGUAGE THEN DELETE INSTANCE LANGUAGE
delete from t_description
from t_description od inner join (
				select * from t_description d inner join (select n_desc from t_base_props mbp inner join (select id_pi_instance from t_pl_map where id_paramtable is null and id_pi_template = %%ID_TEMPLATE%%) m on mbp.id_prop = m.id_pi_instance) insts
												on insts.n_desc = d.id_desc and insts.n_desc > 0
				where id_lang_code NOT IN (SELECT id_lang_code from t_description id inner join t_base_props ibp on (ibp.n_desc = id.id_desc) where ibp.id_prop = %%ID_TEMPLATE%% and ibp.n_desc > 0)) fq
				on fq.id_desc = od.id_desc and fq.id_lang_code = od.id_lang_code

--- *** TEMPLATE HAS LANGUAGE BUT INSTANCE DOES NOT HAVE THAT LANGUAGE.
INSERT INTO t_description  
select n_desc, fq.id_lang_code, nm_desc, null from (select insts.id_lang_code, insts.n_desc from (select id_prop, n_desc, id_lang_code from t_vw_base_props mbp 
					inner join (select id_pi_instance from t_pl_map where id_paramtable is null and id_pi_template = %%ID_TEMPLATE%%)	m on mbp.id_prop = m.id_pi_instance) insts left outer join t_description d
												on insts.n_desc = d.id_desc and insts.id_lang_code = d.id_lang_code 
				where insts.id_lang_code  IN (SELECT id_lang_code from t_description id inner join t_base_props ibp on (ibp.n_desc = id.id_desc) where ibp.id_prop = %%ID_TEMPLATE%% and ibp.n_desc > 0)
				and insts.n_desc > 0 and d.id_desc is null) fq 
				inner join (select id_lang_code, nm_desc from t_vw_base_props vwb where vwb.id_prop = %%ID_TEMPLATE%%) ut on fq.id_lang_code = ut.id_lang_code


---- *** UPDATE INSTANCE DESCRIPTIONS TO TEMPLATE DESCRITION WHEN BOTH TEMPLATE AND INSTANCE HAS LANGUAGES.
update t_description set tx_desc = templ.tx_desc, tx_URL_desc = templ.tx_url_desc
from (
			select * from t_description d inner join (select n_desc from t_base_props mbp inner join (select id_pi_instance from t_pl_map where id_paramtable is null and id_pi_template = %%ID_TEMPLATE%%)	m on mbp.id_prop = m.id_pi_instance) insts
												on insts.n_desc = d.id_desc and insts.n_desc > 0
							 where id_lang_code  IN (SELECT id_lang_code from t_description id inner join t_base_props ibp on (ibp.n_desc = id.id_desc) where ibp.id_prop = %%ID_TEMPLATE%% and ibp.n_desc > 0)
				) fq inner join (select td.id_lang_code, td.tx_desc, td.tx_URL_desc from t_base_props bp inner join t_description td on (bp.n_desc = td.id_desc) where id_prop = %%ID_TEMPLATE%% and n_desc > 0) templ on (fq.id_lang_code = templ.id_lang_code)
where t_description.id_desc = fq.n_desc and t_description.id_lang_code = fq.id_lang_code


              