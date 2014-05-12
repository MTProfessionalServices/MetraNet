create table CurrencyExchangeMonthly
(
InstanceId nvarchar(64),
StartDate datetime NOT NULL,
EndDate datetime,
SourceCurrency nvarchar(100) NOT NULL,
TargetCurrency nvarchar(100) NOT NULL,
ExchangeRate numeric(22,10) NOT NULL
)