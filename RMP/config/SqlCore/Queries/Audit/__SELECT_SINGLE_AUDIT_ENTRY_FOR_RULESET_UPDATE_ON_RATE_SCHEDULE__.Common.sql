
select distinct %%PARAM_TABLE_ID%% id_pt, aud.*, case when pt.tt_start is null then aud.dt_crt else pt.tt_start end "RuleSetStartDate" 
from vw_audit_log aud 
left outer join %%PARAM_TABLE_DB_NAME%% pt on aud.id_audit =pt.id_audit WHERE aud.id_audit = %%AUDIT_ID%%
        