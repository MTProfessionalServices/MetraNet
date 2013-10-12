
CREATE TABLE QuoteIndividualPrice
(
	[Id] [uniqueidentifier] NOT NULL PRIMARY KEY,
	[QuoteId] [int] NOT NULL,
	[CurrentChargeType] nvarchar(50) NOT NULL,	
	[ProductOfferingId] [int] NOT NULL,
	[ChargesRates] [xml] NOT NULL
)