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

CREATE TABLE t_recevent_localize
(
	id_local int NOT NULL, 		 /* Localize identifier. This is foreign key to t_recevent */
	id_lang_code int NOT NULL,  /* Language identifier displayed on the MetraNet Presentation Server */
	tx_name VARCHAR2(255) NULL,  /* The localized DisplayName */
	tx_desc VARCHAR2(2048) NULL, /* The localized Description */
CONSTRAINT PK_t_recevent_localize PRIMARY KEY (id_local, id_lang_code)
)
/

alter table t_recevent_localize add constraint FK1_LOCALIZE_TO_T_RECEVENT
			foreign key (id_local) references t_recevent(id_event);
/
					
alter table t_recevent_localize add constraint FK2_LOCALIZE_TO_T_LANGUAGE
			foreign key (id_lang_code) references t_language(id_lang_code);
/

COMMENT ON TABLE t_recevent_localize 				IS 'The t_recevent_localize table contains the localized DisplayName and DEscription of t_recevent table for the languages supported by the MetraTech platform.(Package:Pipeline) ';
/
COMMENT ON COLUMN t_recevent_localize.id_desc 		IS 'Localize identifier. This is foreign key to t_recevent';
/
COMMENT ON COLUMN t_recevent_localize.id_lang_code 	IS 'Language identifier displayed on the MetraNet Presentation Server';
/
COMMENT ON COLUMN t_recevent_localize.tx_name 		IS 'The localized DisplayName';
/
COMMENT ON COLUMN t_recevent_localize.tx_desc 		IS 'The localized DEscription';
/
