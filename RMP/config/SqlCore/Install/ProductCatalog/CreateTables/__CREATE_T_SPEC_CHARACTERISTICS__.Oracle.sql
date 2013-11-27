
            CREATE TABLE t_spec_characteristics
            (
              id_spec	int not null ,
              c_spec_type	int not null,
              id_category int not null,
              c_category	nvarchar2(20),
              c_is_required	char(1) not null,
              n_description int not null,
              nm_description	nvarchar2(255),
              n_name int not null,
              nm_name	nvarchar2(20),
              c_user_visible	char(1) not null,
              c_user_editable	char(1) not null,
              c_min_value nvarchar2(30),
              c_max_value nvarchar2(30),
              constraint t_spec_characteristics_PK primary key (id_spec)
             )
           