
create global temporary table po_cycle_type_mapping
(
  id_po number(10) NOT NULL,
  id_cycle_type number(10) NOT NULL
) on commit preserve rows

