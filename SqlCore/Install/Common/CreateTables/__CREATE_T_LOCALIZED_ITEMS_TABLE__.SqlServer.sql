
CREATE TABLE [t_localized_items]
(
	[id_local_type] int NOT NULL,     				/* Composite key: This is foreign key to t_localized_items_type.*/
	[id_item] int NOT NULL,							/* Composite key: Localize identifier. This is foreign key to t_recevent and other tables */
	[id_item_second_key] int NOT NULL DEFAULT -1 ,	/* Composite key: Second localize identifier. This is foreign key, for example, to t_compositor (it is atomoc capability) and other tables with composite PK. In case second key is not used set -1 as default value */
	[id_lang_code] int NOT NULL,      				/* Composite key: Language identifier displayed on the MetraNet Presentation Server */
	[tx_name] [nvarchar](255) NULL, 				/* The localized DisplayName */
	[tx_desc] [nvarchar](2000) NULL,				/* The localized Description */
CONSTRAINT [PK_t_localized_items] PRIMARY KEY CLUSTERED 
(
[id_local_type],
[id_item],
[id_item_second_key],
[id_lang_code]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]