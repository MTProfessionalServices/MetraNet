
select distinct aud.*, 
case when pt.tt_start is null then aud.dt_crt else pt.tt_start end "RuleSetStartDate" 
from vw_audit_log aud 
/* ESR-5495 performance tuning, stop full table scan on the PT table */
left outer join %%PARAM_TABLE_DB_NAME%% pt on aud.id_audit = pt.id_audit and aud.id_entity = pt.id_sched
WHERE 
aud.id_entitytype = 2 and aud.id_event in (1400,1402,1450) and 
/* ESR-5495 performance tuning, stop full table scan on the PT table */
aud.id_entity = %%RS_ID%%
        