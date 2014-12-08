
CREATE TABLE [t_approvals]
(
	[id_approval]               [int] IDENTITY(1, 1) NOT NULL,
	[c_SubmittedDate]           [datetime] NULL CONSTRAINT [DF_t_approvals_c_SubmittedDate] DEFAULT(GETDATE()),
	[c_SubmitterId]             [int] NOT NULL,
	[c_ChangeType]              [varchar](100) NOT NULL,
	[c_ChangeDetails]           [VARBINARY](MAX) NOT NULL,
	[c_ApproverId]              [int] NULL,
	[c_ChangeLastModifiedDate]  [datetime] NULL,
	[c_ItemDisplayName]         [varchar](100) NULL,
	[c_UniqueItemId]            [varchar](100) NULL,
	[c_Comment]                 [varchar](255) NULL,
	[c_CurrentState]            [varchar](50) NOT NULL,
	[c_PartitionId]             [int] NOT NULL CONSTRAINT [DF_t_approvals_c_PartitionId] DEFAULT(1),
	CONSTRAINT [PK_t_approvals] PRIMARY KEY CLUSTERED([id_approval] ASC) ON [PRIMARY]
) ON [PRIMARY]
