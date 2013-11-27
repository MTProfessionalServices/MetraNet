
        Create TABLE [dbo].[t_user_credentials_history](
        [nm_login] [nvarchar](255) NOT NULL,
        [nm_space] [nvarchar](40) NOT NULL,
        [tx_password] [nvarchar](1024) NOT NULL,
        [tt_end] [datetime] NOT NULL,
        CONSTRAINT [PK_t_user_credentials_history] PRIMARY KEY CLUSTERED
        (
        [nm_login] ASC,
        [nm_space] ASC,
        [tt_end] ASC
        )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
        ) ON [PRIMARY]
      