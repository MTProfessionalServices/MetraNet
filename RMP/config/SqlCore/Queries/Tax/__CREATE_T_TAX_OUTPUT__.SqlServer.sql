
			create table %%TABLE_NAME%% (
			id_tax_charge	bigint primary key not null,
			tax_fed_amount	decimal(22,10),
			tax_fed_name	nvarchar(255),
			tax_fed_rounded	decimal(22,10),
			tax_state_amount decimal(22,10),		
			tax_state_name	 nvarchar(255),	
			tax_state_rounded decimal(22,10),		
			tax_county_amount decimal(22,10),		
			tax_county_name		nvarchar(255),	
			tax_county_rounded decimal(22,10),	
			tax_local_amount	decimal(22,10),	
			tax_local_name		nvarchar(255),	
			tax_local_rounded	decimal(22,10),	
			tax_other_amount	decimal(22,10),	
			tax_other_name		nvarchar(255),	
			tax_other_rounded	decimal(22,10)
			)
      