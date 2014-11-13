
CREATE TABLE [t_recevent_localize]
(
[id_local] [int] NOT NULL, --Localize identifier. This is foreign key to t_recevent
[id_lang_code] [int] NOT NULL, -- Language identifier displayed on the MetraNet Presentation Server
[tx_name] [nvarchar](255) NULL, -- The localized DisplayName
[tx_desc] [nvarchar](2048) NULL, -- The localized Description
CONSTRAINT [PK_t_recevent_localize] PRIMARY KEY CLUSTERED 
(
[id_local],
[id_lang_code]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]