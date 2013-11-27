

IF EXISTS (SELECT 1 FROM t_base_props where id_prop = %%ID_TEMPLATE%% and n_display_name <= 0)
BEGIN
---*** UPDATE INSTANCE BASE PROPS WITH 0 AND DELETE DESCRIPTIONS IF TEMPLATE HAS NO DEFAULT *** ---
delete from t_description
from t_description d inner join ( select n_display_name
						from t_base_props bbp inner join (
						select id_pi_instance from t_pl_map m inner join (select id_prop from t_base_props bp inner join t_pi_template t on (t.id_template = bp.id_prop) where bp.n_display_name <= 0 
						and	id_prop = %%ID_TEMPLATE%%) 
						templ on (templ.id_prop = m.id_pi_template and m.id_paramtable is null)) iq
						on (iq.id_pi_instance = bbp.id_prop)
							) fq on (fq.n_display_name = d.id_desc) where fq.n_display_name > 0


update t_base_props set n_display_name = 0, nm_display_name = null
from t_base_props bbp inner join (
						select id_pi_instance from t_pl_map m inner join (select id_prop from t_base_props bp inner join t_pi_template t on (t.id_template = bp.id_prop) where bp.n_display_name <= 0 
						and	id_prop = %%ID_TEMPLATE%%) 
						templ on (templ.id_prop = m.id_pi_template and m.id_paramtable is null)) iq
						on (iq.id_pi_instance = bbp.id_prop) and bbp.n_display_name > 0
END
ELSE
BEGIN
---*** UPDATE INSTANCE DISPLAYNAME TEXT IF INSTANCE DISPLAYNAME IS AVAILABLE AND TEMPLATE DISPLAYNAME IS AVAILABLE

update t_base_props set nm_display_name = fq.template_displayname 
from (
select bp.id_prop, bp.n_display_name, bp.nm_display_name inst_displayname , templ.nm_display_name template_displayname 
								from t_base_props bp inner join  t_pl_map m on (bp.id_prop = m.id_pi_instance)
											 inner join (
											select bp.id_prop, bp.nm_display_name  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_display_name > 0 
											) templ on (templ.id_prop = m.id_pi_template)
								where bp.n_display_name > 0 and m.id_paramtable is null) fq
where t_base_props.id_prop = fq.id_prop
								
---*** INSERT BASE PROPS IF TEMPLATE HAS DEFAULT AND INSTANCES DONT *** ---
declare @ids int
select @ids = IDENT_CURRENT('t_mt_id')
set identity_insert t_mt_id on
--GENERATE NEW IDS 
insert into t_MT_ID (id_MT)
select @ids + ROW_NUMBER() over (order by (select 1)) as NextId from t_base_props bp inner join  t_pl_map m on (bp.id_prop = m.id_pi_instance)
									 inner join (
									select bp.id_prop, n_display_name from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_display_name > 0
									) templ on (templ.id_prop = m.id_pi_template)
where bp.n_display_name <= 0 and m.id_paramtable is null
set identity_insert t_mt_id off

-- INSERT t_description with the new id's
insert t_description
select  @ids + ROW_NUMBER() over (order by (select 1)) as NextId, %%ID_LANG_CDE%%, templ.nm_display_name, null
from t_base_props bp inner join  t_pl_map m on (bp.id_prop = m.id_pi_instance)
									 inner join (
									select bp.id_prop, bp.nm_display_name  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_display_name > 0 
									) templ on (templ.id_prop = m.id_pi_template)
where bp.n_display_name <= 0 and m.id_paramtable is null

-- update t_base_props with the new id's and default display names
update t_base_props set n_display_name = nextId, nm_display_name = iq.nm_display_name
from t_base_props bbp inner join (
								select bp.id_prop, templ.nm_display_name, @ids + ROW_NUMBER() over (order by (select 1)) as NextId
								from t_base_props bp inner join  t_pl_map m on (bp.id_prop = m.id_pi_instance)
											 inner join (
											select bp.id_prop, bp.nm_display_name  from t_base_props bp where id_prop = %%ID_TEMPLATE%% and n_display_name > 0 
											) templ on (templ.id_prop = m.id_pi_template)
								where bp.n_display_name <= 0 and m.id_paramtable is null
								) as iq on bbp.id_prop = iq.id_prop
							
								
END
              