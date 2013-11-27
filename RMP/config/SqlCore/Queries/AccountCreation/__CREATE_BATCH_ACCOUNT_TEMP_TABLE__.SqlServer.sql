
          IF OBJECT_ID('tempdb..%%TMP_TABLE_NAME%%') IS NOT NULL DROP TABLE %%TMP_TABLE_NAME%%
          CREATE TABLE %%TMP_TABLE_NAME%%
          (
            [id_request] [int] NOT NULL,
            [id_acc_ext] [varbinary] (16) NULL,
            [acc_state] [varchar] (2)  NOT NULL,
            [acc_status_ext] [int] NULL,
            [acc_vtstart] [datetime] NULL,
            [acc_vtend] [datetime] NULL,
            [nm_login] [nvarchar] (255)  NOT NULL,
            [nm_space] [nvarchar] (40)  NOT NULL,
            [tx_password] [nvarchar] (1024)  NOT NULL,
            [langcode] [varchar] (10)  NOT NULL, /* 10 */
            [profile_timezone] [int] NOT NULL,
            [id_cycle_type] [int] NULL,
            [day_of_month] [int] NULL,
            [day_of_week] [int] NULL,
            [first_day_of_month] [int] NULL,
            [second_day_of_month] [int] NULL,
            [start_day] [int] NULL,
            [start_month] [int] NULL,
            [start_year] [int] NULL,
            [billable] [varchar] (1)  NOT NULL, /* 20 */
            [id_payer] [int] NULL,
            [payer_startdate] [datetime] NULL,
            [payer_enddate] [datetime] NULL,
            [payer_login] [nvarchar] (255)  NULL,
            [payer_namespace] [nvarchar] (40)  NULL,
            [id_ancestor] [int] NULL,
            [hierarchy_start] [datetime] NULL,
            [hierarchy_end] [datetime] NULL,
            [ancestor_name] [nvarchar] (255)  NULL,
            [ancestor_namespace] [nvarchar] (40)  NULL, /* 30 */
            [acc_type] [varchar] (40)  NOT NULL,
            [apply_default_policy] [varchar] (1)  NOT NULL,
            [account_currency] [nvarchar] (5)  NULL,
            [id_profile] [int] NOT NULL,
            [login_app][varchar](10) NULL,
            [id_site] [int] NULL,
            [id_usage_cycle] [int] NULL,
            [folder] [varchar] (1)  NULL,
            [account_id_as_string] [nvarchar] (50)  NULL,
            [auth_ancestor] [int] NULL, /* 40 */
            [billable_payer] [varchar] (1)  NULL,
            [same_corporation] [varchar] (1)  NULL,
            [parent_login] [nvarchar] (255) NULL,
            [parent_policy] [int] NULL,
            [child_policy] [int] NULL,
            [id_account] [int] NULL,
            [status] [int] NULL,
            [hierarchy_path] [varchar] (4000)  NULL,
            [id_ancestor_out] [int] NULL,
            [id_corporation] [int] NULL,
            [ancestor_type][varchar](40) NULL
   
          )
          CREATE CLUSTERED INDEX %%TMP_TABLE_IDX_NAME%% ON %%TMP_TABLE_NAME%% (id_account)
      