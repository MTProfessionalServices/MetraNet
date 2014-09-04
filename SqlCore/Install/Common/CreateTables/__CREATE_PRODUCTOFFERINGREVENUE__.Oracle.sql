create table ProductOfferingRevenue
(
InstanceId nvarchar2(64),
ProductOfferingId int NOT NULL,
Year int NOT NULL,
Month int NOT NULL,
RevPrimaryCurrency number(22,10) NOT NULL
)