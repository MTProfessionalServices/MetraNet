create table SalesRep (
			InstanceId varchar2(1) null,
            MetraNetId int not null,
            ExternalId nvarchar2(255) not null,
            CustomerId int not null,
            Percentage int not null,
            RelationshipType nvarchar2(100) null )