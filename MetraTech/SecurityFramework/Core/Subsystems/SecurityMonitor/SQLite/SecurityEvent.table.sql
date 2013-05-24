CREATE TABLE SecurityEvent
(
	ID INTEGER NOT NULL,
	SecurityEventTypeID INTEGER,
	SubsystemCategoryID INTEGER,
	ProblemID INTEGER,
	InputData TEXT,
	Reason TEXT,
	TimeStamp TEXT NOT NULL,
	Path TEXT,
	HostName TEXT NOT NULL,
	Message TEXT,
	ClientAddress TEXT,
	UserIdentity TEXT,
	SessionID TEXT,
	ClientInfo TEXT,
	--StackTrace TEXT,
	InputDataSize INTEGER,
	CONSTRAINT PK_SecurityEvent PRIMARY KEY (ID),
	CONSTRAINT FK_SecurityEvent_SecurityEventTypeID FOREIGN KEY (SecurityEventTypeID)
		REFERENCES SecurityEventType (ID) ON DELETE RESTRICT,
	CONSTRAINT FK_SecurityEvent_SubsystemCategoryID FOREIGN KEY (SubsystemCategoryID)
		REFERENCES SubsystemCategory (ID) ON DELETE RESTRICT,
	CONSTRAINT FK_SecurityEvent_ProblemID FOREIGN KEY (ProblemID)
		REFERENCES Problem (ID) ON DELETE RESTRICT
);
