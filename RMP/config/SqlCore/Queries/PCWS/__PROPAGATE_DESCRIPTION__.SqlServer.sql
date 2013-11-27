

IF EXISTS (SELECT 1 FROM t_base_props where id_prop = %%ID_TEMPLATE%% and n_desc <= 0)
BEGIN
---*** UPDATE INSTANCE BASE PROPS WITH 0 AND DELETE DESCRIPTIONS IF TEMPLATE HAS NO DEFAULT *** ---
delete from t_description
from t_description d inner join ( select n_desc
						from t_base_props bbp inner join (
						select id_pi_instance from t_pl_map m inner join (select id_prop from t_base_props bp inner join t_pi_template t on (t.id_template = bp.id_prop) where bp.n_desc <= 0 
						and	id_prop = %%ID_TEMPLATE%%) 
						templ on (templ.id_prop = m.id_pi_template and m.id_paramtable is null)) iq
						on (iq.id_pi_instance = bbp.id_prop)
							) fq on (fq.n_desc = d.id_desc) where fq.n_desc > 0


update t_base_props set n_desc = 0, nm_desc = null
from t_base_props bbp inner join (
						select id_pi_instance from t_pl_map m inner join (select id_prop from t_base_props bp inner join t_pi_template t on (t.id_template = bp.id_prop) where bp.n_desc <= 0 
						and	id_prop = %%ID_TEMPLATE%%) 
						templ on (templ.id_prop = m.id_pi_template and m.id_paramtable is null)) iq
						on (iq.id_pi_instance = bbp.id_prop) and bbp.n_desc > 0
END
ELSE
BEGIN
---*** UPDATE INSTANCE DESCRITION TEXT IF INSTANCE DESCRIPTION IS AVAILABLE AND TEMPLATE DESC IS AVAILABLE

update t_base_props set nm_desc = fq.template_desc 
from (
select bp.id_prop, bp.n_desc, bp.nm_desc inst_desc , templ.nm_desc template_desc
								from t_base_props bp inner join  t_pl_map m on (bp.id_prop = m.id_pi_instance)
											 inner join (
											select bp.id_prop, bp.nm_desc  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_desc > 0 
											) templ on (templ.id_prop = m.id_pi_template)
								where bp.n_desc > 0 and m.id_paramtable is null) fq
where t_base_props.id_prop = fq.id_prop
								
---*** INSERT BASE PROPS IF TEMPLATE HAS DEFAULT AND INSTANCES DONT *** ---
declare @ids int
select @ids = IDENT_CURRENT('t_mt_id')
set identity_insert t_mt_id on
--GENERATE NEW IDS 
insert into t_MT_ID (id_MT)
select @ids + ROW_NUMBER() over (order by (select 1)) as NextId from t_base_props bp inner join  t_pl_map m on (bp.id_prop = m.id_pi_instance)
									 inner join (
									select bp.id_prop, n_desc from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_desc > 0
									) templ on (templ.id_prop = m.id_pi_template)
where bp.n_desc <= 0 and m.id_paramtable is null
set identity_insert t_mt_id off

-- INSERT t_description with the new id's
insert t_description
select  @ids + ROW_NUMBER() over (order by (select 1)) as NextId, %%ID_LANG_CDE%%, templ.nm_desc, null
from t_base_props bp inner join  t_pl_map m on (bp.id_prop = m.id_pi_instance)
									 inner join (
									select bp.id_prop, bp.nm_desc  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_desc > 0 
									) templ on (templ.id_prop = m.id_pi_template)
where bp.n_desc <= 0 and m.id_paramtable is null

-- update t_base_props with the new id's and default description
update t_base_props set n_desc = nextId, nm_desc = iq.nm_desc
from t_base_props bbp inner join (
								select bp.id_prop, templ.nm_desc, @ids + ROW_NUMBER() over (order by (select 1)) as NextId
								from t_base_props bp inner join  t_pl_map m on (bp.id_prop = m.id_pi_instance)
											 inner join (
											select bp.id_prop, bp.nm_desc  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_desc > 0 
											) templ on (templ.id_prop = m.id_pi_template)
								where bp.n_desc <= 0 and m.id_paramtable is null
								) as iq on bbp.id_prop = iq.id_prop
							
								
END
              