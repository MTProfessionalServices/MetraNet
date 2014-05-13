create table SalesRep (
			InstanceId varchar2(64),
            MetraNetId int not null,
            ExternalId nvarchar2(255) not null,
            CustomerId int not null,
            Percentage int not null,
            RelationshipType nvarchar2(100) null )