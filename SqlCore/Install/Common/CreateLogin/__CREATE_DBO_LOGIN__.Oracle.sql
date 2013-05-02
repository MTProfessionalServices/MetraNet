
        create user %%DBO_LOGON%% identified by "%%DBO_PASSWORD%%"
        default tablespace %%DATABASE_NAME%% temporary tablespace
        temp quota unlimited on %%DATABASE_NAME%%
				