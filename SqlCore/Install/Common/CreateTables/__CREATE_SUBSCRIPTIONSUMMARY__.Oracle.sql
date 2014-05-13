create table SubscriptionSummary
(
InstanceId nvarchar2(64),
ProductOfferingId int NOT NULL,
Year int NOT NULL,
Month int NOT NULL,
TotalParticipants int NOT NULL,
DistinctHierarchies int NOT NULL,
NewParticipants int NOT NULL,
MRRPrimaryCurrency number(22,10) NOT NULL,
MRRNewPrimaryCurrency number(22,10) NOT NULL,
MRRBasePrimaryCurrency number(22,10) NOT NULL,
MRRRenewalPrimaryCurrency number(22,10) NOT NULL,
MRRPriceChangePrimaryCurrency number(22,10) NOT NULL,
MRRChurnPrimaryCurrency number(22,10) NOT NULL,
MRRCancelationPrimaryCurrency number(22,10) NOT NULL,
SubscriptionRevPrimaryCurrency number(22,10) NOT NULL,
DaysInMonth int NOT NULL
)