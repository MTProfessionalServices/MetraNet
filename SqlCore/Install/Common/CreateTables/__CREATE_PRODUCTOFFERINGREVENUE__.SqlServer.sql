create table ProductOfferingRevenue
(
InstanceId nvarchar(64),
ProductOfferingId int NOT NULL,
Year int NOT NULL,
Month int NOT NULL,
RevPrimaryCurrency numeric(22,10) NOT NULL
)