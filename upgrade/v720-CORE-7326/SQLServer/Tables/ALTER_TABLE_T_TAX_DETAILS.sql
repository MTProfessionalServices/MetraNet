ALTER TABLE t_tax_details
DROP CONSTRAINT pk_t_tax_details 
ALTER TABLE t_tax_details
ADD CONSTRAINT pk_t_tax_details PRIMARY KEY
(
	[id_tax_run] ASC,
	[id_tax_detail] ASC,
	[id_tax_charge] ASC,
	[id_usage_interval] ASC
)