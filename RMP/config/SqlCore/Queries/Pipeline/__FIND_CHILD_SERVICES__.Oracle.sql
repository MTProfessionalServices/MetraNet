
      select id_source_sess from %%SERVICEDEF_TABLENAME%%
      where id_parent_source_sess = hextoraw(%%ID_PARENT_SOURCE_SESS%%)
			