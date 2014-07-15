SELECT * FROM (
           select distinct _AccountID, name_space, username %%SORT_COLUMN%% %%FILTER_COLUMN%%
           from (%%INNER_QUERY%%) iq1) iq2 WHERE _ACCOUNTID IN (%%ACCOUNTIDLIST%%)