
			      CREATE TABLE [dbo].[t_wf_instancestate] (
	              [id_instance] [nvarchar](36) NOT NULL ,
	              [state] [image] NULL ,
	              [n_status] [int] NULL ,
	              [n_unlocked] [int] NULL ,
	              [n_blocked] [int] NULL ,
	              [tx_info] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	              [dt_modified] [datetime] NOT NULL,
	              [id_owner] [nvarchar](36) NULL ,
	              [dt_ownedUntil] [datetime] NULL,
	              [dt_nextTimer] [datetime] NULL
              ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
              CREATE  UNIQUE CLUSTERED  INDEX [idx_t_wf_instancestate_id_instance] ON [dbo].[t_wf_InstanceState]([id_instance]) ON [PRIMARY]
			