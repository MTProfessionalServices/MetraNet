create table ProductOffering
(
InstanceId nvarchar2(64),
ProductOfferingId int NOT NULL,
ProductOfferingName nvarchar2(255),
IsUserSubscribable char(1) NOT NULL,
IsUserUnsubscribable char(1) NOT NULL,
IsHidden char(1) NOT NULL,
EffectiveStartDate date NOT NULL,
EffectiveEndDate date NOT NULL,
AvailableStartDate date NOT NULL,
AvailableEndDate date NOT NULL
)