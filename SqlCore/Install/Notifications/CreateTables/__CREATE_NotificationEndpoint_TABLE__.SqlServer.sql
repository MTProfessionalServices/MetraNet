CREATE TABLE [NotificationEndpoint](
	[EntityId] [uniqueidentifier] NOT NULL,
	[ExternalId] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[CreationDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[Active] [bit] NOT NULL,
	[EndpointConfiguration] [nvarchar](max) NULL,
	[AuthenticationConfiguration] [nvarchar](max) NULL,
 CONSTRAINT [PK_NotificationEndpoint] PRIMARY KEY CLUSTERED 
(
	[EntityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]									 