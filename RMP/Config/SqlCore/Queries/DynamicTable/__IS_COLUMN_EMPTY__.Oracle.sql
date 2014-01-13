
        select case when exists (select 1 from %%tabname%% where %%column%% is not NULL) then 'N' else 'Y' end as empty from dual
      