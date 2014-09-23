

SELECT 
ID_SUB,                 
ID_PO                  
,ID_PI_INSTANCE         
,ID_PARAMTABLE          
,
cast(INSTANCE_NM_NAME as Varchar(1024)) as instance_nm_name
,
N_KIND,
NM_NAME,
PT_NM_NAME                                                                                                                                                                                                                                                      
,PT_NM_DISPLAY_NAME                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
,PO_NM_NAME                                                                                                                                                                                                                                                      
,PO_NM_DISPLAY_NAME                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
,B_PERSONALRATE                   
,B_CANICB 
,DT_START                  
,DT_END                    
from (
select
sub.id_sub,
map.id_po,map.id_pi_instance,map.id_paramtable,
case when tb_ip.id_prop is NULL then
  tb.nm_display_name
  else
  dbo.mtconcat(tb_ip.nm_display_name,dbo.mtconcat('/',tb.nm_display_name))
end
as instance_nm_name,
tb.n_kind,
tb.nm_name,
tb_pt.nm_name pt_nm_name,
case when tb_pt.nm_display_name is NULL or tb_pt.nm_display_name = '' then
  tb_pt.nm_name
  else
  tb_pt.nm_display_name
end
as pt_nm_display_name,
tb_po.nm_name po_nm_name,
tb_po.nm_display_name po_nm_display_name,
case when 
(select count(id_sub) from t_pl_map map2 where map2.id_pi_instance = map.id_pi_instance AND
map2.id_paramtable = map.id_paramtable and map2.id_sub = %%ID_SUB%%) > 0 then
'Y'
else
'N'
end as b_PersonalRate,
map.b_canICB,
sub.vt_start dt_start,
sub.vt_end dt_end,
rec.n_rating_type as n_rating_type
from t_vw_base_props tb
INNER JOIN t_sub sub on sub.id_sub = %%ID_SUB%%
INNER JOIN t_pl_map map on map.id_po = sub.id_po AND
  map.id_sub is NULL AND map.id_paramtable is not null
INNER JOIN t_vw_base_props tb_pt on tb_pt.id_prop = map.id_paramtable and tb_pt.id_lang_code = %%LANGCODE%%
INNER JOIN t_vw_base_props tb_po on tb_po.id_prop = map.id_po and tb_po.id_lang_code = %%LANGCODE%%
INNER JOIN t_pi_template on t_pi_template.id_template = map.id_pi_template
LEFT OUTER JOIN t_vw_base_props tb_ip on  tb_ip.id_prop = map.id_pi_instance_parent AND tb_ip.id_lang_code = %%LANGCODE%%
LEFT OUTER JOIN t_recur rec on map.id_pi_instance = rec.id_prop 
where
tb.id_prop =  map.id_pi_instance and tb.id_lang_code = %%LANGCODE%%
) Query
where (n_rating_type=0  and upper(pt_nm_name)=upper('metratech.com/udrctiered')) 
	 or (n_rating_type=1  and upper(pt_nm_name)=upper('metratech.com/udrctapered')) 
	 or (upper(pt_nm_name)not in(upper('metratech.com/udrctapered'),upper('metratech.com/udrctiered')) )  
  