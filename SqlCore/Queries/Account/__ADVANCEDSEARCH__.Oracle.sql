select distinct "_ACCOUNTID", "NAME_SPACE", "USERNAME" %%SORT_COLUMN%%
           from (%%INNER_QUERY%%) iq1