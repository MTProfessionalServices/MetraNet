drop table master..tmp_create_account
select * from tmp_create_account

insert into #tmp_create_account select * from tmp_create_account
select * from #tmp_create_account
drop table #tmp_create_account

IF OBJECT_ID('temp..#tmp_create_account') IS NOT NULL
  DROP TABLE #tmp_create_account

CREATE TABLE [#tmp_create_account]
(
  -- Input Values - Required values are specified as NOT NULL.
  [id_request] int NOT NULL ,
	[id_acc_ext] [varbinary] (16) NULL ,
	[acc_state] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[acc_status_ext] [int] NULL ,
	[acc_vtstart] [datetime] NULL ,
	[acc_vtend] [datetime] NULL ,
	[nm_login] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[nm_space] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,  -- Always lower case.
	[tx_password] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[langcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[profile_timezone] [int] NOT NULL ,
	[id_cycle_type] [int] NOT NULL ,
	[day_of_month] [int] NULL ,
	[day_of_week] [int] NULL ,
	[first_day_of_month] [int] NULL ,
	[second_day_of_month] [int] NULL ,
	[start_day] [int] NULL ,
	[start_month] [int] NULL ,
	[start_year] [int] NULL ,
	[billable] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[id_payer] [int] NULL ,
	[payer_startdate] [datetime] NULL ,
	[payer_enddate] [datetime] NULL ,
	[payer_login] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[payer_namespace] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[id_ancestor] [int] NULL ,
	[hierarchy_start] [datetime] NULL ,
	[hierarchy_end] [datetime] NULL ,
	[ancestor_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ancestor_namespace] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[acc_type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,  -- Always upper case.
	[apply_default_policy] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[account_currency] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
  [id_profile] [int] NOT NULL ,

  -- Temporary Work Values - These could be "Output or Return Values".
	[id_site] [int] NULL ,
  [id_usage_cycle] [int] NULL ,
	[folder] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[account_id_as_string] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[auth_ancestor] [int] NULL ,
	[billable_payer] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[same_corporation] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
  [parent_policy] [int] NULL ,
  [child_policy] [int] NULL ,

  -- Ouput or Return Values - These are always set for rows that succeeded.
  --                          "id_request", "acc_type" and "nm_login" are also
  --                          returned as output values.
	[id_account] [int] NULL ,
	[status] [int] NULL ,
	[hierarchy_path] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[id_ancestor_out] [int] NULL ,
	[id_corporation] [int] NULL

) ON [PRIMARY]
GO
