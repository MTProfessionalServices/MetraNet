
CREATE TABLE t_account_type_view_map
(
  id_type number(10) NOT NULL,
  id_account_view number(10) NOT NULL,
  account_view_name nvarchar2(256) NOT NULL,
  CONSTRAINT pk_t_account_view_map PRIMARY KEY (id_type, id_account_view)
)
