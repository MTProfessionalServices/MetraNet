
CREATE TABLE t_localized_items_type
(
	id_local_type int NOT NULL,     	/* PK, where '1' - Localization type for Recurring Adapters,
													 '2' - 'Localization type for Composite Capability,
													 '3' - 'Localization type for Atomic Capability */	
	local_type_description NVARCHAR2(255) NOT NULL,	/* The type description */
CONSTRAINT PK_t_localized_items_type PRIMARY KEY (id_local_type)
)