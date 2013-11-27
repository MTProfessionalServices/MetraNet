
/* Temp tables used during account deletion and dearchive_files */
				CREATE TABLE tmp_AccountIDsTable (
            ID NUMBER(10) NOT NULL,
            status NUMBER(10) NULL,
            message varchar2(255) NULL);
				CREATE TABLE tmp_AccountBucketsTable (
            ID NUMBER(10) NOT NULL,
            bucket NUMBER(10) NULL);
				CREATE TABLE tmp_file (
				filename varchar2(4000),
				id_acc number(10));

