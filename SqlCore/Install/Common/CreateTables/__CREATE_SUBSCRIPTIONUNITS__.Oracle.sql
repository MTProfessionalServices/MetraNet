create table SubscriptionUnits
(
InstanceId nvarchar2(64),
SubscriptionId int NOT NULL,
StartDate datetime NOT NULL,
EndDate datetime NOT NULL,
UdrcId int NOT NULL,
UdrcName nvarchar2(255) NOT NULL,
UnitName nvarchar2(255) NOT NULL,
Units number(22,10) NOT NULL
)