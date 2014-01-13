
create global temporary table tmp_accounts_hasusage (
  id_acc int not null,
  hasusage char(1) default 'N' not null
  ) on commit preserve rows
		