
			       CREATE TABLE [dbo].[t_payment_instrument_xref](
	            [temp_acc_id] [int] NOT NULL,
	            [nm_login] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	            [nm_space] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	            [dt_created] [datetime] NOT NULL
             CONSTRAINT [PK_t_payment_instrument_xref] PRIMARY KEY CLUSTERED 
	            (
		            [temp_acc_id] ASC,
		            [nm_login] ASC,
		            [nm_space] ASC
	            ) 
            )
				