create table SubscriptionSummary
(
InstanceId nvarchar(64),
ProductOfferingId int NOT NULL,
Year int NOT NULL,
Month int NOT NULL,
TotalParticipants int NOT NULL,
DistinctHierarchies int NOT NULL,
NewParticipants int NOT NULL,
MRRPrimaryCurrency numeric(22,10) NOT NULL,
MRRNewPrimaryCurrency numeric(22,10) NOT NULL,
MRRBasePrimaryCurrency numeric(22,10) NOT NULL,
MRRRenewalPrimaryCurrency numeric(22,10) NOT NULL,
MRRPriceChangePrimaryCurrency numeric(22,10) NOT NULL,
MRRChurnPrimaryCurrency numeric(22,10) NOT NULL,
MRRCancelationPrimaryCurrency numeric(22,10) NOT NULL,
SubscriptionRevPrimaryCurrency numeric(22,10) NOT NULL,
DaysInMonth int NOT NULL
)