
        select top %%RECORDS_TO_DISPLAY%%
          *
        from (
          select TOP %%TOP_RECORDS%%
            *
          from (
             select distinct _AccountID,username,name_space %%SORT_COLUMN%% 
             from (%%INNER_QUERY%%) iq1
          ) iq2
          order by %%SORT_DIRECTION%%
        ) iq3
        order by %%SORT_DIRECTION_REVERSE%%
			