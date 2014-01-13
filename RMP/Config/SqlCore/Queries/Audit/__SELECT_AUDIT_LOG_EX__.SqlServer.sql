
        select TOP %%TOP_CLAUSE%% * from vw_audit_log %%WHERE_CLAUSE%% order by Time DESC
        