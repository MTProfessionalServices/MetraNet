create table SubscriptionParticipants
(
InstanceId nvarchar(64),
ProductOfferingId int NOT NULL,
Year int NOT NULL,
Month int NOT NULL,
TotalParticipants int NOT NULL,
DistinctHierarchies int NOT NULL,
NewParticipants int NOT NULL,
UnsubscribedParticipants int NOT NULL
)