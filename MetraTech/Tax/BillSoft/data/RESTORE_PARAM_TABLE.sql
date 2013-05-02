USE NETMETER
GO
drop table t_tax_vendor_params
GO
create table t_tax_vendor_params (
	id_vendor int not null,
	tx_canonical_name varchar(255) not null,
	tx_type varchar(255) not null,
	tx_default varchar(255) not null,
	tx_description varchar(255) not null,
	constraint pk_t_tax_vendor_params_id_vendor primary key(id_vendor, tx_canonical_name)
)
BULK INSERT t_tax_vendor_params FROM 'C:\dev\6.7.0-Development\UnitTests\MetraTech\Tax\BillSoft\data\t_tax_param_data_good.csv'
WITH (
	FIELDTERMINATOR =',', 
	ROWTERMINATOR = '\n'
)
GO
