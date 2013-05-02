
        CREATE TABLE t_ps_ach(
        [id_payment_instrument] [nvarchar](72) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [nm_routing_number] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [nm_bank_name] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [nm_bank_address] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [nm_bank_city] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [nm_bank_state] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [nm_bank_zip] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [id_country] [int] NOT NULL,
        CONSTRAINT [PK_t_ps_ach] PRIMARY KEY CLUSTERED
        (
        [id_payment_instrument] ASC
        ))
      