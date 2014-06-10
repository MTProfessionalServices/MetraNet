create table CurrencyExchangeMonthly
(
InstanceId nvarchar2(64),
StartDate datetime NOT NULL,
EndDate datetime NOT NULL,
SourceCurrency nvarchar2(100) NOT NULL,
TargetCurrency nvarchar2(100) NOT NULL,
ExchangeRate number(22,10) NOT NULL
)