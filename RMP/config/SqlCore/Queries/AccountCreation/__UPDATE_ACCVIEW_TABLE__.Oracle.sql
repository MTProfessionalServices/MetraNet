
				update %%NETMETER%%.%%TARGET_TABLE%% dest 
				set (%%UPDATECOLLIST%%)=
				(SELECT %%SELECTCOLLIST%%
				FROM %%STAGING%%.%%TEMP_TABLE%% src WHERE dest.id_acc = src.%%DEST_ACCT_ID_COL_NAME%%
				)
				where exists
        (
          SELECT %%DEST_ACCT_ID_COL_NAME%% FROM  %%STAGING%%.%%TEMP_TABLE%% src
          %%FIXEDPARTWHERECLAUSE%% %%SKIPRECORDSPARTWHERECLAUSE%%
          %%KEYPARTWHERECLAUSE%%
          AND dest.id_acc = src.%%DEST_ACCT_ID_COL_NAME%%
        )
			