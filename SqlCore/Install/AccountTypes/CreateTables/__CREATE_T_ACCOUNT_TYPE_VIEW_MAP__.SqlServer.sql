
CREATE TABLE t_account_type_view_map
(
  id_type INT NOT NULL,
  id_account_view int NOT NULL,
  account_view_name nvarchar(256) NOT NULL,
  CONSTRAINT pk_t_account_view_map PRIMARY KEY CLUSTERED (id_type, id_account_view)
)
			