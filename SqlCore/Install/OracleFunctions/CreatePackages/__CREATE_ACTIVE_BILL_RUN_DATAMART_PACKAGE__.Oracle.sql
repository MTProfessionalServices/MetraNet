create or replace type ActiveBillRunWidgetTblType as object(
RowNumber int,
Adapter nvarchar2(200),
Duration int,
Average int
);
/
create or replace package active_bill_run_pkg as
TYPE ActiveBillRunWidgetTable is table of ActiveBillRunWidgetTblType;
function GetActvCurAverage(v_id_interval int) return ActiveBillRunWidgetTable
  pipelined;
end;
