
        select *
        from (
          select *
          from (
             select distinct "_ACCOUNTID" %%SORT_COLUMN%% %%FILTER_COLUMN%%
             from (%%INNER_QUERY%%) iq1
             order by %%SORT_DIRECTION%%
          ) iq2
          where ROWNUM <= %%TOP_RECORDS%%
          order by %%SORT_DIRECTION_REVERSE%%
        ) iq3
        WHERE ROWNUM <= %%RECORDS_TO_DISPLAY%%
			