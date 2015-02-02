USE [NetMeter]
GO

/****** Object:  Table [dbo].[t_message_mapping]    Script Date: 10/16/2014 07:18:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[t_message_mapping](
	[ID_MESSAGE] [int] NOT NULL,
	[ID_ORIGIN_MESSAGE] [int] NOT NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[t_message_mapping] ADD  CONSTRAINT [pk_t_message_mapping] PRIMARY KEY CLUSTERED 
(
	[id_origin_message] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
