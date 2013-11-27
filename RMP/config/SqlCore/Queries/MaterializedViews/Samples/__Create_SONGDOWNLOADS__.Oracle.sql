
		execute immediate 'create table %%SONGDOWNLOADS%%
		(
			id_acc number(10),
			id_usage_interval number(10),
			amount numeric(22,10),
			c_totalsongs numeric(22,10),
			c_totalbytes numeric(22,10),
			numtransactions number(10)
		)';
	