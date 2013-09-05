
CREATE TABLE QuoteIndividualPrice
(
	[Id] [uniqueidentifier] NOT NULL PRIMARY KEY,
	[QuoteId] [int] NOT NULL,
	[AccountId] [int] NOT NULL FOREIGN KEY REFERENCES t_account(id_acc),
	[ProductOfferingId] [int] NOT NULL FOREIGN KEY REFERENCES t_po(id_po),
	[PriceableItemInstanceId] [int] NOT NULL FOREIGN KEY REFERENCES t_base_props(id_prop),
	[ParameterTableId] [int] NOT NULL FOREIGN KEY REFERENCES t_rulesetdefinition(id_paramtable),
	[RateSchedules] [xml] NOT NULL
)