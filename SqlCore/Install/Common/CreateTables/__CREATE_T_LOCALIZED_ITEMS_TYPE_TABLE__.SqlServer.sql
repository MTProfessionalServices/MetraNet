
CREATE TABLE [t_localized_items_type]
(
	[id_local_type] int NOT NULL,     	/* PK, where '1' - Localization type for Recurring Adapters,
													 '2' - 'Localization type for Composite Capability,
													 '3' - 'Localization type for Atomic Capability */	
	[local_type_description] [nvarchar](255) NULL,	/* The type description */
CONSTRAINT [PK_t_localized_items_type] PRIMARY KEY CLUSTERED 
(
[id_local_type]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]