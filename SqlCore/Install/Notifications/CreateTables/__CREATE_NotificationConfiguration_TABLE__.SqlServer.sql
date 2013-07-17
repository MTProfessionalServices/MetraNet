CREATE TABLE [NotificationConfiguration](
	[EntityId] [uniqueidentifier] NOT NULL,
	[ExternalId] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[CreationDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[EventType] [nvarchar](max) NULL,
	[NotificationEndpointEntityId] [uniqueidentifier] NOT NULL,
	[EmailTemplate] [nvarchar](max) NULL,
 CONSTRAINT [PK_NotificationConfiguration] PRIMARY KEY CLUSTERED 
(
	[EntityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE NotificationConfiguration  WITH CHECK ADD  CONSTRAINT [FK_NotificationConfiguration_NotificationEndpoint_NotificationEndpointEntityId] FOREIGN KEY([NotificationEndpointEntityId])
REFERENCES NotificationEndpoint ([EntityId])
GO

ALTER TABLE NotificationConfiguration CHECK CONSTRAINT [FK_NotificationConfiguration_NotificationEndpoint_NotificationEndpointEntityId]
GO