create table ProductOffering
(
InstanceId nvarchar2(64),
ProductOfferingId int NOT NULL,
ProductOfferingName nvarchar2(255),
IsUserSubscribable char(1) NOT NULL,
IsUserUnsubscribable char(1) NOT NULL,
IsHidden char(1) NOT NULL,
EffectiveStartDate datetime NOT NULL,
EffectiveEndDate datetime,
AvailableStartDate datetime NOT NULL,
AvailableEndDate datetime
)