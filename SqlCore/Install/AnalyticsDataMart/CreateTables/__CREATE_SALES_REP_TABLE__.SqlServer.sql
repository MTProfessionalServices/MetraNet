create table SalesRep (
			InstanceId varchar(64),
            MetraNetId int not null,
            ExternalId nvarchar(255) not null,
            CustomerId int not null,
            Percentage int not null,
            RelationshipType nvarchar(100) null )