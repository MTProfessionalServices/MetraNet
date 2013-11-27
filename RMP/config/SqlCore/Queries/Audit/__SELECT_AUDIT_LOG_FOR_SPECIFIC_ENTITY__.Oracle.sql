
				select * from
				(
        select * from vw_audit_log
        WHERE
          EntityType = %%ENTITY_TYPE_ID%% AND
          EntityId = %%ENTITY_ID%%
        order by Time DESC
        )
				where rownum < 1001
        