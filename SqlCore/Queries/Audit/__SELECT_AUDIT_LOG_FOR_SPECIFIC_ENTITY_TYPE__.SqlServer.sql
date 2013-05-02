
        select top 1000 * from vw_audit_log
        WHERE
          EntityType = %%ENTITY_TYPE_ID%%
        order by Time DESC
        