
			      CREATE TABLE [dbo].[t_wf_completedscope] (
	            [id_instance] [nvarchar](36) NOT NULL,
	            [id_completedScope] [nvarchar](36) NOT NULL,
	            [state] [image] NOT NULL,
	            [dt_modified] [datetime] NOT NULL
            ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
            CREATE  NONCLUSTERED  INDEX [idx_t_wf_completedscope_id_completedscope] ON [dbo].[t_wf_CompletedScope]([id_completedScope]) ON [PRIMARY]
            CREATE  NONCLUSTERED  INDEX [idx_t_wf_completedscope_id_instance] ON [dbo].[t_wf_CompletedScope]( [id_instance] )
			