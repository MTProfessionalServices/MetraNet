use netmeter
select * from t_po
select * from t_base_props where id_prop=93
select * from t_base_props where id_prop=104

select id_po,nm_name,* from t_po po,t_base_props pr where po.id_po=pr.id_prop

select distinct id_pricelist "id" from t_pl_map where id_po=93


select distinct  id_pi_template from t_pl_map where id_po=93

select distinct id_pi_template "id" from t_pl_map where id_po=93


select * from t_rsched 
select * from t_pl_map where id_po=93


select * from t_pl_map

sp_help t_pl_map



select tcal.c_calendar_id "id" from
	t_rsched
	INNER JOIN t_pl_map pm on pm.id_po = 93 AND id_paramtable is not NULL AND id_sub is NULL
	JOIN t_base_props tbp on tbp.id_prop = pm.id_paramtable
	JOIN t_pt_calendar tcal on tcal.id_sched = t_rsched.id_sched
where
	t_rsched.id_pt = pm.id_paramtable AND t_rsched.id_pi_template = pm.id_pi_template AND
	t_rsched.id_pricelist = pm.id_pricelist AND
	tbp.nm_name = N'metratech.com/calendar' 

select tcal.c_calendar_id from  t_rsched  
INNER JOIN t_pl_map pm on pm.id_po = 93 AND id_paramtable is not NULL AND id_sub is NULL  
JOIN t_base_props tbp on tbp.id_prop = pm.id_paramtable  JOIN t_pt_calendar tcal on tcal.id_sched = t_rsched.id_schedwhere  t_rsched.id_pt = pm.id_paramtable AND t_rsched.id_pi_template = pm.id_pi_template AND  t_rsched.id_pricelist = pm.id_pricelist AND  tbp.nm_name = N'metratech.com/calendar' 



select *from 
	t_rsched
	INNER JOIN t_pl_map pm on pm.id_po = 93 AND id_paramtable is not NULL AND id_sub is NULL
where
	t_rsched.id_pt = pm.id_paramtable AND t_rsched.id_pi_template = pm.id_pi_template AND
	t_rsched.id_pricelist = pm.id_pricelist 




select * from t_pl_map

select * from t_rsched

select * from t_pt_calendar
select * from t_vw_base_props where id_prop=109

SELECT t_calendar.id_calendar, t_vw_base_props.nm_name,             t_vw_base_props.nm_desc, t_calendar.n_timezoneoffset, t_calendar.b_combinedweekend        

	FROM t_vw_base_props 
	JOIN            t_calendar ON t_vw_base_props.id_prop = t_calendar.id_calendar and t_vw_base_props.id_lang_code = 840        
	WHERE (t_calendar.id_calendar = 109)


select * from t_rsched where id_pt=23 

/* Get all the parameter table used by a price list and a PriceAbleItem Template */
select distinct id_pt from t_rsched where  id_pricelist=98 and id_pi_template=57

/* get all the rate schedule from a PT, PL and PT */
select * from t_rsched where id_pt=23 and id_pricelist=98 and id_pi_template=57


select * from t_rsched where id_pt in(select distinct id_pt from t_rsched where id_pricelist=98 and id_pi_template=57) and id_pricelist=98 and id_pi_template=57



select * from t_pv_error