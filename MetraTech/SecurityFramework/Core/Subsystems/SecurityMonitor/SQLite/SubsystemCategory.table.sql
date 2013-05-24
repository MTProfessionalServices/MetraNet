﻿CREATE TABLE SubsystemCategory
(
	ID INTEGER NOT NULL,
	SubsystemID INTEGER NOT NULL,
	Name Text NOT NULL,
	CONSTRAINT PK_SubsystemCategory PRIMARY KEY (ID),
	CONSTRAINT FK_SubsystemCategory_SubsystemID FOREIGN KEY (SubsystemID)
		REFERENCES Subsystem (ID) ON DELETE RESTRICT
);
