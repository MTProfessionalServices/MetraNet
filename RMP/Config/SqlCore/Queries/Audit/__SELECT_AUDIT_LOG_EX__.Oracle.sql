
        select * from (select * from vw_audit_log %%WHERE_CLAUSE%% order by Time DESC)
        where rownum <= %%TOP_CLAUSE%%
        