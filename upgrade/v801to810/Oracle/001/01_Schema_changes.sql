SET DEFINE OFF

DECLARE
    last_upgrade_id NUMBER;
BEGIN
    SELECT (NVL(MAX(upgrade_id), 0) + 1)
    INTO   last_upgrade_id
    FROM   t_sys_upgrade;

    INSERT INTO t_sys_upgrade
      (
        upgrade_id,
        target_db_version,
        dt_start_db_upgrade,
        db_upgrade_status
      )
    VALUES
      (
        last_upgrade_id,
        '8.1.0',
        SYSDATE,
        'R'
      );
END;
/

CREATE TABLE t_localized_items
(
	id_local_type int NOT NULL,     			/* Composite key: This is foreign key to t_localized_items_type.*/
	id_item int NOT NULL,						/* Composite key: Localize identifier. This is foreign key to t_recevent and other tables*/
	id_item_second_key int default -1 NOT NULL,	/* Composite key: Second localize identifier. This is foreign key, for example, to t_compositor (it is atomoc capability) and other tables with composite PK. In case second key is not used set -1 as default value */
	id_lang_code int NOT NULL,      			/* Composite key: Language identifier displayed on the MetraNet Presentation Server */
	tx_name NVARCHAR2(255) NULL,   				/* The localized DisplayName */
	tx_desc NVARCHAR2(2000) NULL,  				/* The localized Description */
CONSTRAINT PK_t_localized_items PRIMARY KEY (id_local_type, id_item, id_item_second_key, id_lang_code)
)
/

COMMENT ON TABLE  t_localized_items 						IS  'The t_localized_items table contains the localized DisplayName and Description of entyties (for example t_recevent, t_composite_capability_type, t_atomic_capability_type tables) for the languages supported by the MetraTech platform.(Package:Pipeline) ';
/
COMMENT ON COLUMN t_localized_items.id_local_type 			IS	'Composite key: This is foreign key to t_localized_items_type.';
/
COMMENT ON COLUMN t_localized_items.id_item					IS	'Composite key: Localize identifier. This is foreign key to t_recevent and other tables (see constraints)';
/
COMMENT ON COLUMN t_localized_items.id_item_second_key 		IS 'Composite key: Second localize identifier. This is foreign key, for example, to t_compositor (it is atomoc capability) and other tables with composite PK. In case second key is not used set -1 as default value';
/
COMMENT ON COLUMN t_localized_items.id_lang_code			IS	'Composite key: Language identifier displayed on the MetraNet Presentation Server';
/
COMMENT ON COLUMN t_localized_items.tx_name 				IS 	'The localized DisplayName';
/
COMMENT ON COLUMN t_localized_items.tx_desc 				IS 	'The localized DEscription';
/

CREATE TABLE t_localized_items_type
(
	id_local_type int NOT NULL,     	/* PK, where '1' - Localization type for Recurring Adapters,
													 '2' - 'Localization type for Composite Capability,
													 '3' - 'Localization type for Atomic Capability */	
	local_type_description NVARCHAR2(255) NOT NULL,	/* The type description */
CONSTRAINT PK_t_localized_items_type PRIMARY KEY (id_local_type)
)
/
COMMENT ON TABLE t_localized_items_type							IS  'Dictionary table for t_localized_items.id_local_type colum. Contains id localization type and their description';
/
COMMENT ON COLUMN t_localized_items_type.id_local_type 			IS	'Primary key.';
/
COMMENT ON COLUMN t_localized_items_type.local_type_description	IS	'Description type';
/


alter table t_localized_items add constraint FK_LOCAL_TO_LOCAL_ITEMS_TYPE
					foreign key(id_local_type) references t_localized_items_type(id_local_type);
/
					
alter table t_localized_items add constraint FK_LOCALIZE_TO_T_LANGUAGE
					foreign key(id_lang_code) references t_language (id_lang_code);
/