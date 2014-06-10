create table ProductOffering
(
InstanceId nvarchar(64),
ProductOfferingId int NOT NULL,
ProductOfferingName nvarchar(255),
IsUserSubscribable char(1) NOT NULL,
IsUserUnsubscribable char(1) NOT NULL,
IsHidden char(1) NOT NULL,
EffectiveStartDate datetime NOT NULL,
EffectiveEndDate datetime NOT NULL,
AvailableStartDate datetime NOT NULL,
AvailableEndDate datetime NOT NULL
)