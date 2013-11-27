
		create global temporary table gtempAccountIDsTable
		(
			ID int NOT NULL,
			status int NULL,
			message varchar2(255) NULL
		) on commit preserve rows
    