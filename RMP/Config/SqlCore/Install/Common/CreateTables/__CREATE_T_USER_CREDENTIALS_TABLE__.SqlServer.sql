
         CREATE TABLE [dbo].[t_user_credentials](
         [nm_login] [nvarchar](255) NOT NULL,
         [nm_space] [nvarchar](40) NOT NULL,
         [tx_password] [nvarchar](1024) NOT NULL,
         [dt_expire] [datetime] NULL,
         [dt_last_login] [datetime] NULL,
         [dt_last_logout] [datetime] NULL,
         [num_failures_since_login] [int] NULL,
         [dt_auto_reset_failures] [datetime] NULL,
         [b_enabled] [nvarchar](1) NULL,
         CONSTRAINT [PK_t_user_credentials] PRIMARY KEY CLUSTERED
         (
         [nm_login] ASC,
         [nm_space] ASC
         )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
         ) ON [PRIMARY]
       