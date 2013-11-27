use %%NETMETER%%

alter table t_payment_instrument
	alter column tx_hash nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL