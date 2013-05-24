CREATE TABLE SecurityPolicyAction
(
	ID INTEGER NOT NULL,
	SecurityEventID INTEGER NOT NULL,
	SecurityPolicyActionTypeID INTEGER NOT NULL,
	BlockingPeriod REAL,							-- For blocking actions
	SessionParameterName TEXT,						-- For change session parameter action
	SessionParameterValue TEXT,						-- For change session parameter action
	Message TEXT,									-- For notification actions
	AdminEmailAddress TEXT,							-- For notify admin action
	DestinationPath TEXT,							-- For redirect actions
	CONSTRAINT PK_SecurityPolicyAction PRIMARY KEY (ID),
	CONSTRAINT FK_SecurityPolicyAction_SecurityEventID FOREIGN KEY (SecurityEventID)
		REFERENCES SecurityEvent (ID) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_SecurityPolicyAction_SecurityPolicyActionTypeID FOREIGN KEY (SecurityPolicyActionTypeID)
		REFERENCES SecurityPolicyActionType (ID) ON DELETE RESTRICT ON UPDATE CASCADE
);
