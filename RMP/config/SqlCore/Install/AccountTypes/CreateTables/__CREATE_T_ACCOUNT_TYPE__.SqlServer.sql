/*
	<initialization table="t_account_type">
		<primary_key>
			<field name="name" alt_name="id_type"/>
		</primary_key>
	</initialization>
*/
create table t_account_type
(
  -- unique ID representing this account type
  id_type int identity(1,1) constraint pk_t_account_type PRIMARY KEY,
  name varchar(200) NOT NULL,
  b_CanSubscribe char(1) NOT NULL,
  b_CanBePayer char(1) NOT NULL,
  b_CanHaveSyntheticRoot char(1) NOT NULL,
  b_CanParticipateInGSub char(1) NOT NULL,
  b_IsVisibleInHierarchy char(1) NOT NULL,
  b_CanHaveTemplates char(1) NOT NULL,
  b_IsCorporate char(1) NOT NULL,
  nm_description varchar(512)
)
alter table t_account_type add constraint uk_t_account_type_name UNIQUE (name)
			