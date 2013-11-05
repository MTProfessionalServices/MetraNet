
CREATE TABLE t_acc_template_valid_subs (
    id_acc_template_session number(10) not null,
    id_po                   number(10),
    id_group                number(10),
    sub_start               date,
    sub_end                 date,
    po_start                date,
    po_end                  date
);
