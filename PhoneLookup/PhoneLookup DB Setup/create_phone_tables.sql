CREATE TABLE [phone_device] (
	[name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[lineaccess] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[countryname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[nationalcode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]

CREATE TABLE [phone_country] (
	[name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[internationalaccesscode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[countrycode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[nationalaccesscode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[nationalcodetable] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[primarycountrycode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]

CREATE TABLE [phone_region] (
	[code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[countryname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[international] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[tollfree] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[localcodetable] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]