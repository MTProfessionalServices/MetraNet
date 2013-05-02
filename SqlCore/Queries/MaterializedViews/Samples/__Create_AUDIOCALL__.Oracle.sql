
		execute immediate 'create table %%AUDIOCALL%%
		(
		id_acc number(10),
		amount numeric(22,10),
		c_actualduration numeric(22,10),
		c_bridgeamount numeric(22,10),
		c_setupcharge numeric(22,10),
		numtransactions number(10)
		)';
	