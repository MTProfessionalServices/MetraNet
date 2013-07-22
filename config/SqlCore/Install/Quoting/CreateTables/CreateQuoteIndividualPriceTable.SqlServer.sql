
CREATE TABLE QuoteIndividualPrice
(
	[Id] [uniqueidentifier] NOT NULL PRIMARY KEY,
	[QuoteId] [int] NOT NULL,
	[ProductOfferingId] [int] NOT NULL FOREIGN KEY REFERENCES t_po(id_po),
	[PriceableItemInstanceId] [int] NOT NULL FOREIGN KEY REFERENCES t_pi(id_pi),
	[ParameterTableId] [int] NOT NULL FOREIGN KEY REFERENCES t_rulesetdefinition(id_paramtable),
	[RateSchedules] [xml] NOT NULL
)