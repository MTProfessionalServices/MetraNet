create table SubscriptionUnits
(
InstanceId nvarchar(64),
SubscriptionId int NOT NULL,
StartDate datetime NOT NULL,
EndDate datetime NOT NULL,
UdrcId int NOT NULL,
UdrcName nvarchar(255) NOT NULL,
UnitName nvarchar(255) NOT NULL,
Units numeric(22,10) NOT NULL
)