/*
<inits>
	<initialization table="t_mt_id" default="true">
		<dependent_insert/>
	</initialization>
	<initialization table="t_enum_data">
		<primary_key>
			<field name="nm_enum_data" alt_name="id_enum_data"/>
		</primary_key>
		<join>
			<field name="id_enum_data" remote_name="id_mt" table="t_mt_id" insert_only="true"/>
		</join>
	</initialization>
	<initialization table="t_tariff">
		<primary_key>
			<field name="id_enum_tariff" remote_name="nm_enum_data"/>
		</primary_key>
		<join>
			<field name="id_enum_tariff" remote_name="id_enum_data" table="t_enum_data"/>
		</join>
	</initialization>
</inits>
*/

insert into t_mt_id (id_mt) values (12345);

insert into t_mt_id (id_mt) values (65432);

insert into t_enum_data (id_enum_data, nm_enum_data) values (12345, 'metratech.com/tariffs/TariffID/Default');

insert into t_enum_data (id_enum_data, nm_enum_data) values (65432, 'metratech.com/tariffs/TariffID/ConferenceExpress');

insert into t_tariff (id_enum_tariff, tx_currency) values (12345, 'USD');

insert into t_tariff (id_enum_tariff, tx_currency) values (65432, 'USD');

