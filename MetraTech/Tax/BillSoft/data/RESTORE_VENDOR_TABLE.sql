USE NETMETER
GO
drop table t_tax_vendor
GO
create table t_tax_vendor (
	id_vendor int not null,
	nm_name varchar(255) not null,
	tx_description varchar(255) not null,
	tx_version varchar(255) not null
)
GO
BULK INSERT t_tax_vendor FROM 'S:\MetraTech\Tax\unittests\t_tax_vendor_data.csv'
WITH (
	FIELDTERMINATOR =',', 
	ROWTERMINATOR = '\n'
)
GO
