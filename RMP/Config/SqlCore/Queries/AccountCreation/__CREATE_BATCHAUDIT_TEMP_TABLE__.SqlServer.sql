
        IF OBJECT_ID('%%TMP_TABLE_NAME%%') IS NOT NULL DROP TABLE %%TMP_TABLE_NAME%%
        CREATE TABLE %%TMP_TABLE_NAME%%
        (
			[id_audit] [int] NOT NULL,
			[id_event] [int] NULL,
			[id_userid] [int] NULL,
			[id_entitytype] [int] NULL,
			[id_entity] [int] NULL,
			[tx_details] [nvarchar] (4000) NULL,
			[dt_crt] [datetime] NOT NULL
		)
			